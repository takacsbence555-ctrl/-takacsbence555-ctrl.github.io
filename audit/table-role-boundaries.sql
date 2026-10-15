create or replace function kavelyq_private.can_manage_business(p_business_id uuid)
returns boolean language sql stable security definer set search_path='' as $$
select exists(select 1 from public.business_members where business_id=p_business_id and user_id=(select auth.uid()) and role in('owner','manager'))
$$;
revoke all on function kavelyq_private.can_manage_business(uuid) from public,anon;
grant execute on function kavelyq_private.can_manage_business(uuid) to authenticated;
do $$ declare t record;p record;q text;c text;begin
for t in select tablename from pg_tables where schemaname='public' loop
execute format('revoke all on table public.%I from anon',t.tablename);
execute format('revoke truncate,references,trigger on table public.%I from authenticated',t.tablename);
end loop;
for p in select * from pg_policies where schemaname='public' and (qual like '%is_business_member%' or with_check like '%is_business_member%') loop
q:=replace(p.qual,'kavelyq_private.is_business_member','kavelyq_private.can_manage_business');
c:=replace(p.with_check,'kavelyq_private.is_business_member','kavelyq_private.can_manage_business');
execute format('alter policy %I on public.%I to authenticated using (%s)%s',p.policyname,p.tablename,q,case when c is not null then ' with check ('||c||')' else '' end);
end loop;
end $$;
alter default privileges for role postgres in schema public revoke all on tables from anon;
alter default privileges for role postgres in schema public revoke truncate,references,trigger on tables from authenticated;
