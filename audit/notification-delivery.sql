-- Fail closed: no queued email is claimable until an explicitly provisioned business provider is enabled.
create table kavelyq_private.communication_delivery(
 business_id uuid primary key references public.businesses(id),transactional_enabled boolean not null default false,provider_verified boolean not null default false
);
alter table kavelyq_private.communication_delivery enable row level security;
revoke all on kavelyq_private.communication_delivery from public,anon,authenticated;
alter table public.notification_queue drop constraint notification_queue_status_check;
alter table public.notification_queue add constraint notification_queue_status_check check(status in('pending','processing','sent','failed','cancelled'));
create or replace function public.claim_due_email_notifications(p_limit integer default 20) returns setof public.notification_queue language plpgsql security definer set search_path='' as $$
begin
if coalesce(current_setting('request.jwt.claim.role',true),'')<>'service_role' and coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'SERVICE_ROLE_REQUIRED';end if;
return query with due as(
select q.id from public.notification_queue q
join kavelyq_private.communication_delivery cfg on cfg.business_id=q.business_id and cfg.transactional_enabled and cfg.provider_verified
where q.channel='email' and q.destination is not null and q.scheduled_for<=now() and q.scheduled_for>now()-interval '24 hours' and q.attempt_count<5
and not exists(select 1 from kavelyq_private.demo_businesses d where d.business_id=q.business_id)
and (q.status='pending' or (q.status='failed' and coalesce(q.claimed_at,'epoch'::timestamptz)<now()-interval '10 minutes') or (q.status='processing' and q.claimed_at<now()-interval '15 minutes'))
and (q.customer_id is null or exists(select 1 from public.customers c where c.id=q.customer_id and c.deleted_at is null and c.email=q.destination))
and (q.booking_id is null or exists(select 1 from public.bookings b where b.id=q.booking_id and ((q.template='booking_cancelled' and b.status='cancelled') or (q.template in('booking_confirmation','booking_reminder') and b.status='confirmed' and b.starts_at>now()))))
order by q.scheduled_for for update of q skip locked limit greatest(1,least(coalesce(p_limit,20),100))
),upd as(update public.notification_queue q set status='processing',claimed_at=now(),attempt_count=attempt_count+1 from due where q.id=due.id returning q.*)select * from upd;
end $$;
revoke all on function public.claim_due_email_notifications(integer) from public,anon,authenticated;
grant execute on function public.claim_due_email_notifications(integer) to service_role;
-- Keep queued reminders consistent when an appointment changes.
create or replace function public.refresh_rescheduled_notifications() returns trigger language plpgsql security definer set search_path='' as $$
declare em text;payload jsonb;
begin
if new.starts_at is not distinct from old.starts_at or new.status<>'confirmed' then return new;end if;
update public.notification_queue set status='cancelled' where booking_id=new.id and status in('pending','failed','processing');
select c.email into em from public.customers c where c.id=new.customer_id and c.deleted_at is null;
if em is null then return new;end if;
payload:=jsonb_build_object('business_name',(select name from public.businesses where id=new.business_id),'service_name',(select name from public.services where id=new.service_id),'staff_name',(select display_name from public.staff where id=new.staff_id),'starts_at',new.starts_at,'timezone',(select timezone from public.businesses where id=new.business_id),'manage_token',new.manage_token);
insert into public.notification_queue(business_id,booking_id,customer_id,channel,template,destination,scheduled_for,payload) values(new.business_id,new.id,new.customer_id,'email','booking_confirmation',em,now(),payload);
if new.starts_at>now()+interval '25 hours' then insert into public.notification_queue(business_id,booking_id,customer_id,channel,template,destination,scheduled_for,payload) values(new.business_id,new.id,new.customer_id,'email','booking_reminder',em,new.starts_at-interval '24 hours',payload);end if;
return new;
end $$;
revoke all on function public.refresh_rescheduled_notifications() from public,anon,authenticated;
create trigger refresh_rescheduled_notifications after update of starts_at on public.bookings for each row execute function public.refresh_rescheduled_notifications();
