-- Keep privileged helpers outside the exposed public API, and allow the
-- existing authenticated owner functions / RLS policies to call them.
create schema if not exists kavelyq_private;
revoke all on schema kavelyq_private from public, anon;
grant usage on schema kavelyq_private to authenticated;
alter function public.is_business_member(uuid) set schema kavelyq_private;
alter function public.business_accepts_live_operations(uuid) set schema kavelyq_private;
alter function public.assert_booking_slot(uuid,uuid,uuid,timestamptz,uuid) set schema kavelyq_private;
alter function public.refresh_customer_crm(uuid) set schema kavelyq_private;
do $repair$
declare r record;definition text;helper text;
begin
 for r in select p.oid from pg_proc p join pg_namespace n on n.oid=p.pronamespace
 where n.nspname='public' and p.proname not in ('is_business_member','business_accepts_live_operations','assert_booking_slot','refresh_customer_crm')
 loop
  definition:=pg_get_functiondef(r.oid);
  foreach helper in array array['is_business_member','business_accepts_live_operations','assert_booking_slot','refresh_customer_crm'] loop
   definition:=regexp_replace(definition,'(public[.])?\m'||helper||'\M','kavelyq_private.'||helper,'g');
  end loop;
  if definition<>pg_get_functiondef(r.oid) then execute definition;end if;
 end loop;
end
$repair$;
revoke all on all functions in schema kavelyq_private from public,anon;
grant execute on all functions in schema kavelyq_private to authenticated;
