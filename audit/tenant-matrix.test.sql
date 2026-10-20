-- Synthetic identities and edits are rolled back; no email is sent.
begin;
do $test$
declare a uuid;b uuid;u uuid:=gen_random_uuid();v uuid:=gen_random_uuid();staff_user uuid:=gen_random_uuid();
s uuid;svc uuid;bk uuid;customer uuid;off_id uuid;d date:=current_date+2;cmd text;denied boolean;t record;n bigint;checks integer:=0;result jsonb;
begin
select id into a from public.businesses where public_slug='demo-studio';
select id into b from public.businesses where public_slug='demo-beauty';
assert a is not null and b is not null;
insert into auth.users(id) values(u),(v),(staff_user);
insert into public.business_members(business_id,user_id,role) values(a,u,'owner'),(b,v,'owner'),(a,staff_user,'staff');
select id into s from public.staff where business_id=b and active limit 1;
select id into svc from public.services where business_id=b and active limit 1;
while extract(dow from d)=0 loop d:=d+1;end loop;
perform set_config('request.jwt.claims',jsonb_build_object('sub',v,'role','authenticated')::text,true);
execute 'set local role authenticated';
bk:=public.owner_create_booking_local(b,s,svc,d,'13:00','QA Tenant Boundary');
execute 'reset role';
select customer_id into customer from public.bookings where id=bk;
insert into public.time_off(staff_id,starts_at,ends_at,reason) values(s,(d+1+'18:00'::time) at time zone 'Europe/London',(d+1+'19:00'::time) at time zone 'Europe/London','QA boundary') returning id into off_id;
perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);
execute 'set local role authenticated';
assert public.owner_dashboard()->'business'->>'id'=a::text;
foreach cmd in array array[
format('select public.owner_update_staff(%L::uuid,%L,true)',s,'QA Forbidden'),
format('select public.owner_update_service(%L::uuid,%L,45,3500,true)',svc,'QA Forbidden'),
format('select public.owner_set_staff_service(%L::uuid,%L::uuid,false)',s,svc),
format('select public.owner_set_working_hours(%L::uuid,1,%L::time,%L::time,true)',s,'09:00','17:00'),
format('select public.owner_add_time_off_local(%L::uuid,%L::timestamp,%L::timestamp,%L)',s,(d+3)::text||' 18:00',(d+3)::text||' 19:00','QA Forbidden'),
format('select public.owner_remove_time_off(%L::uuid)',off_id),
format('select public.owner_create_booking_local(%L::uuid,%L::uuid,%L::uuid,%L::date,%L::time,%L)',b,s,svc,d,'14:00','QA Forbidden'),
format('select public.owner_reschedule_booking_local(%L::uuid,%L::date,%L::time)',bk,d,'14:00'),
format('select public.owner_update_booking_status(%L::uuid,%L)',bk,'no_show'),
format('select public.owner_cancel_booking(%L::uuid)',bk),
format('select public.owner_save_cut_memory(%L::uuid,%L,28)',customer,'QA Forbidden'),
format('select public.owner_set_marketing_consent(%L::uuid,true)',customer),
format('select public.owner_export_customer(%L::uuid)',customer),
format('select public.owner_delete_customer_data(%L::uuid)',customer)
] loop
denied:=false;
begin execute 'select to_jsonb(('||substr(cmd,8)||'))' into result;denied:=result='false'::jsonb;exception when insufficient_privilege or raise_exception then denied:=true;end;
assert denied,'Foreign object RPC was accepted: '||cmd;checks:=checks+1;
end loop;
for t in select table_name from information_schema.columns where table_schema='public' and column_name='business_id' loop
begin execute format('select count(*) from public.%I where business_id<>%L::uuid',t.table_name,a) into n;assert n=0,'Foreign rows visible in '||t.table_name;
exception when insufficient_privilege then null;end;
end loop;
assert (select count(*) from public.time_off where staff_id=s)=0;
assert (select count(*) from public.staff_services where staff_id=s)=0;
assert (select count(*) from public.working_hours where staff_id=s)=0;
execute 'reset role';
assert (select display_name from public.customers where id=customer)='QA Tenant Boundary';
assert (select status from public.bookings where id=bk)='confirmed';
assert exists(select 1 from public.time_off where id=off_id);
perform set_config('request.jwt.claims',jsonb_build_object('sub',staff_user,'role','authenticated')::text,true);
execute 'set local role authenticated';
for t in select table_name from information_schema.columns where table_schema='public' and column_name='business_id' and table_name<>'business_members' loop
begin execute format('select count(*) from public.%I',t.table_name) into n;assert n=0,'Staff rows visible in owner-only table '||t.table_name;
exception when insufficient_privilege then null;end;
end loop;
execute 'reset role';
assert checks=14;
raise notice 'PASS 14 cross-tenant RPC denials and all business_id table read boundaries; owner positive control verified';
end $test$;
rollback;
