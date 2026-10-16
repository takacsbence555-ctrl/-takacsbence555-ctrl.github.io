-- Pending release migration. Tested only in disposable CI; NOT applied to production.
begin;
do $$ declare signature text;definition text;begin
foreach signature in array array['public.complete_email_notification(uuid,text)','public.fail_email_notification(uuid,text)'] loop
select pg_get_functiondef(signature::regprocedure) into definition;
definition:=replace(definition,$q$coalesce(current_setting('request.jwt.claim.role',true),'') <> 'service_role'$q$,$q$coalesce(current_setting('request.jwt.claim.role',true),'') <> 'service_role' and coalesce(auth.jwt()->>'role','') <> 'service_role'$q$);
execute definition;
end loop;
end $$;
create table kavelyq_private.notification_delivery_events(event_id text primary key,notification_id uuid not null references public.notification_queue(id),event_type text not null,received_at timestamptz not null default now());
create table kavelyq_private.notification_delivery_state(notification_id uuid primary key references public.notification_queue(id),outcome text not null,updated_at timestamptz not null default now());
create table kavelyq_private.notification_suppressions(business_id uuid not null references public.businesses(id),destination text not null,reason text not null,primary key(business_id,destination));
alter table kavelyq_private.notification_delivery_events enable row level security;
alter table kavelyq_private.notification_delivery_state enable row level security;
alter table kavelyq_private.notification_suppressions enable row level security;
revoke all on kavelyq_private.notification_delivery_events,kavelyq_private.notification_delivery_state,kavelyq_private.notification_suppressions from public,anon,authenticated;
create function public.notification_claim_current(p_id uuid,p_attempt integer) returns boolean language plpgsql security definer set search_path='' as $$
declare q public.notification_queue;begin
if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'SERVICE_ROLE_REQUIRED';end if;
select * into q from public.notification_queue where id=p_id and status='processing' and attempt_count=p_attempt and claimed_at>now()-interval '15 minutes' for update;
if q.id is null then return false;end if;
if exists(select 1 from kavelyq_private.notification_suppressions s where s.business_id=q.business_id and s.destination=lower(q.destination)) then update public.notification_queue set status='cancelled' where id=q.id;return false;end if;
return q.template in('booking_confirmation','booking_reminder','booking_cancelled')
and exists(select 1 from kavelyq_private.communication_delivery c where c.business_id=q.business_id and c.transactional_enabled and c.provider_verified)
and not exists(select 1 from kavelyq_private.demo_businesses d where d.business_id=q.business_id)
and (q.customer_id is null or exists(select 1 from public.customers c where c.id=q.customer_id and c.deleted_at is null and c.email=q.destination))
and (q.booking_id is null or exists(select 1 from public.bookings b where b.id=q.booking_id and ((q.template='booking_cancelled' and b.status='cancelled') or (q.template in('booking_confirmation','booking_reminder') and b.status='confirmed' and b.starts_at>now()))));
end $$;
create function public.notification_finish_claim(p_id uuid,p_attempt integer,p_provider_id text) returns boolean language plpgsql security definer set search_path='' as $$
begin if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'SERVICE_ROLE_REQUIRED';end if;
if nullif(p_provider_id,'') is null or length(p_provider_id)>200 then raise exception 'INVALID_PROVIDER_ID';end if;
update public.notification_queue set status='sent',provider_message_id=p_provider_id,sent_at=now(),last_error=null where id=p_id and status='processing' and attempt_count=p_attempt;return found;
end $$;
create function public.notification_fail_claim(p_id uuid,p_attempt integer,p_code text,p_retryable boolean) returns boolean language plpgsql security definer set search_path='' as $$
begin if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'SERVICE_ROLE_REQUIRED';end if;
if p_code !~ '^[A-Z_]{1,80}$' then raise exception 'INVALID_ERROR_CODE';end if;
update public.notification_queue set status='failed',last_error=p_code,attempt_count=case when p_retryable then attempt_count else 5 end where id=p_id and status='processing' and attempt_count=p_attempt;return found;
end $$;
create function public.notification_record_event(p_event_id text,p_provider_id text,p_type text) returns text language plpgsql security definer set search_path='' as $$
declare q public.notification_queue;begin
if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'SERVICE_ROLE_REQUIRED';end if;
if p_event_id is null or length(p_event_id)>200 or p_type not in('email.delivered','email.bounced','email.complained','email.suppressed','email.failed','email.delivery_delayed') then raise exception 'INVALID_EVENT';end if;
select * into q from public.notification_queue where provider_message_id=p_provider_id limit 1 for update;if q.id is null then raise exception 'UNKNOWN_PROVIDER_MESSAGE';end if;
insert into kavelyq_private.notification_delivery_events(event_id,notification_id,event_type) values(p_event_id,q.id,p_type) on conflict do nothing;if not found then return 'duplicate';end if;
insert into kavelyq_private.notification_delivery_state(notification_id,outcome) values(q.id,p_type) on conflict(notification_id) do update set outcome=excluded.outcome,updated_at=now() where notification_delivery_state.outcome not in('email.bounced','email.complained','email.suppressed','email.failed');
if p_type in('email.bounced','email.complained','email.suppressed') then
insert into kavelyq_private.notification_suppressions values(q.business_id,lower(q.destination),p_type) on conflict do nothing;
update public.notification_queue set status='cancelled' where business_id=q.business_id and lower(destination)=lower(q.destination) and status in('pending','failed','processing');end if;
return 'recorded';end $$;
revoke all on function public.notification_claim_current(uuid,integer),public.notification_finish_claim(uuid,integer,text),public.notification_fail_claim(uuid,integer,text,boolean),public.notification_record_event(text,text,text) from public,anon,authenticated;
grant execute on function public.notification_claim_current(uuid,integer),public.notification_finish_claim(uuid,integer,text),public.notification_fail_claim(uuid,integer,text,boolean),public.notification_record_event(text,text,text) to service_role;
commit;
