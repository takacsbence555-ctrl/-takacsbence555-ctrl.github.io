create temporary table product_extension_results(result jsonb) on commit drop;
do $$
declare bid uuid;sid uuid;vid uuid;bk uuid;u uuid:=gen_random_uuid();r jsonb;checks text[]:=array[]::text[];denied boolean;
begin
 begin
  select id into bid from public.businesses where public_slug='demo-studio';
  insert into auth.users(id) values(u);insert into public.business_members(business_id,user_id,role) values(bid,u,'owner');
  perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);execute 'set local role authenticated';
  r:=public.owner_save_branding('{"accent":"#112233","font":"georgia","logo_url":"https://example.invalid/logo.png","description":"QA branding"}'::jsonb);
  assert r->>'accent'='#112233';assert public.owner_branding_snapshot()->>'font'='georgia';checks:=array_append(checks,'branding saves and persists');
  denied:=false;begin perform public.owner_save_branding('{"accent":"bad","font":"system"}');exception when others then denied:=true;end;assert denied;checks:=array_append(checks,'invalid branding rejected');
  r:=public.owner_import_records('customers','[{"name":"QA Import","email":"qa-import@example.invalid"}]',true);assert jsonb_array_length(r->'errors')=0 and (r->>'inserted')::int=0;
  r:=public.owner_import_records('customers','[{"name":"QA Import","email":"qa-import@example.invalid","marketing_consent":true}]',false);assert (r->>'inserted')::int=1;
  assert exists(select 1 from public.customers where business_id=bid and email='qa-import@example.invalid' and marketing_consent=false);checks:=array_append(checks,'preview/commit and consent remains false');
  r:=public.owner_import_records('customers','[{"name":"QA Import","email":"qa-import@example.invalid"}]',false);assert jsonb_array_length(r->'errors')>0 and (r->>'inserted')::int=0;checks:=array_append(checks,'existing duplicate prevented');
  r:=public.owner_import_records('customers','[{"name":"A One","phone":"+430000000501"},{"name":"B Two","email":"b@example.invalid","phone":"+430000000501"}]',true);assert jsonb_array_length(r->'errors')>0;checks:=array_append(checks,'cross-email phone duplicate detected');
  r:=public.owner_import_records('staff','[{"name":"QA Imported Barber"}]',false);assert (r->>'inserted')::int=1;
  r:=public.owner_import_records('services','[{"name":"QA Imported Service","duration_minutes":30,"price_cents":2500}]',false);assert (r->>'inserted')::int=1;checks:=array_append(checks,'staff/service imports persisted');
  r:=public.owner_import_records('services','[{"name":"Invalid","duration_minutes":2,"price_cents":-1}]',false);assert jsonb_array_length(r->'errors')>0;checks:=array_append(checks,'invalid service import rejected');
  select id into sid from public.staff where business_id=bid and public_slug='demo-barber-a';select id into vid from public.services where business_id=bid and public_slug='classic-cut';
  bk:=public.owner_create_booking_local(bid,sid,vid,current_date+1,'14:00','QA Performance');perform public.owner_update_booking_status(bk,'completed');
  r:=public.owner_calendar_range(current_date,current_date+31,null);assert jsonb_array_length(r)>0;checks:=array_append(checks,'bounded calendar contains recorded appointment');
  r:=public.owner_performance_report(date_trunc('month',current_date)::date,(date_trunc('month',current_date)+interval '1 month')::date);assert jsonb_array_length(r->'staff')>0 and (r->>'visiting_customers')::int=1;checks:=array_append(checks,'real staff/service/retention report');
  assert exists(select 1 from public.business_audit_log where business_id=bid and entity='business_branding');checks:=array_append(checks,'tenant audit metadata recorded');
  perform set_config('request.jwt.claims',jsonb_build_object('sub',gen_random_uuid(),'role','authenticated')::text,true);
  assert public.owner_branding_snapshot()='{}'::jsonb;denied:=false;begin perform public.owner_save_branding('{}');exception when others then denied:=true;end;assert denied;
  denied:=false;begin perform public.owner_import_records('customers','[{"name":"Foreign"}]',false);exception when others then denied:=true;end;assert denied;
  denied:=false;begin perform public.owner_calendar_range(current_date,current_date+1,null);exception when others then denied:=true;end;assert denied;assert (select count(*) from public.business_audit_log)=0;checks:=array_append(checks,'foreign tenant branding/import/calendar/audit denied');
  execute 'reset role';
  u:=gen_random_uuid();insert into auth.users(id) values(u);perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);execute 'set local role authenticated';
  r:=public.create_owner_business_v2('QA UK Setup','qa-uk-'||substr(u::text,1,8),'QA Barber','QA Cut',30,2500,'Europe/London','GBP');assert r->>'timezone'='Europe/London' and r->>'currency'='GBP';checks:=array_append(checks,'UK timezone/currency onboarding');
  execute 'reset role';raise exception 'QA_ROLLBACK';
 exception when others then if sqlerrm<>'QA_ROLLBACK' then raise;end if;end;
 insert into product_extension_results values(jsonb_build_object('passed',checks,'rolled_back',true));
end $$;
select * from product_extension_results;
