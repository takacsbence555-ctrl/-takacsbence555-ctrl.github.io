"""Standard age CLI drills with EPHEMERAL SYNTHETIC identities only.

No CLI parameters, founder identity, recipient, passphrase, PDF, database URL or
upload target are accepted. Never print CLI output, keys or recovery material.
"""
import fcntl,hashlib,json,os,pathlib,pty,secrets,select,subprocess,sys,tempfile,termios,time

def checked(args):
    result=subprocess.run(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    if result.returncode:raise RuntimeError('Synthetic age command failed (output withheld)')
    return result.stdout

def atomic_decrypt_for_drill(identity,encrypted,target):
    """Quarantine CLI output until FINAL authentication succeeds; never overwrite.

    Called only with generated synthetic paths. Never pipe streaming decryption
    directly into pg_restore: a late corrupt chunk can follow valid plaintext.
    """
    fd,name=tempfile.mkstemp(prefix='.age-quarantine-',dir=target.parent)
    os.close(fd);staging=pathlib.Path(name)
    try:
        result=subprocess.run(['age','--decrypt','--identity',str(identity),'--output',str(staging),str(encrypted)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        if result.returncode:return False
        with staging.open('rb') as f:os.fsync(f.fileno())
        # Same-filesystem, atomic, exclusive publication: existing files survive.
        os.link(staging,target)
        return True
    finally:
        staging.unlink(missing_ok=True)

def passphrase_cli_for_drill(args,password,encrypt=False):
    """Feed only a GENERATED test passphrase over a non-echoing local terminal.

    age intentionally has no command-line passphrase flag. Do not put one in
    argv, environment variables, logs or a source fixture to automate tests.
    """
    master,slave=pty.openpty()
    attrs=termios.tcgetattr(slave);attrs[3]&=~termios.ECHO
    termios.tcsetattr(slave,termios.TCSANOW,attrs)
    def terminal():
        os.setsid();fcntl.ioctl(0,termios.TIOCSCTTY,0)
    process=None
    try:
        process=subprocess.Popen(args,stdin=slave,stdout=slave,stderr=slave,preexec_fn=terminal,close_fds=True)
        os.close(slave);slave=None
        prompts=[b'Enter passphrase',b'Confirm passphrase'] if encrypt else [b'Enter passphrase']
        answered=0;buffer=b'';deadline=time.monotonic()+60
        while process.poll() is None:
            if time.monotonic()>deadline:raise RuntimeError('Synthetic passphrase drill timed out')
            if not select.select([master],[],[],0.1)[0]:continue
            try:chunk=os.read(master,4096)
            except OSError:break
            if not chunk:break
            buffer=(buffer+chunk)[-8192:]
            if answered<len(prompts) and prompts[answered] in buffer:
                buffer=b'';os.write(master,password.encode()+b'\n');answered+=1
        return process.wait(timeout=5),answered
    finally:
        if process is not None and process.poll() is None:
            process.kill();process.wait()
        os.close(master)
        if slave is not None:os.close(slave)

def recovery_identity_for_drill(p,recipient,archive,encrypted):
    # This models the ARMORED AGE PAYLOAD embedded in a protected paper PDF,
    # not the native iOS PDF renderer, QR scanner or the founder's actual file.
    password=secrets.token_hex(16)
    protected=p/'synthetic-recovery-payload.age'
    code,prompts=passphrase_cli_for_drill(['age','--passphrase','--armor','--output',str(protected),str(p/'synthetic.identity')],password,encrypt=True)
    assert code==0 and prompts==2,'Synthetic recovery sealing failed'
    assert b'BEGIN AGE ENCRYPTED FILE' in protected.read_bytes()
    recovered=p/'recovered.identity'
    code,prompts=passphrase_cli_for_drill(['age','--decrypt','--output',str(recovered),str(protected)],password)
    assert code==0 and prompts==1,'Synthetic recovery opening failed'
    os.chmod(recovered,0o600)
    assert checked(['age-keygen','-y',str(recovered)]).decode().strip()==recipient,'Recovered recipient mismatch'
    # Prove recovered material works while the ORIGINAL identity is unavailable.
    original=p/'synthetic.identity';original.unlink()
    assert not original.exists(),'Original synthetic identity still exists'
    restored=p/'recovered-identity-plaintext.dump'
    assert atomic_decrypt_for_drill(recovered,encrypted,restored)
    assert restored.read_bytes()==archive,'Recovered identity did not decrypt original archive'
    rejected=p/'wrong-passphrase.identity'
    code,_=passphrase_cli_for_drill(['age','--decrypt','--output',str(rejected),str(protected)],secrets.token_hex(16))
    assert code!=0,'Wrong recovery passphrase accepted'
    assert not rejected.exists() or rejected.stat().st_size==0,'Failed key recovery exposed plaintext'
    rejected.unlink(missing_ok=True)
    damaged=p/'damaged-recovery-payload.age';failed_identity=p/'damaged-recovery.identity'
    protected_bytes=protected.read_bytes()
    lines=protected_bytes.splitlines(keepends=True)
    changed=bytearray(lines[1]);changed[0]=ord('A') if changed[0]!=ord('A') else ord('B')
    for data in [b''.join([lines[0],bytes(changed),*lines[2:]]),protected_bytes[:-40]]:
        damaged.write_bytes(data)
        code,_=passphrase_cli_for_drill(['age','--decrypt','--output',str(failed_identity),str(damaged)],password)
        assert code!=0,'Damaged recovery payload accepted'
        assert not failed_identity.exists() or failed_identity.stat().st_size==0,'Damaged recovery exposed plaintext'
        failed_identity.unlink(missing_ok=True)
    # A missing identity must not publish even an empty restored archive.
    missing=p/'missing-identity.dump'
    assert not atomic_decrypt_for_drill(p/'nonexistent.identity',encrypted,missing)
    assert not missing.exists()
    return restored.read_bytes(),{'protected_identity_recovery':True,'recovered_identity_decrypts_without_original':True,'wrong_recovery_passphrase_rejected':True,'damaged_recovery_payload_rejected':True,'missing_identity_rejected':True,'native_pdf_recovery_tested':False}

def round_trip(archive,directory):
    p=pathlib.Path(directory)
    for name in ['synthetic.identity','wrong.identity']:
        checked(['age-keygen','-o',str(p/name)]);os.chmod(p/name,0o600)
    recipient=checked(['age-keygen','-y',str(p/'synthetic.identity')]).decode().strip()
    source=p/'age-input.dump';source.write_bytes(archive);os.chmod(source,0o600)
    encrypted=p/'synthetic.dump.age'
    # Public-recipient-only encryption. No private identity/passphrase passed.
    checked(['age','--encrypt','--recipient',recipient,'--output',str(encrypted),str(source)])
    invalid=subprocess.run(['age','--encrypt','--recipient','age1-invalid-test-recipient','--output',str(p/'invalid-recipient.age'),str(source)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    assert invalid.returncode!=0,'Malformed recipient accepted'
    original=encrypted.read_bytes();output=p/'verified-plaintext.dump'
    assert atomic_decrypt_for_drill(p/'synthetic.identity',encrypted,output)
    plain=output.read_bytes()
    assert hashlib.sha256(plain).digest()==hashlib.sha256(archive).digest(),'Age round-trip mismatch'
    rejected=p/'rejected-plaintext.dump'
    assert not atomic_decrypt_for_drill(p/'wrong.identity',encrypted,rejected)
    assert not rejected.exists()
    # Header, payload, late corruption and truncation; no partial publication.
    cases=[b'',original[:32],original[:len(original)//2],original[:-1],original[:-1]+bytes([original[-1]^1]),bytes([original[0]^1])+original[1:]]
    for bad in cases:
        encrypted.write_bytes(bad)
        assert not atomic_decrypt_for_drill(p/'synthetic.identity',encrypted,rejected),'Corrupt/truncated archive accepted'
        assert not rejected.exists(),'Partial plaintext was published'
        assert not list(p.glob('.age-quarantine-*')),'Quarantined bytes left behind'
    encrypted.write_bytes(original)
    sentinel=p/'existing-destination.dump';sentinel.write_bytes(b'preserve this existing file')
    try:
        atomic_decrypt_for_drill(p/'synthetic.identity',encrypted,sentinel)
        raise AssertionError('Existing output overwritten')
    except FileExistsError:pass
    assert sentinel.read_bytes()==b'preserve this existing file'
    recovered_plain,recovery=recovery_identity_for_drill(p,recipient,archive,encrypted)
    return recovered_plain,{'age_x25519_roundtrip':True,'malformed_recipient_rejected':True,'wrong_identity_rejected':True,'age_tampering_rejected':True,'age_truncation_rejected':True,'atomic_plaintext_publication':True,'partial_plaintext_removed':True,'existing_destination_preserved':True,**recovery,'founder_identity_used':False,'iphone_recovery_verified':False}

def main():
    # Exercise empty input and both sides of the 64 KiB STREAM boundary.
    for size in [0,1,65535,65536,65537,131089]:
        with tempfile.TemporaryDirectory(prefix='kavelyq-synthetic-age-') as directory:
            os.chmod(directory,0o700)
            _,result=round_trip(bytes(i%251 for i in range(size)),directory)
    print(json.dumps({'payload_sizes_tested':[0,1,65535,65536,65537,131089],**result}))

if __name__=='__main__':
    if len(sys.argv)!=1:raise SystemExit('Synthetic age drill accepts no arguments')
    main()
