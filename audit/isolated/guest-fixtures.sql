-- Synthetic fixtures for disposable Docker database ONLY. No Auth identities or customer data.
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
 {"type":"barber","slug":"demo-studio","name":"Demo Studio","role":"Barber","services":[["Classic Cut",2500,30],["Skin Fade",3000,45],["Cut + Beard",4000,60],["Beard Ritual",1500,30]]},
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
