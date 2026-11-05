begin;
do $$declare u uuid:=gen_random_uuid();r jsonb;s uuid;t uuid;denied boolean:=false;begin
insert into auth.users(id) values(u);perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);execute 'set local role authenticated';
r:=public.create_owner_business_industry_v2('QA DST','qa-dst-'||substr(u::text,1,8),'QA Professional','QA Service',30,2500,'beauty','Europe/London','GBP');
select id into s from public.staff where business_id=(r->>'business_id')::uuid;
t:=public.owner_add_time_off_local(s,'2026-10-24 10:00','2026-10-24 11:00','QA BST');assert (select starts_at='2026-10-24 09:00+00'::timestamptz from public.time_off where id=t);
t:=public.owner_add_time_off_local(s,'2026-10-26 10:00','2026-10-26 11:00','QA GMT');assert (select starts_at='2026-10-26 10:00+00'::timestamptz from public.time_off where id=t);
begin perform public.owner_add_time_off_local(s,'2027-03-28 01:30','2027-03-28 03:00','QA missing hour');exception when others then assert sqlerrm='INVALID_LOCAL_TIME';denied:=true;end;assert denied;
end $$;rollback;
