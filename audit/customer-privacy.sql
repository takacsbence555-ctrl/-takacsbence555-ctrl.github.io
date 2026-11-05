create or replace function public.owner_delete_customer_data(p_customer_id uuid) returns boolean language plpgsql security definer set search_path='' as $$
declare bid uuid;em text;ph text;
begin
select business_id,email,phone into bid,em,ph from public.customers where id=p_customer_id for update;
if bid is null or not kavelyq_private.can_manage_business(bid) then raise exception 'FORBIDDEN' using errcode='42501';end if;
update public.notification_queue set destination=null,payload='{}'::jsonb,status='cancelled',customer_id=null,last_error=null,provider_message_id=null where business_id=bid and (customer_id=p_customer_id or booking_id in(select id from public.bookings where business_id=bid and customer_id=p_customer_id));
delete from public.cut_memory where business_id=bid and customer_id=p_customer_id;
update public.bookings set customer_id=null,manage_token=gen_random_uuid() where business_id=bid and customer_id=p_customer_id;
update public.operator_outreach set customer_id=null,message='[Removed under customer erasure request]',status='failed',provider_message_id=null where business_id=bid and customer_id=p_customer_id;
update public.business_action_drafts set status='cancelled' where business_id=bid and subject_id=p_customer_id;
update public.waitlist_requests set display_name='Deleted request',email=null,phone=null,contact_permission=false,status='withdrawn',manage_token=gen_random_uuid() where business_id=bid and ((em is not null and lower(email)=lower(em)) or (ph is not null and regexp_replace(phone,'[^0-9]','','g')=regexp_replace(ph,'[^0-9]','','g')));
update public.customers set display_name='Deleted Customer',email=null,phone=null,marketing_consent=false,deleted_at=now(),preferred_staff_id=null,preferred_service_id=null where id=p_customer_id and business_id=bid;
return true;
end $$;
revoke all on function public.owner_delete_customer_data(uuid) from public,anon;
grant execute on function public.owner_delete_customer_data(uuid) to authenticated;
create or replace function public.owner_export_customer(p_customer_id uuid) returns jsonb language plpgsql security invoker set search_path='' as $$
declare bid uuid;r jsonb;
begin
perform kavelyq_private.require_business_owner();
select business_id into bid from public.customers where id=p_customer_id;
if bid is null or not kavelyq_private.can_manage_business(bid) then raise exception 'FORBIDDEN';end if;
select jsonb_build_object(
'customer',to_jsonb(c)-'business_id',
'bookings',coalesce((select jsonb_agg(to_jsonb(b)-'business_id'-'manage_token') from public.bookings b where b.business_id=bid and b.customer_id=c.id),'[]'::jsonb),
'cut_memory',coalesce((select jsonb_agg(to_jsonb(m)-'business_id') from public.cut_memory m where m.business_id=bid and m.customer_id=c.id),'[]'::jsonb),
'notifications',coalesce((select jsonb_agg(jsonb_build_object('template',q.template,'destination',q.destination,'status',q.status,'scheduled_for',q.scheduled_for,'sent_at',q.sent_at)) from public.notification_queue q where q.business_id=bid and q.customer_id=c.id),'[]'::jsonb),
'outreach',coalesce((select jsonb_agg(jsonb_build_object('channel',o.channel,'status',o.status,'message',o.message,'sent_at',o.sent_at)) from public.operator_outreach o where o.business_id=bid and o.customer_id=c.id),'[]'::jsonb),
'waitlist',coalesce((select jsonb_agg(to_jsonb(w)-'business_id'-'manage_token') from public.waitlist_requests w where w.business_id=bid and ((c.email is not null and lower(w.email)=lower(c.email)) or (c.phone is not null and regexp_replace(w.phone,'[^0-9]','','g')=regexp_replace(c.phone,'[^0-9]','','g')))),'[]'::jsonb)
) into r from public.customers c where c.id=p_customer_id and c.business_id=bid;
return r;
end $$;
