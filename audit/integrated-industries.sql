-- Industry onboarding uses the established owner-bound timezone/currency API.
create function public.create_owner_business_industry_v2(p_name text,p_public_slug text,p_staff_name text,p_service_name text,p_duration_minutes integer,p_price_cents integer,p_business_type text,p_timezone text default 'Europe/London',p_currency text default 'GBP') returns jsonb language plpgsql security definer set search_path='' as $$
declare r jsonb;bid uuid;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED';end if;
 if p_business_type is null or p_business_type not in('barber','beauty','nails','wellness','other') then raise exception 'INVALID_BUSINESS_TYPE';end if;
 r:=public.create_owner_business_v2(p_name,p_public_slug,p_staff_name,p_service_name,p_duration_minutes,p_price_cents,p_timezone,p_currency);bid:=(r->>'business_id')::uuid;
 update public.businesses set business_type=p_business_type where id=bid and exists(select 1 from public.business_members m where m.business_id=bid and m.user_id=auth.uid() and m.role='owner');
 if not found then raise exception 'BUSINESS_TYPE_SAVE_FAILED';end if;
 return r||jsonb_build_object('business_type',p_business_type);
end $$;
revoke all on function public.create_owner_business_industry_v2(text,text,text,text,integer,integer,text,text,text) from public,anon;
grant execute on function public.create_owner_business_industry_v2(text,text,text,text,integer,integer,text,text,text) to authenticated;
-- Existing clients use the same public catalog; add only safe public metadata.
do $$ declare d text;begin
 select pg_get_functiondef('public.get_public_booking_catalog(text)'::regprocedure) into d;
 if position('''business_type''' in d)=0 then d:=replace(d,'''name'',b.name,''timezone''','''name'',b.name,''business_type'',b.business_type,''timezone''');end if;
 if position('''is_demo''' in d)=0 then d:=replace(d,'''timezone'',b.timezone','''is_demo'',exists(select 1 from kavelyq_private.demo_businesses dm where dm.business_id=b.id),''timezone'',b.timezone');end if;
 execute d;
end $$;
-- Register synthetic examples for the same persisted booking engine, not a
-- separate simulator. No customers, owner accounts or subscriptions are seeded.
do $$
declare item jsonb;svc jsonb;bid uuid;sid uuid;vid uuid;n int;
begin
 for item in select value from jsonb_array_elements('[
 {"type":"beauty","slug":"demo-beauty","name":"KAVELYQ BEAUTY · DEMO","role":"Artist","services":[["Everyday Makeup",5500,60],["Evening Makeup",7500,90],["Bridal Trial",11000,120],["Facial Treatment",6500,60]]},
 {"type":"nails","slug":"demo-nails","name":"KAVELYQ NAILS · DEMO","role":"Technician","services":[["Classic Manicure",3500,45],["Gel Manicure",5500,75],["Lash Extensions",8500,120],["Lash Refill",5000,60]]},
 {"type":"wellness","slug":"demo-wellness","name":"KAVELYQ WELLNESS · DEMO","role":"Therapist","services":[["Relaxing Massage",6500,60],["Deep Tissue Massage",8500,90],["Back Massage",4000,30],["Wellness Consultation",2500,30]]},
 {"type":"other","slug":"demo-other","name":"KAVELYQ STUDIO · DEMO","role":"Professional","services":[["Consultation",2500,30],["Standard Session",6000,60],["Extended Session",9500,90]]}
 ]'::jsonb) loop
  select id into bid from public.businesses where public_slug=item->>'slug';
  if bid is not null then continue;end if;
  insert into public.businesses(name,public_slug,business_type,timezone,currency,onboarding_complete,deposit_percent,no_show_policy) values(item->>'name',item->>'slug',item->>'type','Europe/London','GBP',true,0,'Synthetic demo only. No appointment or fee.') returning id into bid;
  insert into kavelyq_private.demo_businesses(business_id) values(bid);
  for svc in select value from jsonb_array_elements(item->'services') loop insert into public.services(business_id,name,price_cents,duration_minutes,public_slug) values(bid,svc->>0,(svc->>1)::int,(svc->>2)::int,lower(regexp_replace(svc->>0,'[^a-zA-Z0-9]+','-','g'))) returning id into vid;end loop;
  for n in 1..3 loop
   insert into public.staff(business_id,display_name,public_slug) values(bid,'Demo '||(item->>'role')||' '||chr(64+n),'professional-'||n) returning id into sid;
   insert into public.staff_services(staff_id,service_id) select sid,id from public.services where business_id=bid;
   insert into public.working_hours(staff_id,weekday,start_time,end_time) select sid,d,'09:00','18:00' from generate_series(1,6)d;
  end loop;
 end loop;
end $$;
