-- Pending release migration. Apply only after authorised coordinated release.
create function public.owner_set_staff_week_hours(p_staff_id uuid,p_days jsonb) returns boolean language plpgsql set search_path='' as $$
declare d jsonb;begin
perform kavelyq_private.require_business_owner();
if jsonb_typeof(p_days) is distinct from 'array' or jsonb_array_length(p_days)<>7 then raise exception 'INVALID_WEEK';end if;
if (select count(distinct (value->>'weekday')::integer) from jsonb_array_elements(p_days))<>7 then raise exception 'INVALID_WEEK';end if;
for d in select value from jsonb_array_elements(p_days) loop
if (d->>'weekday')::integer not between 0 and 6 or jsonb_typeof(d->'enabled') is distinct from 'boolean' then raise exception 'INVALID_WEEK';end if;
if (d->>'enabled')::boolean and ((d->>'start') is null or (d->>'end') is null or (d->>'start')::time>=(d->>'end')::time) then raise exception 'INVALID_HOURS';end if;
end loop;
for d in select value from jsonb_array_elements(p_days) loop
perform public.owner_set_working_hours(p_staff_id,(d->>'weekday')::integer,(d->>'start')::time,(d->>'end')::time,(d->>'enabled')::boolean);
end loop;return true;
end $$;
revoke all on function public.owner_set_staff_week_hours(uuid,jsonb) from public,anon;
grant execute on function public.owner_set_staff_week_hours(uuid,jsonb) to authenticated;
