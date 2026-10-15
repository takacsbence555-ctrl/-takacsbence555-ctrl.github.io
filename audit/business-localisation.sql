create function public.create_owner_business_v2(p_name text,p_public_slug text,p_staff_name text,p_service_name text,p_duration_minutes integer,p_price_cents integer,p_timezone text default 'Europe/London',p_currency text default 'GBP') returns jsonb language plpgsql security invoker set search_path='' as $$
declare r jsonb;bid uuid;
begin
 if p_timezone is null or not exists(select 1 from pg_catalog.pg_timezone_names where name=p_timezone) or p_currency is null or p_currency not in('GBP','EUR','USD','CAD','AUD','NZD','CHF') then raise exception 'INVALID_LOCALISATION';end if;
 r:=public.create_owner_business(p_name,p_public_slug,p_staff_name,p_service_name,p_duration_minutes,p_price_cents);bid:=(r->>'business_id')::uuid;
 update public.businesses set timezone=p_timezone,currency=p_currency where id=bid;
 if not found then raise exception 'BUSINESS_SETUP_FAILED';end if;
 return r||jsonb_build_object('timezone',p_timezone,'currency',p_currency);
end $$;
revoke all on function public.create_owner_business_v2(text,text,text,text,integer,integer,text,text) from public,anon;
grant execute on function public.create_owner_business_v2(text,text,text,text,integer,integer,text,text) to authenticated;
