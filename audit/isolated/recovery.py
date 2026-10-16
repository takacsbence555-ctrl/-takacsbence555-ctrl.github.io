"""An encrypted backup/restore drill restricted to the disposable Docker database.

It never accepts a production URL, exports a hosted database, or uploads a dump/key.
The full dump includes Auth fixture records, application data, policies and grants.
"""
import hashlib,json,os,pathlib,subprocess,tempfile,time,uuid

ROOT=pathlib.Path(__file__).resolve().parents[2]
COMPOSE=['docker','compose','-f',str(ROOT/'audit/isolated/compose.yml')]

def run(args,**kwargs):
    return subprocess.run(args,check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,**kwargs).stdout

def db(args,**kwargs):
    return run(COMPOSE+['exec','-T','db']+args,**kwargs)

def query(database,sql):
    return db(['psql','-U','postgres','-d',database,'-v','ON_ERROR_STOP=1','-At','-c',sql]).decode().strip()

def manifest(database):
    tables=json.loads(query(database,"select json_agg(format('%I.%I',schemaname,tablename) order by schemaname,tablename) from pg_tables where schemaname in ('auth','public','kavelyq_private')"))
    rows={}
    for table in tables:
        value=query(database,"select coalesce(jsonb_agg(to_jsonb(t) order by to_jsonb(t)::text),'[]')::text from "+table+' t')
        rows[table]={'count':len(json.loads(value)),'sha256':hashlib.sha256(value.encode()).hexdigest()}
    structural=query(database,"select jsonb_build_object('policies',(select jsonb_agg(to_jsonb(p) order by schemaname,tablename,policyname) from pg_policies p where schemaname in('public','kavelyq_private')),'functions',(select jsonb_agg(pg_get_functiondef(p.oid) order by n.nspname,p.proname,pg_get_function_identity_arguments(p.oid)) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname in('public','kavelyq_private')),'grants',(select jsonb_agg(to_jsonb(g) order by table_schema,table_name,grantee,privilege_type) from information_schema.role_table_grants g where table_schema in('public','kavelyq_private')),'constraints',(select jsonb_agg(pg_get_constraintdef(c.oid) order by n.nspname,t.relname,c.conname) from pg_constraint c join pg_class t on t.oid=c.conrelid join pg_namespace n on n.oid=t.relnamespace where n.nspname in('public','kavelyq_private')))::text")
    return {'tables':rows,'structure_sha256':hashlib.sha256(structural.encode()).hexdigest()}

def verify_boundaries(database):
    query(database,"""begin; do $$ declare u uuid;b uuid;n integer;begin
    select m.user_id,m.business_id into u,b from public.business_members m limit 1;
    assert u is not null;
    perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);
    execute 'set local role authenticated';
    assert public.owner_dashboard()->'business'->>'id'=b::text;
    assert (select count(*) from public.customers where business_id<>b)=0;
    assert (select count(*) from public.staff where business_id<>b)=0;
    execute 'reset role';
    assert not exists(select 1 from pg_tables where schemaname='public' and not rowsecurity);
    assert not has_function_privilege('anon','public.claim_due_email_notifications(integer)','EXECUTE');
    end $$;rollback;""")

def main():
    # Stop only the local fixture Auth process so the source remains quiescent.
    run(COMPOSE+['stop','auth'])
    before=manifest('postgres');target='qa_restore_'+uuid.uuid4().hex
    assert target.startswith('qa_restore_') and len(target)==43
    started=time.monotonic()
    with tempfile.TemporaryDirectory(prefix='kavelyq-drill-') as directory:
        os.chmod(directory,0o700);p=pathlib.Path(directory)
        archive=db(['pg_dump','-U','postgres','-d','postgres','--format=custom','--serializable-deferrable'])
        (p/'backup.dump').write_bytes(archive);os.chmod(p/'backup.dump',0o600)
        run(['openssl','req','-x509','-newkey','rsa:3072','-nodes','-subj','/CN=KAVELYQ disposable drill','-keyout',str(p/'key.pem'),'-out',str(p/'cert.pem'),'-days','1'])
        os.chmod(p/'key.pem',0o600)
        run(['openssl','cms','-encrypt','-binary','-aes-256-gcm','-outform','DER','-in',str(p/'backup.dump'),'-out',str(p/'backup.cms'),str(p/'cert.pem')])
        plain=run(['openssl','cms','-decrypt','-binary','-inform','DER','-in',str(p/'backup.cms'),'-recip',str(p/'cert.pem'),'-inkey',str(p/'key.pem')])
        assert plain==archive,'Encrypted backup did not round-trip'
        damaged=bytearray((p/'backup.cms').read_bytes());damaged[-1]^=1;(p/'damaged.cms').write_bytes(damaged)
        bad=subprocess.run(['openssl','cms','-decrypt','-binary','-inform','DER','-in',str(p/'damaged.cms'),'-recip',str(p/'cert.pem'),'-inkey',str(p/'key.pem')],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        assert bad.returncode!=0,'Encrypted archive corruption was not rejected'
        db(['createdb','-U','postgres',target])
        db(['pg_restore','-U','postgres','-d',target,'--exit-on-error','--single-transaction'],input=plain)
        after=manifest(target);assert before==after,'Restored rows, functions, policies or grants differ'
        verify_boundaries(target)
        assert manifest('postgres')==before,'Source data changed during drill'
        result={'scope':'isolated synthetic CI database only','tables_verified':len(before['tables']),'backup_sha256':hashlib.sha256(archive).hexdigest(),'encrypted_roundtrip':True,'corruption_rejected':True,'rows_schema_policies_grants_equal':True,'restored_rls_verified':True,'source_unchanged':True,'duration_seconds':round(time.monotonic()-started,2),'production_backup_verified':False}
        (ROOT/'audit/isolated/recovery-result.json').write_text(json.dumps(result,indent=2)+'\n')
        print(json.dumps(result))
    # The whole isolated Compose cluster is removed by CI; no real database is touched.

if __name__=='__main__':main()
