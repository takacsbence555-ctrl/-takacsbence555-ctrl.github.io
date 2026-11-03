"""Standard age CLI interoperability drill with EPHEMERAL SYNTHETIC keys only.

Does not accept a founder identity, public recipient, database URL or upload target.
Never prints identities, recipients, passphrases, raw archive bytes or CLI stderr.
"""
import hashlib,json,os,pathlib,subprocess,tempfile

def checked(args):
    result=subprocess.run(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    if result.returncode:raise RuntimeError('Synthetic age command failed (output withheld)')
    return result.stdout

def round_trip(archive,directory):
    p=pathlib.Path(directory)
    for name in ['synthetic.identity','wrong.identity']:
        checked(['age-keygen','-o',str(p/name)])
        os.chmod(p/name,0o600)
    # Only the generated public recipient reaches the encryption command.
    recipient=checked(['age-keygen','-y',str(p/'synthetic.identity')]).decode().strip()
    source=p/'age-input.dump';source.write_bytes(archive);os.chmod(source,0o600)
    encrypted=p/'synthetic.dump.age'
    checked(['age','--encrypt','--recipient',recipient,'--output',str(encrypted),str(source)])
    original=encrypted.read_bytes()
    args=['age','--decrypt','--identity',str(p/'synthetic.identity'),str(encrypted)]
    plain=checked(args)
    assert hashlib.sha256(plain).digest()==hashlib.sha256(archive).digest(),'Age round-trip mismatch'
    wrong=subprocess.run(['age','--decrypt','--identity',str(p/'wrong.identity'),str(encrypted)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    assert wrong.returncode!=0,'Wrong identity accepted'
    for bad in [original[:-1],original[:-1]+bytes([original[-1]^1])]:
        encrypted.write_bytes(bad)
        result=subprocess.run(args,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        assert result.returncode!=0,'Corrupt or truncated age archive accepted'
    encrypted.write_bytes(original)
    return plain,{'age_x25519_roundtrip':True,'wrong_identity_rejected':True,'age_tampering_rejected':True,'age_truncation_rejected':True,'founder_identity_used':False,'iphone_recovery_verified':False}

def main():
    with tempfile.TemporaryDirectory(prefix='kavelyq-synthetic-age-') as directory:
        os.chmod(directory,0o700)
        _,result=round_trip(b'Synthetic fixture only\n'*4096,directory)
        print(json.dumps(result))

if __name__=='__main__':main()
