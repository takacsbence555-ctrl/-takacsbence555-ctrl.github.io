-- Financial history must not change when a service's current price changes.
alter table public.bookings add column booked_price_cents integer;
update public.bookings bk set booked_price_cents=sv.price_cents from public.services sv where sv.id=bk.service_id;
create or replace function kavelyq_private.capture_booking_price()
returns trigger language plpgsql security invoker set search_path='' as $fn$
begin
 if tg_op='INSERT' or new.service_id is distinct from old.service_id then
  select price_cents into new.booked_price_cents from public.services where id=new.service_id;
 else new.booked_price_cents:=old.booked_price_cents;
 end if;
 return new;
end
$fn$;
revoke all on function kavelyq_private.capture_booking_price() from public,anon,authenticated;
create trigger capture_booking_price before insert or update on public.bookings for each row execute function kavelyq_private.capture_booking_price();
alter table public.bookings alter column booked_price_cents set not null;
alter table public.bookings add constraint booking_price_nonnegative check(booked_price_cents>=0);
do $snapshot$
declare r record;definition text;
begin
 for r in select p.oid,p.proname from pg_proc p join pg_namespace n on n.oid=p.pronamespace
 where (n.nspname='public' and p.proname in ('owner_dashboard','owner_business_metrics','owner_operator_snapshot','owner_operator_measure','get_public_booking_manage'))
 or (n.nspname='kavelyq_private' and p.proname='refresh_customer_crm') loop
  definition:=pg_get_functiondef(r.oid);
  if r.proname='owner_dashboard' then
   definition:=replace(definition,'''service'',sv.name,''price_cents'',sv.price_cents','''service'',sv.name,''price_cents'',bk.booked_price_cents');
  else definition:=replace(replace(definition,'sv.price_cents','bk.booked_price_cents'),'sum(s.price_cents)','sum(bk.booked_price_cents)');end if;
  execute definition;
 end loop;
end
$snapshot$;
