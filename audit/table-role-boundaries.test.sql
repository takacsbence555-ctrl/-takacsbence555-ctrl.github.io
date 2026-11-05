begin;
do $$ declare u uuid:=gen_random_uuid();b uuid;n int;t record;begin
select id into b from public.businesses where public_slug='demo-studio';insert into auth.users(id) values(u);insert into public.business_members(business_id,user_id,role) values(b,u,'staff');
for t in select tablename from pg_tables where schemaname='public' loop
assert not has_table_privilege('anon','public.'||quote_ident(t.tablename),'TRUNCATE');
assert not has_table_privilege('authenticated','public.'||quote_ident(t.tablename),'TRUNCATE');
assert not has_table_privilege('anon','public.'||quote_ident(t.tablename),'SELECT');
end loop;
perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);execute 'set local role authenticated';
assert (select count(*) from public.customers)=0;
update public.services set price_cents=price_cents+1 where business_id=b;get diagnostics n=row_count;assert n=0;
delete from public.bookings where business_id=b;get diagnostics n=row_count;assert n=0;
execute 'reset role';update public.business_members set role='owner' where user_id=u;execute 'set local role authenticated';
assert (select count(*) from public.services where business_id=b)>0;
update public.services set price_cents=price_cents+1 where business_id=b;get diagnostics n=row_count;assert n>0;
assert (select count(*) from public.services where business_id<>b)=0;
end $$;
rollback;