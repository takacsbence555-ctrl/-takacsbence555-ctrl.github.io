create temporary table integration_results(result jsonb) on commit drop;
do $$
declare bid uuid;u uuid:=gen_random_uuid();staffuser uuid:=gen_random_uuid();r jsonb;w jsonb;a jsonb;c uuid;denied boolean;checks text[]:=array[]::text[];kind text;
begin
 begin
 select id into bid from public.businesses where public_slug='demo-studio';
 insert into auth.users(id) values(u),(staffuser);insert into public.business_members(business_id,user_id,role) values(bid,u,'owner'),(bid,staffuser,'staff');
 foreach kind in array array['demo-studio','demo-beauty','demo-nails','demo-wellness','demo-other'] loop
  r:=public.get_public_booking_catalog(kind);assert jsonb_array_length(r->'services')>=3 and jsonb_array_length(r->'staff')=3 and (r->'business'->>'is_demo')::boolean;
 end loop;checks:=array_append(checks,'five persisted industry catalogs with labelled demo metadata');
 denied:=false;begin perform public.join_public_waitlist('demo-studio','classic-cut',null,'QA Waitlist',null,'+430000000909',current_date+1,current_date+2,false);exception when others then denied:=true;end;assert denied;
 w:=public.join_public_waitlist('demo-studio','classic-cut',null,'QA Waitlist',null,'+430000000909',current_date+1,current_date+2,true);assert (w->>'id')::uuid is not null;checks:=array_append(checks,'waitlist requires consent and persists a token');
 perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);execute 'set local role authenticated';
 r:=public.owner_intelligence_snapshot();assert jsonb_array_length(r->'waitlist')=1 and (r->>'delivery_enabled')::boolean=false;
 a:=public.owner_prepare_business_action('waitlist',(w->>'id')::uuid);r:=public.owner_approve_business_action((a->>'id')::uuid);assert r->>'status'='approved' and (r->>'delivery_enabled')::boolean=false;checks:=array_append(checks,'owner forecast, preparation and approval persist without delivery');
 execute 'reset role';insert into public.customers(business_id,display_name,phone,marketing_consent) values(bid,'QA Consent','+430000000908',false) returning id into c;
 execute 'set local role authenticated';denied:=false;begin perform public.owner_prepare_business_action('reactivation',c);exception when others then denied:=true;end;assert denied;
 execute 'reset role';update public.customers set marketing_consent=true where id=c;execute 'set local role authenticated';a:=public.owner_prepare_business_action('reactivation',c);
 execute 'reset role';update public.customers set marketing_consent=false where id=c;execute 'set local role authenticated';denied:=false;begin perform public.owner_approve_business_action((a->>'id')::uuid);exception when others then denied:=true;end;assert denied;checks:=array_append(checks,'revoked consent denies approval');
 assert public.withdraw_public_waitlist((w->>'manage_token')::uuid);assert not public.withdraw_public_waitlist((w->>'manage_token')::uuid);checks:=array_append(checks,'private withdrawal removes permission idempotently');
 perform set_config('request.jwt.claims',jsonb_build_object('sub',staffuser,'role','authenticated')::text,true);
 denied:=false;begin perform public.owner_intelligence_snapshot();exception when insufficient_privilege then denied:=true;end;assert denied;
 denied:=false;begin perform public.owner_export_customer(c);exception when insufficient_privilege then denied:=true;end;assert denied;
 denied:=false;begin perform public.owner_save_branding('{}');exception when insufficient_privilege then denied:=true;end;assert denied;checks:=array_append(checks,'same-tenant staff denied owner intelligence, export and mutation');
 execute 'reset role';raise exception 'QA_ROLLBACK';
 exception when others then if sqlerrm<>'QA_ROLLBACK' then raise;end if;end;
 insert into integration_results values(jsonb_build_object('passed',checks,'rolled_back',true));
end $$;
select * from integration_results;
