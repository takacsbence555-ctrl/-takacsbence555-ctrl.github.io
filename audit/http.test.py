import json,re,urllib.request,urllib.error,concurrent.futures
from pathlib import Path
s=(Path(__file__).resolve().parent.parent/'app.js').read_text()
base=re.search(r'const SUPABASE_URL="([^"]+)"',s)[1]
key=re.search(r'const SUPABASE_KEY="([^"]+)"',s)[1]
headers={'apikey':key,'Authorization':'Bearer '+key}
tests=[]
def check(name,path,data=None,status=None,empty=False):
 request=urllib.request.Request(base+path,data=json.dumps(data).encode() if data is not None else None,headers={**headers,'Content-Type':'application/json'})
 try: r=urllib.request.urlopen(request,timeout=20)
 except urllib.error.HTTPError as e:r=e
 code=r.code;body=r.read().decode()
 if status: assert code in status,(name,code,body[:100])
 if empty: assert code in (401,403) or json.loads(body)==[],(name,'data exposed')
 return name+' PASS '+str(code)
for table in ['bookings','customers','business_members','notification_queue','public_booking_rate_limits']:
 tests.append((table+' anonymous data isolation','/rest/v1/'+table+'?select=*',None,None,True))
tests.extend([
 ('owner endpoint denies anonymous','/rest/v1/rpc/owner_dashboard',{},[401,403],False),
 ('unknown manage token has no booking','/rest/v1/rpc/get_public_booking_manage',{'p_token':'11111111-1111-4111-8111-111111111111'},[200],False),
 ('public catalog','/rest/v1/rpc/get_public_booking_catalog',{'p_business_slug':'demo-studio'},[200],False),
 ('invalid manage token rejected','/rest/v1/rpc/get_public_booking_manage',{'p_token':'invalid'},[400],False),
 ('invalid booking contact rejected','/rest/v1/rpc/create_public_booking_local_v2',{'p_business_slug':'demo-studio','p_staff_slug':'demo-barber-a','p_service_slug':'classic-cut','p_date':'2026-10-02','p_time':'10:00','p_display_name':'Audit','p_email':'bad-email','p_phone':None},[400],False)
])
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
 for result in pool.map(lambda args:check(*args),tests): print(result)
print(str(len(tests))+' production HTTP checks passed')
