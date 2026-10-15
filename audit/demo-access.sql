-- Restore permanent access for the explicitly registered synthetic demo only.
-- No subscription is activated and no payment provider is touched.
create table kavelyq_private.demo_businesses (
 business_id uuid primary key references public.businesses(id) on delete cascade,
 registered_at timestamptz not null default now()
);
alter table kavelyq_private.demo_businesses enable row level security;
revoke all on kavelyq_private.demo_businesses from public, anon, authenticated;
insert into kavelyq_private.demo_businesses(business_id)
 select id from public.businesses where public_slug='demo-studio' and name='Demo Studio';
create or replace function kavelyq_private.business_accepts_live_operations(p_business_id uuid)
returns boolean language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.businesses b where b.id=p_business_id and (
 exists(select 1 from kavelyq_private.demo_businesses d where d.business_id=b.id)
 or b.subscription_status='active'
 or (b.subscription_status='trialing' and b.trial_ends_at>now())
 ));
$$;
revoke all on function kavelyq_private.business_accepts_live_operations(uuid) from public,anon;
-- Keep existing authenticated execution grant needed by owner RPCs/RLS.
grant execute on function kavelyq_private.business_accepts_live_operations(uuid) to authenticated;
