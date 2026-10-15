create or replace function public.owner_add_time_off_local(p_staff_id uuid,p_starts_local timestamp without time zone,p_ends_local timestamp without time zone,p_reason text) returns uuid language plpgsql security invoker set search_path='' as $$
declare bid uuid:=kavelyq_private.require_business_owner();tz text;s timestamptz;e timestamptz;
begin
select b.timezone into tz from public.businesses b join public.staff st on st.business_id=b.id where b.id=bid and st.id=p_staff_id;
if tz is null then raise exception 'FORBIDDEN';end if;
if p_starts_local is null or p_ends_local is null then raise exception 'INVALID_TIME_OFF';end if;
s:=p_starts_local at time zone tz;e:=p_ends_local at time zone tz;
if s at time zone tz<>p_starts_local or e at time zone tz<>p_ends_local then raise exception 'INVALID_LOCAL_TIME';end if;
return public.owner_add_time_off(p_staff_id,s,e,p_reason);
end $$;
revoke all on function public.owner_add_time_off_local(uuid,timestamp,timestamp,text) from public,anon;grant execute on function public.owner_add_time_off_local(uuid,timestamp,timestamp,text) to authenticated;
