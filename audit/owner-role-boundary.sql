create function kavelyq_private.require_business_owner() returns uuid language plpgsql stable security definer set search_path='' as $$
declare bid uuid;begin
 select business_id into bid from public.business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null then raise exception 'OWNER_ROLE_REQUIRED' using errcode='42501';end if;return bid;
end $$;
revoke all on function kavelyq_private.require_business_owner() from public,anon;
grant execute on function kavelyq_private.require_business_owner() to authenticated;
do $$ declare f record;d text;begin
 for f in select p.oid from pg_proc p join pg_namespace n on n.oid=p.pronamespace join pg_language l on l.oid=p.prolang where n.nspname='public' and p.proname like 'owner_%' and l.lanname='plpgsql' loop
  d:=pg_get_functiondef(f.oid);
  if position('require_business_owner' in d)=0 then d:=regexp_replace(d,'\mbegin\M','begin perform kavelyq_private.require_business_owner();','i');execute d;end if;
 end loop;
 select pg_get_functiondef('public.owner_dashboard()'::regprocedure) into d;
 d:=replace(d,'where bm.user_id=(select auth.uid()) limit 1','where bm.user_id=(select auth.uid()) and bm.role in(''owner'',''manager'') limit 1');execute d;
end $$;
