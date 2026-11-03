"""Rehearse BOTH pending migrations transactionally on disposable Docker only.

No hosted URL, credentials or external command arguments are accepted.
"""
import hashlib,json,pathlib,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[2]
COMMAND=['docker','compose','-f',str(ROOT/'audit/isolated/compose.yml'),'exec','-T','db','psql','-U','postgres','-At','-v','ON_ERROR_STOP=1']
def sql(text,check=True):
    return subprocess.run(COMMAND,input=text.encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=check)
def fingerprint():
    return sql("select md5(string_agg(x,'|' order by x)) from (select pg_get_functiondef(p.oid) x from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname in('public','kavelyq_private') union all select schemaname||'.'||tablename from pg_tables where schemaname in('public','kavelyq_private')) s;").stdout
paths=['audit/owner-atomic-hours.pending.sql','audit/notification-adapter.pending.sql']
parts=[]
for name in paths:
    text=(ROOT/name).read_text();assert text.count('begin;')>=1 and text.rstrip().endswith('commit;')
    # Remove only the OUTER transaction, preserving PL/pgSQL nested blocks.
    start=text.index('begin;');parts.append(text[:start]+text[start+6:text.rindex('commit;')])
before=fingerprint()
assert sql("select to_regprocedure('public.owner_set_staff_week_hours(uuid,jsonb)') is null and to_regclass('kavelyq_private.notification_delivery_events') is null;").stdout.strip()==b't'
preflight=(ROOT/'audit/release-preflight.sql').read_text()
r=sql('begin;\n'+'\n'.join(parts)+'\n'+preflight+'\nrollback;')
report=json.loads(next(line for line in r.stdout.decode().splitlines() if line.startswith('{')))
for key in ['weekly_migration_present','notification_migration_present','anonymous_owner_rpc_denied']:assert report[key] is True,key
assert fingerprint()==before,'Dry-run rollback changed base schema'
# A drifted legacy guard must reject the migration rather than silently applying an ineffective patch.
drift="""do $$ declare definition text;begin
select pg_get_functiondef('public.complete_email_notification(uuid,text)'::regprocedure) into definition;
definition:=replace(definition,'request.jwt.claim.role','request.jwt.claim.unexpected_role');execute definition;
end $$;
"""
r=sql('begin;\n'+drift+parts[1]+'\nrollback;',check=False)
assert r.returncode!=0 and b'INCOMPATIBLE_NOTIFICATION_BASE' in r.stderr,'Drifted base was not rejected'
assert fingerprint()==before,'Failed migration left partial schema changes'
print(json.dumps({'isolated_migration_order':paths,'transactional_rollback':True,'incompatible_base_rejected':True,'failed_migration_atomic':True,'hosted_changes':False}))
