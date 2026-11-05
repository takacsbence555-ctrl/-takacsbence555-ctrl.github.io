-- Disposable CI only: every mutation rolls back. No production connection accepted.
begin;
do $$
declare u uuid;bid uuid;sid uuid;days jsonb;before_rows jsonb;after_rows jsonb;tz text;tid uuid;instant timestamptz;
begin
select m.user_id,m.business_id into u,bid from public.business_members m join public.businesses b on b.id=m.business_id where m.role='owner' and b.timezone='Europe/London' limit 1;
assert u is not null,'Owner fixture missing';
select id into sid from public.staff where business_id=bid limit 1;
perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);
select jsonb_agg(jsonb_build_object('weekday',i,'start','10:00','end','18:00','enabled',true)) into days from generate_series(0,6)i;
execute 'set local role authenticated';
foreach tz in array array['UTC','America/Los_Angeles','Asia/Tokyo'] loop
perform set_config('TimeZone',tz,true);
assert public.owner_set_staff_week_hours(sid,days);
assert (select count(*)=7 and bool_and(start_time=time '10:00') from public.working_hours where staff_id=sid),'Business-local hours shifted';
end loop;
select jsonb_agg(to_jsonb(w) order by weekday) into before_rows from public.working_hours w where staff_id=sid;
begin
perform public.owner_set_staff_week_hours(sid,jsonb_set(days,'{6,end}','"09:00"'));
raise exception 'Invalid weekly hours accepted';
exception when others then if sqlerrm<>'INVALID_HOURS' then raise;end if;end;
select jsonb_agg(to_jsonb(w) order by weekday) into after_rows from public.working_hours w where staff_id=sid;
assert before_rows=after_rows,'Invalid week partially persisted';
tid:=public.owner_add_time_off_local(sid,'2027-01-12 10:00','2027-01-12 11:00','CI winter');
select starts_at into instant from public.time_off where id=tid;
assert instant=timestamptz '2027-01-12 10:00+00','Winter local conversion';
tid:=public.owner_add_time_off_local(sid,'2027-07-13 10:00','2027-07-13 11:00','CI summer');
select starts_at into instant from public.time_off where id=tid;
assert instant=timestamptz '2027-07-13 09:00+00','Summer DST conversion';
begin
perform public.owner_add_time_off_local(sid,'2027-03-28 01:30','2027-03-28 03:00','CI DST gap');
raise exception 'DST gap accepted';
exception when others then if sqlerrm<>'INVALID_LOCAL_TIME' then raise;end if;end;
assert not has_function_privilege('anon','public.owner_set_staff_week_hours(uuid,jsonb)','execute');
end $$;
rollback;
\echo PASS local working hours in three database timezones, atomic invalid-week rollback, winter/summer offsets, DST gap rejection and anonymous denial
