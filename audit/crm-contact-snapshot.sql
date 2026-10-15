do $$ declare d text;begin
 select pg_get_functiondef('public.owner_customer_crm()'::regprocedure) into d;
 if position('''email'',c.email' in d)=0 then
  d:=replace(d,'''id'',c.id,''display_name'',c.display_name','''id'',c.id,''display_name'',c.display_name,''email'',c.email,''phone'',c.phone,''marketing_consent'',c.marketing_consent');
  d:=replace(d,'left join public.services sv on sv.id=c.preferred_service_id','left join public.services sv on sv.id=c.preferred_service_id where c.deleted_at is null');
  execute d;
 end if;
end $$;
