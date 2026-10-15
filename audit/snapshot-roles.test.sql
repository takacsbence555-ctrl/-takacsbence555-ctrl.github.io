begin;
do $$ declare bid uuid;u uuid:=gen_random_uuid();begin
select id into bid from public.businesses where public_slug='demo-studio';
insert into auth.users(id) values(u);insert into public.business_members(business_id,user_id,role) values(bid,u,'staff');
perform set_config('request.jwt.claims',jsonb_build_object('sub',u,'role','authenticated')::text,true);execute 'set local role authenticated';
assert public.owner_setup_snapshot() is null;assert public.owner_subscription_snapshot() is null;
execute 'reset role';update public.business_members set role='owner' where user_id=u;execute 'set local role authenticated';
assert public.owner_setup_snapshot()->>'business_id'=bid::text;
assert public.owner_subscription_snapshot()->'proposed_plans_gbp'->>'essential'='19';
assert (public.owner_subscription_snapshot()->>'live_billing_enabled')::boolean=false;
end $$;
rollback;
