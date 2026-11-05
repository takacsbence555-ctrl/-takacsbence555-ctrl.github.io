begin;
do $$declare b uuid;s uuid;v uuid;u uuid:=gen_random_uuid();d date:=current_date+1;a uuid;other uuid;block uuid;denied boolean;begin
if extract(dow from d)=0 then d:=d+1;end if;
select id into b from public.businesses where public_slug='demo-studio';select id into s from public.staff where business_id=b and public_slug='demo-barber-a';select id into v from public.services where business_id=b and public_slug='classic-cut';
insert into auth.users(id) values(u);insert into public.business_members(business_id,user_id,role) values(b,u,'owner');
perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);execute 'set local role authenticated';
a:=public.owner_create_booking_local(b,s,v,d,'13:00','QA Schedule A');other:=public.owner_create_booking_local(b,s,v,d,'14:00','QA Schedule B');
denied:=false;begin perform public.owner_add_time_off(s,(d+'13:00'::time) at time zone 'Europe/Vienna',(d+'14:00'::time) at time zone 'Europe/Vienna','QA conflict');exception when others then assert sqlerrm='TIME_OFF_CONFLICTS_WITH_BOOKING';denied:=true;end;assert denied;
block:=public.owner_add_time_off(s,(d+'10:00'::time) at time zone 'Europe/Vienna',(d+'11:00'::time) at time zone 'Europe/Vienna','QA break');
assert not (public.get_public_availability('demo-studio','demo-barber-a','classic-cut',d) ? '10:00');
denied:=false;begin perform public.owner_reschedule_booking_local(a,d,'14:00');exception when others then assert sqlerrm='SLOT_ALREADY_BOOKED';denied:=true;end;assert denied;
assert (select starts_at=(d+'13:00'::time) at time zone 'Europe/Vienna' from public.bookings where id=a);
perform public.owner_remove_time_off(block);assert public.get_public_availability('demo-studio','demo-barber-a','classic-cut',d) ? '10:00';
end $$;
rollback;
