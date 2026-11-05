create or replace function kavelyq_private.validate_time_off() returns trigger language plpgsql security definer set search_path='' as $$
begin
perform pg_advisory_xact_lock(hashtextextended('kavelyq-booking-staff:'||new.staff_id::text,0));
if new.starts_at is null or new.ends_at is null or not isfinite(new.starts_at) or not isfinite(new.ends_at) or new.ends_at<=new.starts_at then raise exception 'INVALID_TIME_OFF';end if;
if exists(select 1 from public.bookings b where b.staff_id=new.staff_id and b.status in('pending','confirmed') and tstzrange(b.starts_at,b.ends_at,'[)')&&tstzrange(new.starts_at,new.ends_at,'[)')) then raise exception 'TIME_OFF_CONFLICTS_WITH_BOOKING';end if;
if exists(select 1 from public.time_off t where t.staff_id=new.staff_id and t.id<>new.id and tstzrange(t.starts_at,t.ends_at,'[)')&&tstzrange(new.starts_at,new.ends_at,'[)')) then raise exception 'TIME_OFF_ALREADY_BLOCKED';end if;
return new;
end $$;
revoke all on function kavelyq_private.validate_time_off() from public,anon,authenticated;
create trigger validate_time_off before insert or update on public.time_off for each row execute function kavelyq_private.validate_time_off();
