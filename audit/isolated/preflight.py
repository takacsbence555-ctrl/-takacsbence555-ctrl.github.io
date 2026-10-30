"""Validate the read-only preflight on the disposable CI schema, never production."""
import json,pathlib,subprocess
root=pathlib.Path(__file__).resolve().parents[2]
r=subprocess.run(['docker','compose','-f',str(root/'audit/isolated/compose.yml'),'exec','-T','db','psql','-U','postgres','-v','ON_ERROR_STOP=1','-At'],input=(root/'audit/release-preflight.sql').read_bytes(),stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True)
x=json.loads(r.stdout)
for key in ['public_tables_rls','hours_are_local_time','booking_exclusion_present','weekly_migration_present','notification_migration_present','anonymous_owner_rpc_denied']:assert x[key] is True,key
for key in ['anonymous_table_grants','dangerous_authenticated_grants']:assert x[key]==0,key
assert x['missing_functions']==[],x['missing_functions']
print('PASS read-only schema preflight: required signatures, RLS, client grants, local-time type, booking exclusion and candidate migrations')
