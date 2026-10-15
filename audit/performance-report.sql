create function public.owner_performance_report(p_start date,p_end date) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare bid uuid;tz text;result jsonb;
begin
 select b.id,b.timezone into bid,tz from public.businesses b join public.business_members m on m.business_id=b.id where m.user_id=auth.uid() limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if p_start is null or p_end is null or p_end<=p_start or p_end-p_start>366 then raise exception 'INVALID_DATE_RANGE';end if;
 with records as(select b.*,s.display_name staff_name,v.name service_name from public.bookings b join public.staff s on s.id=b.staff_id join public.services v on v.id=b.service_id where b.business_id=bid and b.starts_at>=(p_start::timestamp at time zone tz) and b.starts_at<(p_end::timestamp at time zone tz)),
 staff_rows as(select staff_name name,count(*) total,count(*) filter(where status='completed') completed,coalesce(sum(booked_price_cents) filter(where status='completed'),0) completed_value_cents,count(*) filter(where status='cancelled') cancelled,count(*) filter(where status='no_show') no_shows from records group by staff_name),
 service_rows as(select service_name name,count(*) total,count(*) filter(where status='completed') completed,coalesce(sum(booked_price_cents) filter(where status='completed'),0) completed_value_cents from records group by service_name),
 repeat_rows as(select customer_id,count(*) n from records where status='completed' and customer_id is not null group by customer_id)
 select jsonb_build_object('staff',coalesce((select jsonb_agg(to_jsonb(s)) from staff_rows s),'[]'::jsonb),'services',coalesce((select jsonb_agg(to_jsonb(s)) from service_rows s),'[]'::jsonb),'visiting_customers',(select count(*) from repeat_rows),'repeat_customers',(select count(*) from repeat_rows where n>1),'period_start',p_start,'period_end',p_end,'value_basis','completed service value, not collected payments') into result;
 return result;
end $$;
revoke all on function public.owner_performance_report(date,date) from public,anon;
grant execute on function public.owner_performance_report(date,date) to authenticated;
