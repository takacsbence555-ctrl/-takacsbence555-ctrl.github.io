-- Schema-only production snapshot captured 2026-10-16. No rows, keys or customer data.
-- Test fixture only; never apply this bootstrap to a hosted/production database.
set check_function_bodies=false;
create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;
create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists btree_gist with schema extensions;
create schema if not exists kavelyq_private;
set search_path=public,extensions;
create sequence public.public_booking_rate_limits_id_seq;
create table "kavelyq_private"."communication_delivery" (
"business_id" uuid not null,
"transactional_enabled" boolean default false not null,
"provider_verified" boolean default false not null
);
create table "public"."business_members" (
"business_id" uuid not null,
"user_id" uuid not null,
"role" text not null
);
create table "public"."staff_services" (
"staff_id" uuid not null,
"service_id" uuid not null
);
create table "public"."working_hours" (
"id" uuid default gen_random_uuid() not null,
"staff_id" uuid not null,
"weekday" integer not null,
"start_time" time without time zone not null,
"end_time" time without time zone not null
);
create table "public"."recovery_offers" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"outreach_id" uuid not null,
"token_hash" text not null,
"expires_at" timestamp with time zone default (now() + '7 days'::interval) not null,
"redeemed_at" timestamp with time zone,
"created_at" timestamp with time zone default now() not null
);
create table "public"."bookings" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"customer_id" uuid,
"staff_id" uuid not null,
"service_id" uuid not null,
"starts_at" timestamp with time zone not null,
"ends_at" timestamp with time zone not null,
"status" text default 'confirmed'::text not null,
"source" text default 'guest'::text not null,
"created_at" timestamp with time zone default now() not null,
"operator_decision_id" uuid,
"operator_outreach_id" uuid,
"cancelled_at" timestamp with time zone,
"completed_at" timestamp with time zone,
"notes" text,
"manage_token" uuid default gen_random_uuid() not null,
"booked_price_cents" integer not null
);
create table "public"."businesses" (
"id" uuid default gen_random_uuid() not null,
"name" text not null,
"timezone" text default 'Europe/Vienna'::text not null,
"currency" text default 'EUR'::text not null,
"created_at" timestamp with time zone default now() not null,
"public_slug" text,
"onboarding_complete" boolean default false not null,
"plan_code" text default 'kavelyq_pro'::text not null,
"trial_started_at" timestamp with time zone default now() not null,
"trial_ends_at" timestamp with time zone default (now() + '14 days'::interval) not null,
"subscription_status" text default 'trialing'::text not null,
"subscription_provider" text,
"subscription_customer_id" text,
"subscription_id" text,
"billing_interval" text default 'monthly'::text not null,
"contact_email" text,
"contact_phone" text,
"address_text" text,
"cancellation_window_hours" integer default 24 not null,
"deposit_percent" integer default 20 not null,
"no_show_policy" text default 'Deposit may be retained for late cancellations or no-shows.'::text not null,
"privacy_url" text,
"terms_url" text,
"business_type" text default 'barber'::text not null
);
create table "public"."operator_outreach" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"decision_id" uuid not null,
"customer_id" uuid,
"channel" text not null,
"status" text default 'prepared'::text not null,
"message" text not null,
"provider_message_id" text,
"sent_at" timestamp with time zone,
"created_at" timestamp with time zone default now() not null
);
create table "public"."cut_memory" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"customer_id" uuid not null,
"staff_id" uuid,
"notes" text not null,
"updated_at" timestamp with time zone default now() not null,
"service_id" uuid
);
create table "public"."notification_queue" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"booking_id" uuid,
"customer_id" uuid,
"channel" text not null,
"template" text not null,
"destination" text,
"scheduled_for" timestamp with time zone default now() not null,
"status" text default 'pending'::text not null,
"provider_message_id" text,
"last_error" text,
"created_at" timestamp with time zone default now() not null,
"sent_at" timestamp with time zone,
"attempt_count" integer default 0 not null,
"claimed_at" timestamp with time zone,
"payload" jsonb default '{}'::jsonb not null
);
create table "kavelyq_private"."demo_businesses" (
"business_id" uuid not null,
"registered_at" timestamp with time zone default now() not null
);
create table "public"."public_booking_rate_limits" (
"id" bigint default nextval('public_booking_rate_limits_id_seq'::regclass) not null,
"business_id" uuid not null,
"contact_hash" text not null,
"created_at" timestamp with time zone default now() not null
);
create table "public"."business_branding" (
"business_id" uuid not null,
"config" jsonb default '{}'::jsonb not null,
"updated_at" timestamp with time zone default now() not null
);
create table "public"."customers" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"display_name" text default 'Guest'::text not null,
"email" text,
"phone" text,
"consent_marketing" boolean default false not null,
"created_at" timestamp with time zone default now() not null,
"preferred_staff_id" uuid,
"preferred_service_id" uuid,
"rebook_interval_days" integer,
"last_visit_at" timestamp with time zone,
"next_due_at" timestamp with time zone,
"visit_count" integer default 0 not null,
"lifetime_value_cents" integer default 0 not null,
"crm_status" text default 'active'::text not null,
"marketing_consent" boolean default false not null,
"consent_updated_at" timestamp with time zone,
"deleted_at" timestamp with time zone
);
create table "public"."business_audit_log" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"actor_id" uuid,
"entity" text not null,
"record_id" text not null,
"operation" text not null,
"occurred_at" timestamp with time zone default now() not null
);
create table "public"."waitlist_requests" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"service_id" uuid not null,
"staff_id" uuid,
"display_name" text not null,
"email" text,
"phone" text,
"date_from" date not null,
"date_to" date not null,
"contact_permission" boolean default false not null,
"status" text default 'waiting'::text not null,
"manage_token" uuid default gen_random_uuid() not null,
"created_at" timestamp with time zone default now() not null
);
create table "public"."business_action_drafts" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"kind" text not null,
"subject_id" uuid not null,
"status" text default 'prepared'::text not null,
"created_by" uuid not null,
"approved_by" uuid,
"created_at" timestamp with time zone default now() not null,
"approved_at" timestamp with time zone
);
create table "public"."time_off" (
"id" uuid default gen_random_uuid() not null,
"staff_id" uuid not null,
"starts_at" timestamp with time zone not null,
"ends_at" timestamp with time zone not null,
"reason" text
);
create table "public"."staff" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"display_name" text not null,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"public_slug" text
);
create table "public"."services" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"name" text not null,
"duration_minutes" integer not null,
"price_cents" integer not null,
"active" boolean default true not null,
"created_at" timestamp with time zone default now() not null,
"public_slug" text
);
create table "public"."operator_decisions" (
"id" uuid default gen_random_uuid() not null,
"business_id" uuid not null,
"kind" text not null,
"reason" text not null,
"status" text default 'prepared'::text not null,
"expected_impact_cents" integer default 0 not null,
"actual_impact_cents" integer,
"metadata" jsonb default '{}'::jsonb not null,
"created_at" timestamp with time zone default now() not null,
"action_type" text,
"executed_at" timestamp with time zone,
"measured_at" timestamp with time zone,
"result" jsonb default '{}'::jsonb not null
);
CREATE OR REPLACE FUNCTION auth.email()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$function$
;
CREATE OR REPLACE FUNCTION auth.jwt()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$function$
;
CREATE OR REPLACE FUNCTION auth.role()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$function$
;
CREATE OR REPLACE FUNCTION auth.uid()
 RETURNS uuid
 LANGUAGE sql
 STABLE
AS $function$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.is_business_member(bid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ select exists(select 1 from public.business_members bm where bm.business_id=bid and bm.user_id=auth.uid()) $function$
;
CREATE OR REPLACE FUNCTION public.owner_operator_prepare()
 RETURNS uuid
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare bid uuid; did uuid; n int; expected int;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from public.business_members where user_id=(select auth.uid()) limit 1;
 if bid is null then raise exception 'FORBIDDEN'; end if;
 select count(*) into n from public.bookings where business_id=bid and status='cancelled' and starts_at>now();
 expected:=least(greatest(n,1),5)*4200;
 insert into public.operator_decisions(business_id,kind,action_type,reason,status,expected_impact_cents,metadata)
 values(bid,'revenue_recovery','recover_cancelled_demand',
 'Detected future cancelled capacity. Prepare a recovery action for eligible existing demand.',
 'prepared',expected,jsonb_build_object('cancelled_slots_detected',n,'simulation',false))
 returning id into did;
 return did;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_cancel_booking(p_booking_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare bid uuid; begin perform kavelyq_private.require_business_owner(); select business_id into bid from bookings where id=p_booking_id;
 if bid is null or not kavelyq_private.is_business_member(bid) then raise exception 'FORBIDDEN'; end if;
 if not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE'; end if;
 update bookings set status='cancelled',cancelled_at=now() where id=p_booking_id and status in('pending','confirmed'); return found; end $function$
;
CREATE OR REPLACE FUNCTION public.owner_operator_execute(p_decision_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare d public.operator_decisions; bid uuid; affected int;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from public.business_members where user_id=(select auth.uid()) limit 1;
 select * into d from public.operator_decisions where id=p_decision_id and business_id=bid for update;
 if d.id is null then raise exception 'DECISION_NOT_FOUND'; end if;
 if d.status<>'prepared' then raise exception 'DECISION_NOT_PREPARED'; end if;
 select count(*) into affected from public.bookings where business_id=bid and status='cancelled' and starts_at>now();
 update public.operator_decisions set status='executed',executed_at=now(),
 result=jsonb_build_object('eligible_cancelled_slots',affected,'execution','recorded','external_messages_sent',false)
 where id=d.id;
 return jsonb_build_object('decision_id',d.id,'status','executed','eligible_cancelled_slots',affected,'external_messages_sent',false);
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_operator_measure(p_decision_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare d public.operator_decisions; bid uuid; actual int:=0; conversions int:=0;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from public.business_members where user_id=(select auth.uid()) limit 1;
 select * into d from public.operator_decisions where id=p_decision_id and business_id=bid for update;
 if d.id is null then raise exception 'DECISION_NOT_FOUND'; end if;
 select coalesce(sum(bk.booked_price_cents),0),count(*) into actual,conversions
 from public.bookings bk join public.services sv on sv.id=bk.service_id
 where bk.business_id=bid and bk.operator_decision_id=d.id and bk.status in ('confirmed','completed');
 update public.operator_decisions set status='measured',measured_at=now(),actual_impact_cents=actual,
 result=result||jsonb_build_object('measurement','complete','attributed_revenue_cents',actual,'attributed_bookings',conversions)
 where id=d.id;
 return jsonb_build_object('decision_id',d.id,'status','measured','attributed_revenue_cents',actual,'attributed_bookings',conversions);
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_set_marketing_consent(p_customer_id uuid, p_consent boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$declare bid uuid;begin perform kavelyq_private.require_business_owner(); select business_id into bid from customers where id=p_customer_id;if bid is null or not kavelyq_private.is_business_member(bid) then raise exception 'FORBIDDEN';end if;if not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE';end if;update customers set marketing_consent=p_consent,consent_updated_at=now() where id=p_customer_id;return found;end$function$
;
CREATE OR REPLACE FUNCTION public.owner_customer_crm()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
with mb as (select business_id id from public.business_members where user_id=(select auth.uid()) limit 1)
select coalesce(jsonb_agg(jsonb_build_object(
 'id',c.id,'display_name',c.display_name,'email',c.email,'phone',c.phone,'marketing_consent',c.marketing_consent,'status',c.crm_status,'visit_count',c.visit_count,
 'lifetime_value_cents',c.lifetime_value_cents,'last_visit_at',c.last_visit_at,'next_due_at',c.next_due_at,
 'rebook_interval_days',c.rebook_interval_days,'preferred_staff',st.display_name,'preferred_service',sv.name,
 'cut_memory',(select cm.notes from public.cut_memory cm where cm.customer_id=c.id order by cm.updated_at desc limit 1)
) order by c.next_due_at nulls last),'[]'::jsonb)
from public.customers c join mb on mb.id=c.business_id
left join public.staff st on st.id=c.preferred_staff_id
left join public.services sv on sv.id=c.preferred_service_id where c.deleted_at is null $function$
;
CREATE OR REPLACE FUNCTION public.owner_rebooking_opportunities()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
with mb as (select business_id id from public.business_members where user_id=(select auth.uid()) limit 1)
select coalesce(jsonb_agg(jsonb_build_object(
 'customer_id',c.id,'display_name',c.display_name,'status',c.crm_status,'next_due_at',c.next_due_at,
 'visit_count',c.visit_count,'lifetime_value_cents',c.lifetime_value_cents,
 'staff',st.display_name,'service',sv.name,'service_price_cents',sv.price_cents,
 'reason',case when c.crm_status='overdue' then 'Customer is past the expected rebooking window'
               when c.crm_status='inactive' then 'Customer has been absent for more than two booking cycles'
               else 'Customer is approaching the expected rebooking window' end
) order by c.next_due_at nulls last),'[]'::jsonb)
from public.customers c join mb on mb.id=c.business_id
left join public.staff st on st.id=c.preferred_staff_id
left join public.services sv on sv.id=c.preferred_service_id
where c.crm_status in ('due','overdue','inactive') $function$
;
CREATE OR REPLACE FUNCTION public.owner_onboarding_snapshot()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
with mb as(select b.* from business_members bm join businesses b on b.id=bm.business_id where bm.user_id=(select auth.uid()) limit 1)
select jsonb_build_object(
 'business',(select jsonb_build_object('id',id,'name',name,'timezone',timezone,'currency',currency,'onboarding_complete',onboarding_complete) from mb),
 'staff_count',(select count(*) from staff s join mb on mb.id=s.business_id where s.active),
 'service_count',(select count(*) from services s join mb on mb.id=s.business_id where s.active),
 'working_hours_count',(select count(*) from working_hours w join staff st on st.id=w.staff_id join mb on mb.id=st.business_id),
 'ready',(select onboarding_complete from mb)
) $function$
;
CREATE OR REPLACE FUNCTION public.create_public_operator_booking(p_business_slug text, p_outreach_id uuid, p_staff_slug text, p_service_slug text, p_starts_at timestamp with time zone, p_display_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare o public.operator_outreach; b public.businesses; st public.staff; sv public.services; cid uuid; bk uuid; vend timestamptz;
begin
 select * into b from public.businesses where public_slug=p_business_slug;
 select * into o from public.operator_outreach where id=p_outreach_id and business_id=b.id and status in ('prepared','sent');
 if o.id is null then raise exception 'OUTREACH_NOT_FOUND'; end if;
 select * into st from public.staff where business_id=b.id and public_slug=p_staff_slug and active;
 select * into sv from public.services where business_id=b.id and public_slug=p_service_slug and active;
 if st.id is null or sv.id is null then raise exception 'INVALID_STAFF_OR_SERVICE'; end if;
 vend:=p_starts_at+make_interval(mins=>sv.duration_minutes);
 cid:=o.customer_id;
 if cid is null then insert into public.customers(business_id,display_name) values(b.id,left(coalesce(nullif(trim(p_display_name),''),'Guest'),120)) returning id into cid; end if;
 insert into public.bookings(business_id,customer_id,staff_id,service_id,starts_at,ends_at,status,source,operator_decision_id,operator_outreach_id)
 values(b.id,cid,st.id,sv.id,p_starts_at,vend,'confirmed','operator',o.decision_id,o.id) returning id into bk;
 update public.operator_outreach set status='converted' where id=o.id;
 return bk;
exception when exclusion_violation then raise exception 'SLOT_ALREADY_BOOKED';
end $function$
;
CREATE OR REPLACE FUNCTION public.create_public_operator_booking_v2(p_business_slug text, p_recovery_token text, p_staff_slug text, p_service_slug text, p_starts_at timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
declare ro public.recovery_offers; o public.operator_outreach; bid uuid; sid uuid; vid uuid; dur int; bk uuid;
begin
 if length(coalesce(p_recovery_token,''))<32 then raise exception 'INVALID_OFFER'; end if;
 select * into ro from public.recovery_offers where token_hash=encode(digest(p_recovery_token,'sha256'),'hex') and redeemed_at is null and expires_at>now();
 if ro.id is null then raise exception 'INVALID_OR_EXPIRED_OFFER'; end if;
 select * into o from public.operator_outreach where id=ro.outreach_id and status in ('prepared','sent');
 select id into bid from public.businesses where public_slug=p_business_slug;
 if o.id is null or o.business_id<>bid or ro.business_id<>bid then raise exception 'INVALID_OFFER'; end if;
 select id into sid from public.staff where business_id=bid and public_slug=p_staff_slug and active=true;
 select id,duration_minutes into vid,dur from public.services where business_id=bid and public_slug=p_service_slug and active=true;
 if sid is null or vid is null then raise exception 'INVALID_BOOKING_SELECTION'; end if;
 perform kavelyq_private.assert_booking_slot(bid,sid,vid,p_starts_at,null);
 insert into public.bookings(business_id,customer_id,staff_id,service_id,starts_at,ends_at,status,source,operator_decision_id,operator_outreach_id)
 values(bid,o.customer_id,sid,vid,p_starts_at,p_starts_at+make_interval(mins=>dur),'confirmed','operator',o.decision_id,o.id) returning id into bk;
 update public.recovery_offers set redeemed_at=now() where id=ro.id;
 update public.operator_outreach set status='converted' where id=o.id;
 return bk;
end $function$
;
CREATE OR REPLACE FUNCTION public.create_owner_business(p_name text, p_public_slug text, p_staff_name text, p_service_name text, p_duration_minutes integer, p_price_cents integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid:=auth.uid(); bid uuid; sid uuid; vid uuid; slug text;
begin
 if uid is null then raise exception 'AUTH_REQUIRED'; end if;
 if exists(select 1 from public.business_members where user_id=uid) then raise exception 'BUSINESS_ALREADY_EXISTS'; end if;
 if length(trim(coalesce(p_name,'')))<2 then raise exception 'INVALID_BUSINESS_NAME'; end if;
 slug:=lower(regexp_replace(trim(coalesce(p_public_slug,'')),'[^a-zA-Z0-9]+','-','g'));
 slug:=trim(both '-' from slug);
 if length(slug)<3 then raise exception 'INVALID_SLUG'; end if;
 if exists(select 1 from public.businesses where public_slug=slug) then raise exception 'SLUG_TAKEN'; end if;
 if p_duration_minutes<5 or p_duration_minutes>720 or p_price_cents<0 then raise exception 'INVALID_SERVICE'; end if;

 insert into public.businesses(name,public_slug,onboarding_complete,plan_code,trial_started_at,trial_ends_at,subscription_status)
 values(left(trim(p_name),120),slug,false,'zelora_pro',now(),now()+interval '14 days','trialing') returning id into bid;
 insert into public.business_members(business_id,user_id,role) values(bid,uid,'owner');
 insert into public.staff(business_id,display_name,public_slug) values(bid,left(trim(coalesce(nullif(p_staff_name,''),'Owner')),120),'owner') returning id into sid;
 insert into public.services(business_id,name,duration_minutes,price_cents,public_slug)
 values(bid,left(trim(coalesce(nullif(p_service_name,''),'Service')),120),p_duration_minutes,p_price_cents,'service-1') returning id into vid;
 insert into public.staff_services(staff_id,service_id) values(sid,vid);
 insert into public.working_hours(staff_id,weekday,start_time,end_time)
 select sid,d,'09:00'::time,'18:00'::time from generate_series(1,5) d;
 return jsonb_build_object('business_id',bid,'public_slug',slug,'trial_ends_at',now()+interval '14 days');
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_add_time_off(p_staff_id uuid, p_starts_at timestamp with time zone, p_ends_at timestamp with time zone, p_reason text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid; tid uuid;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if not exists(select 1 from staff where id=p_staff_id and business_id=bid) then raise exception 'FORBIDDEN'; end if;
 if p_ends_at<=p_starts_at then raise exception 'INVALID_TIME_OFF'; end if;
 insert into time_off(staff_id,starts_at,ends_at,reason) values(p_staff_id,p_starts_at,p_ends_at,left(coalesce(p_reason,''),200)) returning id into tid;
 return tid;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_plan_access()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
 select jsonb_build_object(
 'allowed',(b.subscription_status='active' or (b.subscription_status='trialing' and b.trial_ends_at>now())),
 'status',case when b.subscription_status='trialing' and b.trial_ends_at<=now() then 'expired' else b.subscription_status end,
 'trial_ends_at',b.trial_ends_at
 ) from public.businesses b join public.business_members bm on bm.business_id=b.id where bm.user_id=auth.uid() limit 1
$function$
;
CREATE OR REPLACE FUNCTION public.expire_finished_trials()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare n integer;
begin
 update public.businesses set subscription_status='expired'
 where subscription_status='trialing' and trial_ends_at<=now();
 get diagnostics n=row_count; return n;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_business_settings()
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'public'
AS $function$
 select jsonb_build_object('name',b.name,'public_slug',b.public_slug,'timezone',b.timezone,'currency',b.currency,'contact_email',b.contact_email,'contact_phone',b.contact_phone,'address',b.address_text,'cancellation_window_hours',b.cancellation_window_hours,'deposit_percent',b.deposit_percent,'no_show_policy',b.no_show_policy,'privacy_url',b.privacy_url,'terms_url',b.terms_url)
 from public.businesses b join public.business_members bm on bm.business_id=b.id where bm.user_id=auth.uid() limit 1
$function$
;
CREATE OR REPLACE FUNCTION public.owner_set_working_hours(p_staff_id uuid, p_weekday integer, p_start time without time zone, p_end time without time zone, p_enabled boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if not exists(select 1 from staff where id=p_staff_id and business_id=bid) or p_weekday<0 or p_weekday>6 then raise exception 'FORBIDDEN'; end if;
 delete from working_hours where staff_id=p_staff_id and weekday=p_weekday;
 if p_enabled then
  if p_start is null or p_end is null or p_start>=p_end then raise exception 'INVALID_HOURS'; end if;
  insert into working_hours(staff_id,weekday,start_time,end_time) values(p_staff_id,p_weekday,p_start,p_end);
 end if;
 return true;
end $function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.business_accepts_live_operations(p_business_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select exists(select 1 from public.businesses b where b.id=p_business_id and (
 exists(select 1 from kavelyq_private.demo_businesses d where d.business_id=b.id)
 or b.subscription_status='active'
 or (b.subscription_status='trialing' and b.trial_ends_at>now())
 ));
$function$
;
CREATE OR REPLACE FUNCTION public.get_public_booking_manage(p_token uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
 select jsonb_build_object('booking_id',bk.id,'business_slug',b.public_slug,'business_name',b.name,'timezone',b.timezone,'status',bk.status,'starts_at',bk.starts_at,'staff_slug',st.public_slug,'staff_name',st.display_name,'service_slug',sv.public_slug,'service_name',sv.name,'duration_minutes',sv.duration_minutes,'price_cents',bk.booked_price_cents,'cancellation_window_hours',b.cancellation_window_hours,'can_cancel',(bk.status in('pending','confirmed') and now()<bk.starts_at),'within_policy',(now() <= bk.starts_at-make_interval(hours=>b.cancellation_window_hours)))
 from bookings bk join businesses b on b.id=bk.business_id join staff st on st.id=bk.staff_id join services sv on sv.id=bk.service_id where bk.manage_token=p_token limit 1
$function$
;
CREATE OR REPLACE FUNCTION public.owner_update_business_settings(p_contact_email text, p_contact_phone text, p_address text, p_cancellation_window_hours integer, p_deposit_percent integer, p_no_show_policy text, p_privacy_url text, p_terms_url text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from public.business_members where user_id=auth.uid() limit 1;
 if bid is null then raise exception 'NOT_AUTHORIZED'; end if;
 if p_cancellation_window_hours<0 or p_cancellation_window_hours>336 or p_deposit_percent<0 or p_deposit_percent>100 then raise exception 'INVALID_POLICY'; end if;
 update businesses set contact_email=nullif(trim(p_contact_email),''),contact_phone=nullif(trim(p_contact_phone),''),address_text=nullif(trim(p_address),''),
 cancellation_window_hours=p_cancellation_window_hours,deposit_percent=p_deposit_percent,no_show_policy=left(coalesce(p_no_show_policy,''),500),
 privacy_url=nullif(trim(p_privacy_url),''),terms_url=nullif(trim(p_terms_url),'') where id=bid;
 return public.owner_business_settings();
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_update_service(p_service_id uuid, p_name text, p_duration_minutes integer, p_price_cents integer, p_active boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid; begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE'; end if;
 if length(trim(coalesce(p_name,'')))<2 or p_duration_minutes<5 or p_duration_minutes>720 or p_price_cents<0 then raise exception 'INVALID_SERVICE'; end if;
 update services set name=left(trim(p_name),120),duration_minutes=p_duration_minutes,price_cents=p_price_cents,active=p_active where id=p_service_id and business_id=bid;
 return found; end $function$
;
CREATE OR REPLACE FUNCTION public.owner_subscription_snapshot()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
 select jsonb_build_object(
 'plan_code',b.plan_code,'status',case when b.subscription_status='trialing' and b.trial_ends_at<=now() then 'expired' else b.subscription_status end,
 'trial_started_at',b.trial_started_at,'trial_ends_at',b.trial_ends_at,
 'days_left',greatest(0,ceil(extract(epoch from (b.trial_ends_at-now()))/86400.0)::int),
 'monthly_price_eur',null,'annual_price_eur',null,'proposed_plans_gbp',jsonb_build_object('essential',19,'intelligence',39),'live_billing_enabled',false,'billing_interval',b.billing_interval,
 'booking_commission_percent',0,'setup_fee_eur',0,
 'billing_connected',(b.subscription_provider is not null and b.subscription_customer_id is not null)
 ) from public.businesses b join public.business_members bm on bm.business_id=b.id where bm.user_id=auth.uid() and bm.role in('owner','manager') limit 1
$function$
;
CREATE OR REPLACE FUNCTION public.get_public_booking_catalog(p_business_slug text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
 select jsonb_build_object('business',jsonb_build_object('id',b.id,'name',b.name,'business_type',b.business_type,'is_demo',exists(select 1 from kavelyq_private.demo_businesses dm where dm.business_id=b.id),'timezone',b.timezone,'currency',b.currency,'address',b.address_text,'cancellation_window_hours',b.cancellation_window_hours,'deposit_percent',b.deposit_percent,'no_show_policy',b.no_show_policy,'privacy_url',b.privacy_url,'terms_url',b.terms_url),
 'services',coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'name',s.name,'duration_minutes',s.duration_minutes,'price_cents',s.price_cents,'public_slug',s.public_slug) order by s.name) from services s where s.business_id=b.id and s.active),'[]'::jsonb),
 'staff',coalesce((select jsonb_agg(jsonb_build_object('id',st.id,'display_name',st.display_name,'public_slug',st.public_slug) order by st.display_name) from staff st where st.business_id=b.id and st.active),'[]'::jsonb))
 from businesses b where b.public_slug=p_business_slug and kavelyq_private.business_accepts_live_operations(b.id) limit 1
$function$
;
CREATE OR REPLACE FUNCTION public.owner_setup_snapshot()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
with mine as (select business_id from business_members where user_id=auth.uid() and role in('owner','manager') limit 1)
select jsonb_build_object(
'business_id',b.id,
'staff',coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'name',s.display_name,'slug',s.public_slug,'active',s.active) order by s.created_at) from staff s where s.business_id=b.id),'[]'::jsonb),
'services',coalesce((select jsonb_agg(jsonb_build_object('id',v.id,'name',v.name,'duration_minutes',v.duration_minutes,'price_cents',v.price_cents,'slug',v.public_slug,'active',v.active) order by v.created_at) from services v where v.business_id=b.id),'[]'::jsonb),
'staff_services',coalesce((select jsonb_agg(jsonb_build_object('staff_id',ss.staff_id,'service_id',ss.service_id)) from staff_services ss join staff s on s.id=ss.staff_id where s.business_id=b.id),'[]'::jsonb),
'working_hours',coalesce((select jsonb_agg(jsonb_build_object('id',wh.id,'staff_id',wh.staff_id,'weekday',wh.weekday,'start_time',wh.start_time,'end_time',wh.end_time)) from working_hours wh join staff s on s.id=wh.staff_id where s.business_id=b.id),'[]'::jsonb),
'time_off',coalesce((select jsonb_agg(jsonb_build_object('id',t.id,'staff_id',t.staff_id,'starts_at',t.starts_at,'ends_at',t.ends_at,'reason',t.reason) order by t.starts_at) from time_off t join staff s on s.id=t.staff_id where s.business_id=b.id and t.ends_at>now()-interval '1 day'),'[]'::jsonb)
) from businesses b join mine m on m.business_id=b.id
$function$
;
CREATE OR REPLACE FUNCTION public.owner_set_staff_service(p_staff_id uuid, p_service_id uuid, p_enabled boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if not exists(select 1 from staff where id=p_staff_id and business_id=bid) or not exists(select 1 from services where id=p_service_id and business_id=bid) then raise exception 'FORBIDDEN'; end if;
 if p_enabled then insert into staff_services values(p_staff_id,p_service_id) on conflict do nothing; else delete from staff_services where staff_id=p_staff_id and service_id=p_service_id; end if;
 return true;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_add_service(p_name text, p_duration_minutes integer, p_price_cents integer)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid; sid uuid; slug text;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE'; end if;
 if length(trim(coalesce(p_name,'')))<2 or p_duration_minutes<5 or p_duration_minutes>720 or p_price_cents<0 then raise exception 'INVALID_SERVICE'; end if;
 slug:=lower(regexp_replace(trim(p_name),'[^a-zA-Z0-9]+','-','g'))||'-'||substr(gen_random_uuid()::text,1,6);
 insert into services(business_id,name,duration_minutes,price_cents,public_slug) values(bid,left(trim(p_name),120),p_duration_minutes,p_price_cents,slug) returning id into sid;
 insert into staff_services(staff_id,service_id) select id,sid from staff where business_id=bid and active on conflict do nothing;
 return sid;
end $function$
;
CREATE OR REPLACE FUNCTION public.cancel_public_booking(p_token uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bk bookings; hrs int; withinp boolean;
begin
 select * into bk from bookings where manage_token=p_token for update;
 if bk.id is null then raise exception 'INVALID_BOOKING_LINK'; end if;
 if bk.status not in('pending','confirmed') or bk.starts_at<=now() then raise exception 'BOOKING_NOT_CANCELLABLE'; end if;
 select cancellation_window_hours into hrs from businesses where id=bk.business_id;
 withinp:=now()<=bk.starts_at-make_interval(hours=>hrs);
 update bookings set status='cancelled',cancelled_at=now(),notes=concat_ws(E'\n',notes,case when withinp then 'Guest self-cancelled within policy.' else 'Guest self-cancelled after cancellation deadline.' end) where id=bk.id;
 return jsonb_build_object('cancelled',true,'within_policy',withinp);
end $function$
;
CREATE OR REPLACE FUNCTION public.reschedule_public_booking(p_token uuid, p_starts_at timestamp with time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bk bookings; dur int;
begin
 select * into bk from bookings where manage_token=p_token for update;
 if bk.id is null then raise exception 'INVALID_BOOKING_LINK'; end if;
 if bk.status not in('pending','confirmed') or bk.starts_at<=now() then raise exception 'BOOKING_NOT_RESCHEDULABLE'; end if;
 if not kavelyq_private.business_accepts_live_operations(bk.business_id) then raise exception 'BOOKING_UNAVAILABLE'; end if;
 perform kavelyq_private.assert_booking_slot(bk.business_id,bk.staff_id,bk.service_id,p_starts_at,bk.id);
 select duration_minutes into dur from services where id=bk.service_id;
 update bookings set starts_at=p_starts_at,ends_at=p_starts_at+make_interval(mins=>dur),cancelled_at=null where id=bk.id;
 return jsonb_build_object('rescheduled',true,'starts_at',p_starts_at);
end $function$
;
CREATE OR REPLACE FUNCTION public.get_public_manage_availability(p_token uuid, p_date date)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bk bookings; b businesses; st staff; sv services; v_day int; outj jsonb;
begin
 select * into bk from bookings where manage_token=p_token;
 if bk.id is null or bk.status not in('pending','confirmed') then return '[]'::jsonb; end if;
 select * into b from businesses where id=bk.business_id;
 select * into st from staff where id=bk.staff_id;
 select * into sv from services where id=bk.service_id;
 if not kavelyq_private.business_accepts_live_operations(b.id) then return '[]'::jsonb; end if;
 v_day:=extract(isodow from p_date)::int;
 select coalesce(jsonb_agg(to_char(slot_local,'HH24:MI') order by slot_local),'[]'::jsonb) into outj from (
  select gs slot_local from working_hours wh cross join lateral generate_series(p_date+wh.start_time,p_date+wh.end_time-make_interval(mins=>sv.duration_minutes),interval '15 min') gs
  where wh.staff_id=st.id and wh.weekday=v_day and (gs at time zone b.timezone)>now()
  and not exists(select 1 from bookings x where x.staff_id=st.id and x.status in('pending','confirmed') and x.id<>bk.id and tstzrange(x.starts_at,x.ends_at,'[)')&&tstzrange(gs at time zone b.timezone,(gs+make_interval(mins=>sv.duration_minutes)) at time zone b.timezone,'[)'))
  and not exists(select 1 from time_off t where t.staff_id=st.id and tstzrange(t.starts_at,t.ends_at,'[)')&&tstzrange(gs at time zone b.timezone,(gs+make_interval(mins=>sv.duration_minutes)) at time zone b.timezone,'[)'))
 )q;
 return outj;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_save_cut_memory(p_customer_id uuid, p_notes text, p_rebook_interval_days integer DEFAULT 28)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$declare c customers;bk bookings;cmid uuid;begin perform kavelyq_private.require_business_owner(); select * into c from customers where id=p_customer_id;if c.id is null or not kavelyq_private.is_business_member(c.business_id) then raise exception 'FORBIDDEN';end if;if not kavelyq_private.business_accepts_live_operations(c.business_id) then raise exception 'PLAN_INACTIVE';end if;select * into bk from bookings where customer_id=c.id and status='completed' order by coalesce(completed_at,starts_at) desc limit 1;if bk.id is null then raise exception 'NO_COMPLETED_VISIT';end if;insert into cut_memory(business_id,customer_id,staff_id,service_id,notes,updated_at) values(c.business_id,c.id,bk.staff_id,bk.service_id,left(coalesce(p_notes,''),1000),now()) returning id into cmid;update customers set rebook_interval_days=greatest(7,least(coalesce(p_rebook_interval_days,28),180)) where id=c.id;perform kavelyq_private.refresh_customer_crm(c.id);return jsonb_build_object('cut_memory_id',cmid,'customer_id',c.id);end$function$
;
CREATE OR REPLACE FUNCTION public.create_public_booking_local_v2(p_business_slug text, p_staff_slug text, p_service_slug text, p_date date, p_time time without time zone, p_display_name text DEFAULT 'Guest'::text, p_email text DEFAULT NULL::text, p_phone text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare tz text; ts timestamptz;
begin
 select timezone into tz from businesses where public_slug=p_business_slug;
 if tz is null then raise exception 'BOOKING_UNAVAILABLE'; end if;
 ts := (p_date + p_time) at time zone tz;
 return create_public_booking_v2(p_business_slug,p_staff_slug,p_service_slug,ts,p_display_name,p_email,p_phone);
end$function$
;
CREATE OR REPLACE FUNCTION public.reschedule_public_booking_local(p_token uuid, p_date date, p_time time without time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare tz text;ts timestamptz;
begin
 select b.timezone into tz from bookings bk join businesses b on b.id=bk.business_id where bk.manage_token=p_token;
 if tz is null then raise exception 'BOOKING_NOT_FOUND'; end if;
 ts := (p_date+p_time) at time zone tz;
 return reschedule_public_booking(p_token,ts);
end$function$
;
CREATE OR REPLACE FUNCTION public.complete_email_notification(p_id uuid, p_provider_message_id text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if coalesce(current_setting('request.jwt.claim.role',true),'') <> 'service_role' then raise exception 'SERVICE_ROLE_REQUIRED'; end if;
 update notification_queue set status='sent',provider_message_id=p_provider_message_id,sent_at=now(),last_error=null where id=p_id and status='processing';
end$function$
;
CREATE OR REPLACE FUNCTION public.fail_email_notification(p_id uuid, p_error text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
 if coalesce(current_setting('request.jwt.claim.role',true),'') <> 'service_role' then raise exception 'SERVICE_ROLE_REQUIRED'; end if;
 update notification_queue set status='failed',last_error=left(coalesce(p_error,'UNKNOWN'),1000) where id=p_id and status='processing';
end$function$
;
CREATE OR REPLACE FUNCTION public.create_public_operator_booking(p_business_slug text, p_outreach_id uuid, p_staff_slug text, p_service_slug text, p_starts_at timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare o operator_outreach; bid uuid; sid uuid; vid uuid; dur int; bk uuid;
begin
 select * into o from operator_outreach where id=p_outreach_id and status in ('prepared','sent');
 select id into bid from businesses where public_slug=p_business_slug;
 if o.id is null or o.business_id<>bid then raise exception 'INVALID_OFFER'; end if;
 select id into sid from staff where business_id=bid and public_slug=p_staff_slug and active=true;
 select id,duration_minutes into vid,dur from services where business_id=bid and public_slug=p_service_slug and active=true;
 if sid is null or vid is null then raise exception 'INVALID_BOOKING_SELECTION'; end if;
 perform kavelyq_private.assert_booking_slot(bid,sid,vid,p_starts_at,null);
 insert into bookings(business_id,customer_id,staff_id,service_id,starts_at,ends_at,status,source,operator_decision_id,operator_outreach_id)
 values(bid,o.customer_id,sid,vid,p_starts_at,p_starts_at+make_interval(mins=>dur),'confirmed','operator',o.decision_id,o.id) returning id into bk;
 update operator_outreach set status='converted' where id=o.id;
 return bk;
end $function$
;
CREATE OR REPLACE FUNCTION public.queue_booking_notifications()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare em text; nm text; business_name text; staff_name text; service_name text; tz text; base_payload jsonb;
begin
 select c.email,c.display_name into em,nm from customers c where c.id=new.customer_id;
 select b.name,b.timezone,st.display_name,sv.name into business_name,tz,staff_name,service_name
 from businesses b join staff st on st.id=new.staff_id join services sv on sv.id=new.service_id where b.id=new.business_id;
 base_payload=jsonb_build_object('customer_name',nm,'business_name',business_name,'staff_name',staff_name,'service_name',service_name,'starts_at',new.starts_at,'timezone',tz,'manage_token',new.manage_token);
 if tg_op='INSERT' then
  if em is not null then
   insert into notification_queue(business_id,booking_id,customer_id,channel,template,destination,scheduled_for,payload)
   values(new.business_id,new.id,new.customer_id,'email','booking_confirmation',em,now(),base_payload);
   if new.starts_at>now()+interval '25 hours' then
    insert into notification_queue(business_id,booking_id,customer_id,channel,template,destination,scheduled_for,payload)
    values(new.business_id,new.id,new.customer_id,'email','booking_reminder',em,new.starts_at-interval '24 hours',base_payload);
   end if;
  end if;
 elsif new.status='cancelled' and old.status is distinct from new.status and em is not null then
  update notification_queue set status='cancelled' where booking_id=new.id and status in ('pending','failed','processing');
  insert into notification_queue(business_id,booking_id,customer_id,channel,template,destination,scheduled_for,payload)
  values(new.business_id,new.id,new.customer_id,'email','booking_cancelled',em,now(),base_payload);
 end if;
 return new;
end$function$
;
CREATE OR REPLACE FUNCTION public.owner_create_booking_local(p_business_id uuid, p_staff_id uuid, p_service_id uuid, p_date date, p_time time without time zone, p_customer_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare tz text; ts timestamptz;
begin perform kavelyq_private.require_business_owner();
 if not kavelyq_private.is_business_member(p_business_id) then raise exception 'FORBIDDEN'; end if;
 select timezone into tz from businesses where id=p_business_id;
 if tz is null then raise exception 'BUSINESS_NOT_FOUND'; end if;
 ts=(p_date+p_time) at time zone tz;
 return owner_create_booking(p_business_id,p_staff_id,p_service_id,ts,p_customer_name);
end$function$
;
CREATE OR REPLACE FUNCTION public.owner_reschedule_booking_local(p_booking_id uuid, p_date date, p_time time without time zone)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare bid uuid; tz text; ts timestamptz;
begin perform kavelyq_private.require_business_owner();
 select bk.business_id,b.timezone into bid,tz from bookings bk join businesses b on b.id=bk.business_id where bk.id=p_booking_id;
 if bid is null or not kavelyq_private.is_business_member(bid) then raise exception 'FORBIDDEN'; end if;
 ts=(p_date+p_time) at time zone tz;
 return owner_reschedule_booking(p_booking_id,ts);
end$function$
;
CREATE OR REPLACE FUNCTION public.owner_business_metrics()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
with mb as (
 select b.id,b.timezone from public.business_members bm join public.businesses b on b.id=bm.business_id
 where bm.user_id=(select auth.uid()) limit 1
), z as (
 select id,timezone,(now() at time zone timezone)::date today,
 (date_trunc('month',now() at time zone timezone) at time zone timezone) ms,
 ((date_trunc('month',now() at time zone timezone)+interval '1 month') at time zone timezone) me from mb
)
select jsonb_build_object(
'today_bookings',(select count(*) from public.bookings bk join z on z.id=bk.business_id where (bk.starts_at at time zone z.timezone)::date=z.today and bk.status<>'cancelled'),
'next_7_days',(select count(*) from public.bookings bk join z on z.id=bk.business_id where bk.starts_at>=now() and bk.starts_at<now()+interval '7 days' and bk.status='confirmed'),
'completed_month',(select count(*) from public.bookings bk join z on z.id=bk.business_id where bk.completed_at>=z.ms and bk.completed_at<z.me and bk.status='completed'),
'no_shows_month',(select count(*) from public.bookings bk join z on z.id=bk.business_id where bk.starts_at>=z.ms and bk.starts_at<z.me and bk.status='no_show'),
'booked_revenue_cents',(select coalesce(sum(bk.booked_price_cents),0) from public.bookings bk join z on z.id=bk.business_id join public.services sv on sv.id=bk.service_id where bk.starts_at>=z.ms and bk.starts_at<z.me and bk.status in('confirmed','completed')),
'completed_revenue_cents',(select coalesce(sum(bk.booked_price_cents),0) from public.bookings bk join z on z.id=bk.business_id join public.services sv on sv.id=bk.service_id where bk.completed_at>=z.ms and bk.completed_at<z.me and bk.status='completed')
) $function$
;
CREATE OR REPLACE FUNCTION public.owner_operator_snapshot()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
with mb as (
 select b.id,b.name,b.timezone from public.business_members bm join public.businesses b on b.id=bm.business_id
 where bm.user_id=(select auth.uid()) limit 1
), z as (
 select id,name,timezone,
 (date_trunc('month',now() at time zone timezone) at time zone timezone) ms,
 ((date_trunc('month',now() at time zone timezone)+interval '1 month') at time zone timezone) me from mb
), stats as (
 select
 (select count(*) from public.bookings bk join z on z.id=bk.business_id where bk.status='cancelled' and bk.starts_at>now()) cancelled_future,
 (select count(*) from public.bookings bk join z on z.id=bk.business_id where bk.status='confirmed' and bk.starts_at>=now() and bk.starts_at<now()+interval '7 days') upcoming,
 (select count(*) from public.customers c join z on z.id=c.business_id) customers,
 (select coalesce(sum(bk.booked_price_cents),0) from public.bookings bk join z on z.id=bk.business_id join public.services sv on sv.id=bk.service_id where bk.status='confirmed' and bk.starts_at>=z.ms and bk.starts_at<z.me) booked_revenue
)
select jsonb_build_object(
'business',(select jsonb_build_object('id',id,'name',name,'timezone',timezone) from z),
'signals',(select jsonb_build_object('cancelled_future',cancelled_future,'upcoming_7d',upcoming,'customers',customers,'booked_revenue_cents',booked_revenue) from stats),
'decisions',coalesce((select jsonb_agg(jsonb_build_object('id',d.id,'kind',d.kind,'action_type',d.action_type,'reason',d.reason,'status',d.status,'expected_impact_cents',d.expected_impact_cents,'actual_impact_cents',d.actual_impact_cents,'created_at',d.created_at,'executed_at',d.executed_at,'result',d.result) order by d.created_at desc) from public.operator_decisions d join z on z.id=d.business_id),'[]'::jsonb)
) $function$
;
CREATE OR REPLACE FUNCTION public.get_public_availability(p_business_slug text, p_staff_slug text, p_service_slug text, p_date date)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_business businesses; v_staff staff; v_service services; v_day int; v_slots jsonb;
begin
 select * into v_business from businesses where public_slug=p_business_slug;
 if v_business.id is null or not kavelyq_private.business_accepts_live_operations(v_business.id) then return '[]'::jsonb; end if;
 select * into v_staff from staff where business_id=v_business.id and public_slug=p_staff_slug and active;
 select * into v_service from services where business_id=v_business.id and public_slug=p_service_slug and active;
 if v_staff.id is null or v_service.id is null or not exists(select 1 from staff_services where staff_id=v_staff.id and service_id=v_service.id) then return '[]'::jsonb; end if;
 v_day:=extract(dow from p_date)::int;
 select coalesce(jsonb_agg(to_char(slot_local,'HH24:MI') order by slot_local),'[]'::jsonb) into v_slots from (
 select gs slot_local from working_hours wh cross join lateral generate_series(p_date+wh.start_time,p_date+wh.end_time-make_interval(mins=>v_service.duration_minutes),interval '15 min') gs
 where wh.staff_id=v_staff.id and wh.weekday=v_day and (gs at time zone v_business.timezone)>now()
 and not exists(select 1 from bookings bk where bk.staff_id=v_staff.id and bk.status in('pending','confirmed') and tstzrange(bk.starts_at,bk.ends_at,'[)')&&tstzrange(gs at time zone v_business.timezone,(gs+make_interval(mins=>v_service.duration_minutes)) at time zone v_business.timezone,'[)'))
 and not exists(select 1 from time_off t where t.staff_id=v_staff.id and tstzrange(t.starts_at,t.ends_at,'[)')&&tstzrange(gs at time zone v_business.timezone,(gs+make_interval(mins=>v_service.duration_minutes)) at time zone v_business.timezone,'[)')))q;
 return v_slots;
end $function$
;
CREATE OR REPLACE FUNCTION public.create_public_booking(p_business_slug text, p_staff_slug text, p_service_slug text, p_starts_at timestamp with time zone, p_display_name text DEFAULT 'Guest'::text, p_email text DEFAULT NULL::text, p_phone text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid; sid uuid; vid uuid; dur int; cid uuid; bk uuid;
begin
 select id into bid from businesses where public_slug=p_business_slug;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'BOOKING_UNAVAILABLE'; end if;
 if p_starts_at<=now() then raise exception 'PAST_BOOKING'; end if;
 if length(coalesce(p_email,''))>254 or length(coalesce(p_phone,''))>40 or length(coalesce(p_display_name,''))>120 then raise exception 'INVALID_CONTACT'; end if;
 select id into sid from staff where business_id=bid and public_slug=p_staff_slug and active=true;
 select id,duration_minutes into vid,dur from services where business_id=bid and public_slug=p_service_slug and active=true;
 if sid is null or vid is null then raise exception 'INVALID_BOOKING_SELECTION'; end if;
 if not exists(select 1 from staff_services where staff_id=sid and service_id=vid) then raise exception 'SERVICE_NOT_OFFERED_BY_STAFF'; end if;
 perform kavelyq_private.assert_booking_slot(bid,sid,vid,p_starts_at,null);
 insert into customers(business_id,display_name,email,phone) values(bid,left(coalesce(nullif(trim(p_display_name),''),'Guest'),120),nullif(trim(p_email),''),nullif(trim(p_phone),'')) returning id into cid;
 insert into bookings(business_id,customer_id,staff_id,service_id,starts_at,ends_at,status,source) values(bid,cid,sid,vid,p_starts_at,p_starts_at+make_interval(mins=>dur),'confirmed','guest') returning id into bk;
 return bk;
end $function$
;
CREATE OR REPLACE FUNCTION public.create_public_booking_v2(p_business_slug text, p_staff_slug text, p_service_slug text, p_starts_at timestamp with time zone, p_display_name text DEFAULT 'Guest'::text, p_email text DEFAULT NULL::text, p_phone text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid;sid uuid;vid uuid;dur int;cid uuid;bk uuid;tok uuid;ch text;recent int;
begin
 select id into bid from businesses where public_slug=p_business_slug;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'BOOKING_UNAVAILABLE';end if;
 if p_starts_at is null or p_starts_at<=now() then raise exception 'PAST_BOOKING';end if;
 if length(p_display_name)>120 or length(trim(coalesce(p_display_name,'')))<2 or length(coalesce(p_email,''))>254 or length(coalesce(p_phone,''))>40 then raise exception 'INVALID_CONTACT';end if;
 if nullif(trim(coalesce(p_email,'')),'') is null and nullif(trim(coalesce(p_phone,'')),'') is null then raise exception 'CONTACT_REQUIRED';end if;
 if nullif(trim(p_email),'') is not null and trim(p_email) !~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$' then raise exception 'INVALID_EMAIL'; end if;
 if nullif(trim(p_phone),'') is not null and trim(p_phone) !~ '^[+]?[0-9 ()-]{6,40}$' then raise exception 'INVALID_PHONE'; end if;
 ch:=md5(lower(trim(coalesce(p_email,'')))||'|'||regexp_replace(coalesce(p_phone,''),'\s','','g'));
 perform pg_advisory_xact_lock(hashtextextended(bid::text||ch,0)); select count(*) into recent from public_booking_rate_limits where business_id=bid and contact_hash=ch and created_at>now()-interval '10 minutes';
 if recent>=3 then raise exception 'RATE_LIMITED';end if;
 insert into public_booking_rate_limits(business_id,contact_hash) values(bid,ch);
 delete from public_booking_rate_limits where created_at<now()-interval '2 days';
 select id into sid from staff where business_id=bid and public_slug=p_staff_slug and active;
 select id,duration_minutes into vid,dur from services where business_id=bid and public_slug=p_service_slug and active;
 if sid is null or vid is null or not exists(select 1 from staff_services where staff_id=sid and service_id=vid) then raise exception 'INVALID_BOOKING_SELECTION';end if;
 perform kavelyq_private.assert_booking_slot(bid,sid,vid,p_starts_at,null);
 insert into customers(business_id,display_name,email,phone) values(bid,left(trim(p_display_name),120),nullif(trim(p_email),''),nullif(trim(p_phone),'')) returning id into cid;
 insert into bookings(business_id,customer_id,staff_id,service_id,starts_at,ends_at,status,source) values(bid,cid,sid,vid,p_starts_at,p_starts_at+make_interval(mins=>dur),'confirmed','guest') returning id,manage_token into bk,tok;
 return jsonb_build_object('booking_id',bk,'manage_token',tok);
end$function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.capture_booking_price()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
 if tg_op='INSERT' or new.service_id is distinct from old.service_id then
  select price_cents into new.booked_price_cents from public.services where id=new.service_id;
 else new.booked_price_cents:=old.booked_price_cents;
 end if;
 return new;
end
$function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.refresh_customer_crm(p_customer_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare c public.customers; last_b public.bookings; cnt int; ltv int; interval_days int;
begin
 select * into c from public.customers where id=p_customer_id;
 if c.id is null then return; end if;
 select bk.* into last_b from public.bookings bk where bk.customer_id=c.id and bk.status='completed'
 order by coalesce(bk.completed_at,bk.starts_at) desc limit 1;
 select count(*),coalesce(sum(bk.booked_price_cents),0) into cnt,ltv
 from public.bookings bk join public.services s on s.id=bk.service_id
 where bk.customer_id=c.id and bk.status='completed';
 interval_days:=coalesce(c.rebook_interval_days,28);
 update public.customers set
  last_visit_at=coalesce(last_b.completed_at,last_b.starts_at),
  preferred_staff_id=coalesce(last_b.staff_id,preferred_staff_id),
  preferred_service_id=coalesce(last_b.service_id,preferred_service_id),
  visit_count=cnt,lifetime_value_cents=ltv,
  next_due_at=case when last_b.id is null then null else coalesce(last_b.completed_at,last_b.starts_at)+make_interval(days=>interval_days) end,
  crm_status=case when last_b.id is null then 'active'
    when coalesce(last_b.completed_at,last_b.starts_at)+make_interval(days=>interval_days*2)<now() then 'inactive'
    when coalesce(last_b.completed_at,last_b.starts_at)+make_interval(days=>interval_days)<now() then 'overdue'
    when coalesce(last_b.completed_at,last_b.starts_at)+make_interval(days=>greatest(interval_days-7,1))<now() then 'due'
    else 'active' end
 where id=c.id;
end $function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.assert_booking_slot(p_business_id uuid, p_staff_id uuid, p_service_id uuid, p_starts_at timestamp with time zone, p_exclude_booking uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ declare dur int; local_start timestamp; local_end timestamp; dow int; begin perform pg_advisory_xact_lock(hashtextextended('kavelyq-booking-staff:'||p_staff_id::text,0)); if p_starts_at is null or p_starts_at<=now() then raise exception 'PAST_BOOKING'; end if; select duration_minutes into dur from services where id=p_service_id and business_id=p_business_id and active=true; if dur is null then raise exception 'INVALID_SERVICE'; end if; if not exists(select 1 from staff where id=p_staff_id and business_id=p_business_id and active=true) then raise exception 'INVALID_STAFF'; end if; if not exists(select 1 from staff_services where staff_id=p_staff_id and service_id=p_service_id) then raise exception 'SERVICE_NOT_OFFERED'; end if; local_start:=p_starts_at at time zone coalesce((select timezone from businesses where id=p_business_id),'Europe/Vienna'); local_end:=local_start+make_interval(mins=>dur); dow:=extract(dow from local_start)::int; if extract(second from local_start)<>0 or (extract(minute from local_start)::int % 15)<>0 then raise exception 'INVALID_SLOT_INTERVAL'; end if; if not exists(select 1 from working_hours wh where wh.staff_id=p_staff_id and wh.weekday=dow and local_start::time>=wh.start_time and local_end::time<=wh.end_time and local_start::date=local_end::date) then raise exception 'OUTSIDE_WORKING_HOURS'; end if; if exists(select 1 from time_off t where t.staff_id=p_staff_id and tstzrange(t.starts_at,t.ends_at,'[)')&&tstzrange(p_starts_at,p_starts_at+make_interval(mins=>dur),'[)')) then raise exception 'STAFF_TIME_OFF'; end if; if exists(select 1 from bookings b where b.business_id=p_business_id and b.staff_id=p_staff_id and b.status in('pending','confirmed') and (p_exclude_booking is null or b.id<>p_exclude_booking) and tstzrange(b.starts_at,b.ends_at,'[)')&&tstzrange(p_starts_at,p_starts_at+make_interval(mins=>dur),'[)')) then raise exception 'SLOT_ALREADY_BOOKED'; end if; end $function$
;
CREATE OR REPLACE FUNCTION public.owner_communication_status()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare bid uuid:=kavelyq_private.require_business_owner();begin
return jsonb_build_object('delivery_enabled',coalesce((select transactional_enabled and provider_verified from kavelyq_private.communication_delivery where business_id=bid),false),'pending',(select count(*) from public.notification_queue where business_id=bid and status='pending'),'failed',(select count(*) from public.notification_queue where business_id=bid and status='failed'),'processing',(select count(*) from public.notification_queue where business_id=bid and status='processing'),'provider_note','No provider is enabled by default. Queued records are not evidence of delivery.','monitoring_note','GitHub smoke checks monitor public availability; browser errors and delivered-email outcomes require separate monitoring.');
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_branding_snapshot()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
 select coalesce((select b.config from public.business_branding b join public.business_members m on m.business_id=b.business_id where m.user_id=(select auth.uid()) and m.role in('owner','manager') limit 1),'{}'::jsonb)
$function$
;
CREATE OR REPLACE FUNCTION public.get_public_branding(p_business_slug text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select coalesce(br.config,'{}'::jsonb) from public.businesses b left join public.business_branding br on br.business_id=b.id where b.public_slug=p_business_slug and kavelyq_private.business_accepts_live_operations(b.id)
$function$
;
CREATE OR REPLACE FUNCTION public.owner_import_records(p_kind text, p_records jsonb, p_preview boolean DEFAULT true)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare bid uuid;r jsonb;i int:=0;issues jsonb:='[]';seen text[]:=array[]::text[];key text;nm text;em text;ph text;n int;price int;inserted int:=0;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from public.business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if p_kind is null or p_records is null or p_preview is null or p_kind not in('customers','staff','services') or jsonb_typeof(p_records)<>'array' or jsonb_array_length(p_records) not between 1 and 1000 then raise exception 'INVALID_IMPORT';end if;
 perform pg_advisory_xact_lock(hashtextextended('kavelyq-import:'||bid::text,0));
 for r in select value from jsonb_array_elements(p_records) loop
  i:=i+1;nm:=trim(coalesce(r->>'name',''));em:=nullif(lower(trim(r->>'email')),'');ph:=nullif(trim(r->>'phone'),'');
  if length(nm) not between 2 and 120 then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Invalid name'));end if;
  if p_kind='customers' then
   if (em is not null and (length(em)>254 or em !~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$')) or (ph is not null and ph !~ '^[+]?[0-9 ()-]{6,40}$') then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Invalid contact'));end if;
   if exists(select 1 from public.customers c where c.business_id=bid and c.deleted_at is null and ((em is not null and lower(c.email)=em) or (ph is not null and regexp_replace(c.phone,'[^0-9]','','g')=regexp_replace(ph,'[^0-9]','','g')) or (em is null and ph is null and lower(c.display_name)=lower(nm)))) then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Existing customer duplicate'));end if;
   foreach key in array array[case when em is not null then 'e:'||em end,case when ph is not null then 'p:'||regexp_replace(ph,'[^0-9]','','g') end,case when em is null and ph is null then 'n:'||lower(nm) end] loop
    if key is not null then if key=any(seen) then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Duplicate in file'));end if;seen:=array_append(seen,key);end if;
   end loop;
  else
   key:=lower(nm);if key=any(seen) then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Duplicate in file'));end if;seen:=array_append(seen,key);
   if (p_kind='staff' and exists(select 1 from public.staff where business_id=bid and lower(display_name)=key)) or (p_kind='services' and exists(select 1 from public.services where business_id=bid and lower(name)=key)) then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Existing record duplicate'));end if;
   if p_kind='services' then
    if coalesce(r->>'duration_minutes','') !~ '^[0-9]{1,3}$' or coalesce(r->>'price_cents','') !~ '^[0-9]{1,8}$' then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Use integer duration_minutes and price_cents'));
    elsif (r->>'duration_minutes')::int not between 5 and 720 then issues:=issues||jsonb_build_array(jsonb_build_object('row',i,'error','Duration must be 5–720 minutes'));end if;
   end if;
  end if;
 end loop;
 if p_preview or jsonb_array_length(issues)>0 then return jsonb_build_object('preview',true,'rows',i,'errors',issues,'inserted',0);end if;
 for r in select value from jsonb_array_elements(p_records) loop
  if p_kind='customers' then insert into public.customers(business_id,display_name,email,phone,marketing_consent,consent_marketing) values(bid,trim(r->>'name'),nullif(lower(trim(r->>'email')),''),nullif(trim(r->>'phone'),''),false,false);
  elsif p_kind='staff' then perform public.owner_add_staff(trim(r->>'name'));
  else perform public.owner_add_service(trim(r->>'name'),(r->>'duration_minutes')::int,(r->>'price_cents')::int);end if;
  inserted:=inserted+1;
 end loop;
 return jsonb_build_object('preview',false,'rows',i,'errors','[]'::jsonb,'inserted',inserted);
end $function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.record_business_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare row_data jsonb;bid uuid;rid text;
begin
 row_data:=case when tg_op='DELETE' then to_jsonb(old) else to_jsonb(new) end;
 if tg_table_name='businesses' then bid:=(row_data->>'id')::uuid;
 elsif row_data ? 'business_id' then bid:=(row_data->>'business_id')::uuid;
 else select business_id into bid from public.staff where id=(row_data->>'staff_id')::uuid;end if;
 rid:=coalesce(row_data->>'id',row_data->>'business_id',(row_data->>'staff_id')||':'||(row_data->>'service_id'));
 if bid is not null then insert into public.business_audit_log(business_id,actor_id,entity,record_id,operation) values(bid,auth.uid(),tg_table_name,coalesce(rid,'unknown'),tg_op);end if;
 if tg_op='DELETE' then return old;else return new;end if;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_performance_report(p_start date, p_end date)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO ''
AS $function$
declare bid uuid;tz text;result jsonb;
begin perform kavelyq_private.require_business_owner();
 select b.id,b.timezone into bid,tz from public.businesses b join public.business_members m on m.business_id=b.id where m.user_id=auth.uid() limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if p_start is null or p_end is null or p_end<=p_start or p_end-p_start>366 then raise exception 'INVALID_DATE_RANGE';end if;
 with records as(select b.*,s.display_name staff_name,v.name service_name from public.bookings b join public.staff s on s.id=b.staff_id join public.services v on v.id=b.service_id where b.business_id=bid and b.starts_at>=(p_start::timestamp at time zone tz) and b.starts_at<(p_end::timestamp at time zone tz)),
 staff_rows as(select staff_name name,count(*) total,count(*) filter(where status='completed') completed,coalesce(sum(booked_price_cents) filter(where status='completed'),0) completed_value_cents,count(*) filter(where status='cancelled') cancelled,count(*) filter(where status='no_show') no_shows from records group by staff_name),
 service_rows as(select service_name name,count(*) total,count(*) filter(where status='completed') completed,coalesce(sum(booked_price_cents) filter(where status='completed'),0) completed_value_cents from records group by service_name),
 repeat_rows as(select customer_id,count(*) n from records where status='completed' and customer_id is not null group by customer_id)
 select jsonb_build_object('staff',coalesce((select jsonb_agg(to_jsonb(s)) from staff_rows s),'[]'::jsonb),'services',coalesce((select jsonb_agg(to_jsonb(s)) from service_rows s),'[]'::jsonb),'visiting_customers',(select count(*) from repeat_rows),'repeat_customers',(select count(*) from repeat_rows where n>1),'period_start',p_start,'period_end',p_end,'value_basis','completed service value, not collected payments') into result;
 return result;
end $function$
;
CREATE OR REPLACE FUNCTION public.create_owner_business_industry(p_name text, p_public_slug text, p_staff_name text, p_service_name text, p_duration_minutes integer, p_price_cents integer, p_business_type text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare result jsonb;
begin
 if p_business_type is null or p_business_type not in ('barber','beauty','tattoo','nails','wellness','other') then raise exception 'INVALID_BUSINESS_TYPE'; end if;
 result:=public.create_owner_business(p_name,p_public_slug,p_staff_name,p_service_name,p_duration_minutes,p_price_cents);
 update public.businesses set business_type=p_business_type where id=(result->>'business_id')::uuid and exists(select 1 from public.business_members where business_id=businesses.id and user_id=auth.uid() and role='owner');
 if not found then raise exception 'BUSINESS_TYPE_SAVE_FAILED'; end if;
 return result || jsonb_build_object('business_type',p_business_type);
end $function$
;
CREATE OR REPLACE FUNCTION public.create_owner_business_v2(p_name text, p_public_slug text, p_staff_name text, p_service_name text, p_duration_minutes integer, p_price_cents integer, p_timezone text DEFAULT 'Europe/London'::text, p_currency text DEFAULT 'GBP'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare r jsonb;bid uuid;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED';end if; if p_timezone is null or not exists(select 1 from pg_catalog.pg_timezone_names where name=p_timezone) or p_currency is null or p_currency not in('GBP','EUR','USD','CAD','AUD','NZD','CHF') then raise exception 'INVALID_LOCALISATION';end if;
 r:=public.create_owner_business(p_name,p_public_slug,p_staff_name,p_service_name,p_duration_minutes,p_price_cents);bid:=(r->>'business_id')::uuid;
 update public.businesses set timezone=p_timezone,currency=p_currency where id=bid and exists(select 1 from public.business_members m where m.business_id=bid and m.user_id=auth.uid() and m.role='owner');
 if not found then raise exception 'BUSINESS_SETUP_FAILED';end if;
 return r||jsonb_build_object('timezone',p_timezone,'currency',p_currency);
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_industry_profile()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
 select jsonb_build_object('business_type',b.business_type,'business_name',b.name)
 from public.businesses b join public.business_members m on m.business_id=b.id
 where m.user_id=auth.uid() and m.role in ('owner','manager')
 order by b.created_at limit 1
$function$
;
CREATE OR REPLACE FUNCTION public.owner_calendar_range(p_start date, p_end date, p_staff_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO ''
AS $function$
declare bid uuid;tz text;out jsonb;
begin perform kavelyq_private.require_business_owner();
 select b.id,b.timezone into bid,tz from public.businesses b join public.business_members m on m.business_id=b.id where m.user_id=auth.uid() limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if p_start is null or p_end is null or p_end<=p_start or p_end-p_start>62 then raise exception 'INVALID_DATE_RANGE';end if;
 select coalesce(jsonb_agg(jsonb_build_object('id',b.id,'starts_at',b.starts_at,'ends_at',b.ends_at,'status',b.status,'customer',c.display_name,'staff',s.display_name,'service',v.name,'price_cents',b.booked_price_cents) order by b.starts_at),'[]'::jsonb) into out
 from public.bookings b join public.staff s on s.id=b.staff_id join public.services v on v.id=b.service_id left join public.customers c on c.id=b.customer_id
 where b.business_id=bid and b.starts_at>=(p_start::timestamp at time zone tz) and b.starts_at<(p_end::timestamp at time zone tz) and (p_staff_id is null or b.staff_id=p_staff_id);
 return out;
end $function$
;
CREATE OR REPLACE FUNCTION public.create_owner_business_industry_v2(p_name text, p_public_slug text, p_staff_name text, p_service_name text, p_duration_minutes integer, p_price_cents integer, p_business_type text, p_timezone text DEFAULT 'Europe/London'::text, p_currency text DEFAULT 'GBP'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare r jsonb;bid uuid;
begin
 if auth.uid() is null then raise exception 'AUTH_REQUIRED';end if;
 if p_business_type is null or p_business_type not in('barber','beauty','nails','wellness','other') then raise exception 'INVALID_BUSINESS_TYPE';end if;
 r:=public.create_owner_business_v2(p_name,p_public_slug,p_staff_name,p_service_name,p_duration_minutes,p_price_cents,p_timezone,p_currency);bid:=(r->>'business_id')::uuid;
 update public.businesses set business_type=p_business_type where id=bid and exists(select 1 from public.business_members m where m.business_id=bid and m.user_id=auth.uid() and m.role='owner');
 if not found then raise exception 'BUSINESS_TYPE_SAVE_FAILED';end if;
 return r||jsonb_build_object('business_type',p_business_type);
end $function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.require_business_owner()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare bid uuid;begin
 select business_id into bid from public.business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null then raise exception 'OWNER_ROLE_REQUIRED' using errcode='42501';end if;return bid;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_add_staff(p_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid; sid uuid; slug text;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE'; end if;
 if length(trim(coalesce(p_name,'')))<2 then raise exception 'INVALID_STAFF'; end if;
 slug:=lower(regexp_replace(trim(p_name),'[^a-zA-Z0-9]+','-','g'))||'-'||substr(gen_random_uuid()::text,1,6);
 insert into staff(business_id,display_name,public_slug) values(bid,left(trim(p_name),120),slug) returning id into sid;
 insert into staff_services(staff_id,service_id) select sid,id from services where business_id=bid and active on conflict do nothing;
 insert into working_hours(staff_id,weekday,start_time,end_time) select sid,d,'09:00','18:00' from generate_series(1,5)d;
 return sid;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_complete_onboarding()
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare bid uuid; sc int; svc int; wh int;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=(select auth.uid()) limit 1;
 if bid is null then raise exception 'NO_BUSINESS'; end if;
 select count(*) into sc from staff where business_id=bid and active;
 select count(*) into svc from services where business_id=bid and active;
 select count(*) into wh from working_hours w join staff st on st.id=w.staff_id where st.business_id=bid;
 if sc<1 or svc<1 or wh<1 then raise exception 'ONBOARDING_INCOMPLETE'; end if;
 update businesses set onboarding_complete=true where id=bid;
 return true;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_create_booking(p_business_id uuid, p_staff_id uuid, p_service_id uuid, p_starts_at timestamp with time zone, p_customer_name text)
 RETURNS uuid
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare dur int; cid uuid; outid uuid; begin perform kavelyq_private.require_business_owner();
 if not kavelyq_private.is_business_member(p_business_id) or not kavelyq_private.business_accepts_live_operations(p_business_id) then raise exception 'PLAN_INACTIVE'; end if;
 if p_starts_at<=now() then raise exception 'PAST_BOOKING'; end if;
 if not exists(select 1 from staff where id=p_staff_id and business_id=p_business_id and active) or not exists(select 1 from services where id=p_service_id and business_id=p_business_id and active) or not exists(select 1 from staff_services where staff_id=p_staff_id and service_id=p_service_id) then raise exception 'INVALID_BOOKING_SELECTION'; end if;
 perform kavelyq_private.assert_booking_slot(p_business_id,p_staff_id,p_service_id,p_starts_at,null);
 select duration_minutes into dur from services where id=p_service_id;
 insert into customers(business_id,display_name) values(p_business_id,left(coalesce(nullif(trim(p_customer_name),''),'Guest'),120)) returning id into cid;
 insert into bookings(business_id,customer_id,staff_id,service_id,starts_at,ends_at,status,source) values(p_business_id,cid,p_staff_id,p_service_id,p_starts_at,p_starts_at+make_interval(mins=>dur),'confirmed','owner') returning id into outid; return outid; end $function$
;
CREATE OR REPLACE FUNCTION public.owner_create_recovery_offer(p_outreach_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions'
AS $function$
declare o public.operator_outreach; raw text;
begin perform kavelyq_private.require_business_owner();
 select * into o from public.operator_outreach where id=p_outreach_id;
 if o.id is null or not kavelyq_private.is_business_member(o.business_id) then raise exception 'FORBIDDEN'; end if;
 raw:=encode(gen_random_bytes(32),'hex');
 insert into public.recovery_offers(business_id,outreach_id,token_hash) values(o.business_id,o.id,encode(digest(raw,'sha256'),'hex'));
 return raw;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_operator_prepare_outreach(p_decision_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare d public.operator_decisions; bid uuid; created_count int:=0;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from public.business_members where user_id=(select auth.uid()) limit 1;
 select * into d from public.operator_decisions where id=p_decision_id and business_id=bid;
 if d.id is null then raise exception 'DECISION_NOT_FOUND'; end if;
 insert into public.operator_outreach(business_id,decision_id,customer_id,channel,status,message)
 select bid,d.id,c.id,
   case when nullif(trim(c.email),'') is not null then 'email' else 'sms' end,
   'prepared',
   'A suitable appointment may be available again. Open the booking page to choose a time.'
 from public.customers c
 where c.business_id=bid and (nullif(trim(c.email),'') is not null or nullif(trim(c.phone),'') is not null)
   and not exists(select 1 from public.operator_outreach o where o.decision_id=d.id and o.customer_id=c.id)
 order by c.created_at desc limit 12;
 get diagnostics created_count=row_count;
 update public.operator_decisions set result=result||jsonb_build_object('outreach_prepared',created_count,'external_messages_sent',false) where id=d.id;
 return jsonb_build_object('prepared',created_count,'external_messages_sent',false);
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_remove_time_off(p_time_off_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid; begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE'; end if;
 delete from time_off t using staff s where t.id=p_time_off_id and t.staff_id=s.id and s.business_id=bid; return found; end $function$
;
CREATE OR REPLACE FUNCTION public.owner_reschedule_booking(p_booking_id uuid, p_starts_at timestamp with time zone)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare b bookings; dur int; begin perform kavelyq_private.require_business_owner();
 select * into b from bookings where id=p_booking_id;
 if b.id is null or not kavelyq_private.is_business_member(b.business_id) then raise exception 'FORBIDDEN'; end if;
 if not kavelyq_private.business_accepts_live_operations(b.business_id) then raise exception 'PLAN_INACTIVE'; end if;
 if p_starts_at<=now() then raise exception 'PAST_BOOKING'; end if;
 perform kavelyq_private.assert_booking_slot(b.business_id,b.staff_id,b.service_id,p_starts_at,b.id);
 select duration_minutes into dur from services where id=b.service_id;
 update bookings set starts_at=p_starts_at,ends_at=p_starts_at+make_interval(mins=>dur) where id=b.id and status in('pending','confirmed'); return found; end $function$
;
CREATE OR REPLACE FUNCTION public.owner_save_branding(p_config jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare bid uuid;cfg jsonb;k text;v text;
begin perform kavelyq_private.require_business_owner();
 select business_id into bid from public.business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if p_config is null or jsonb_typeof(p_config)<>'object' then raise exception 'INVALID_BRANDING';end if;
 cfg:=jsonb_build_object('accent',coalesce(p_config->>'accent','#c8e986'),'font',coalesce(p_config->>'font','system'),'logo_url',coalesce(p_config->>'logo_url',''),'hero_url',coalesce(p_config->>'hero_url',''),'description',coalesce(p_config->>'description',''));
 if cfg->>'accent' !~ '^#[0-9a-fA-F]{6}$' or cfg->>'font' not in('system','georgia','arial') or length(cfg->>'description')>1000 then raise exception 'INVALID_BRANDING';end if;
 foreach k in array array['logo_url','hero_url'] loop v:=cfg->>k;if length(v)>2048 or (v<>'' and v !~ '^https://[^[:space:]]+$') then raise exception 'INVALID_IMAGE_URL';end if;end loop;
 insert into public.business_branding(business_id,config) values(bid,cfg) on conflict(business_id) do update set config=excluded.config,updated_at=now();return cfg;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_update_booking_status(p_booking_id uuid, p_status text)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$declare bid uuid;cid uuid;begin perform kavelyq_private.require_business_owner(); if p_status not in('confirmed','completed','cancelled','no_show') then raise exception 'INVALID_STATUS';end if;select business_id,customer_id into bid,cid from bookings where id=p_booking_id;if bid is null or not kavelyq_private.is_business_member(bid) then raise exception 'FORBIDDEN';end if;if not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE';end if;update bookings set status=p_status,completed_at=case when p_status='completed' then now() else completed_at end,cancelled_at=case when p_status='cancelled' then now() else cancelled_at end where id=p_booking_id;if p_status='completed' and cid is not null then perform kavelyq_private.refresh_customer_crm(cid);end if;return found;end$function$
;
CREATE OR REPLACE FUNCTION public.owner_update_staff(p_staff_id uuid, p_name text, p_active boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare bid uuid; begin perform kavelyq_private.require_business_owner();
 select business_id into bid from business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'PLAN_INACTIVE'; end if;
 if length(trim(coalesce(p_name,'')))<2 then raise exception 'INVALID_STAFF'; end if;
 update staff set display_name=left(trim(p_name),120),active=p_active where id=p_staff_id and business_id=bid;
 return found; end $function$
;
CREATE OR REPLACE FUNCTION public.owner_dashboard()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
with mb as (
 select b.id,b.name,b.timezone,b.currency,b.public_slug,bm.role
 from public.business_members bm join public.businesses b on b.id=bm.business_id
 where bm.user_id=(select auth.uid()) and bm.role in('owner','manager') limit 1
)
select case when not exists(select 1 from mb) then null else jsonb_build_object(
 'business',(select jsonb_build_object('id',id,'name',name,'timezone',timezone,'currency',currency,'public_slug',public_slug,'role',role) from mb),
 'counts',jsonb_build_object(
  'bookings',(select count(*) from public.bookings bk join mb on mb.id=bk.business_id),
  'customers',(select count(*) from public.customers c join mb on mb.id=c.business_id),
  'staff',(select count(*) from public.staff s join mb on mb.id=s.business_id where s.active),
  'services',(select count(*) from public.services sv join mb on mb.id=sv.business_id where sv.active)
 ),
 'staff',coalesce((select jsonb_agg(jsonb_build_object('id',s.id,'display_name',s.display_name) order by s.display_name) from public.staff s join mb on mb.id=s.business_id where s.active),'[]'::jsonb),
 'services',coalesce((select jsonb_agg(jsonb_build_object('id',sv.id,'name',sv.name,'duration_minutes',sv.duration_minutes,'price_cents',sv.price_cents) order by sv.name) from public.services sv join mb on mb.id=sv.business_id where sv.active),'[]'::jsonb),
 'bookings',coalesce((select jsonb_agg(x order by (x->>'starts_at')::timestamptz) from (
   select jsonb_build_object('id',bk.id,'starts_at',bk.starts_at,'ends_at',bk.ends_at,'status',bk.status,'source',bk.source,'customer',c.display_name,'staff',s.display_name,'service',sv.name,'price_cents',bk.booked_price_cents) x
   from public.bookings bk join mb on mb.id=bk.business_id left join public.customers c on c.id=bk.customer_id
   join public.staff s on s.id=bk.staff_id join public.services sv on sv.id=bk.service_id
   where bk.starts_at>=date_trunc('day',now())-interval '1 day' order by bk.starts_at limit 50
 ) q),'[]'::jsonb),
 'customers',coalesce((select jsonb_agg(jsonb_build_object('id',c.id,'display_name',c.display_name,'created_at',c.created_at) order by c.created_at desc) from public.customers c join mb on mb.id=c.business_id),'[]'::jsonb)
) end $function$
;
CREATE OR REPLACE FUNCTION public.withdraw_public_waitlist(p_token uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$begin update public.waitlist_requests set status='withdrawn',contact_permission=false where manage_token=p_token and status='waiting';return found;end $function$
;
CREATE OR REPLACE FUNCTION public.join_public_waitlist(p_business_slug text, p_service_slug text, p_staff_slug text, p_name text, p_email text, p_phone text, p_date_from date, p_date_to date, p_contact_permission boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare bid uuid;sid uuid;vid uuid;rid uuid;tok uuid;tz text;ch text;
begin
 select id,timezone into bid,tz from public.businesses where public_slug=p_business_slug;
 if bid is null or not kavelyq_private.business_accepts_live_operations(bid) then raise exception 'BOOKING_UNAVAILABLE';end if;
 if not coalesce(p_contact_permission,false) or length(trim(coalesce(p_name,''))) not between 2 and 120 or (nullif(trim(p_email),'') is null and nullif(trim(p_phone),'') is null) then raise exception 'CONTACT_AND_PERMISSION_REQUIRED';end if;
 if (nullif(p_email,'') is not null and (length(p_email)>254 or p_email !~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$')) or (nullif(p_phone,'') is not null and p_phone !~ '^[+]?[0-9 ()-]{6,40}$') then raise exception 'INVALID_CONTACT';end if;
 if p_date_from is null or p_date_to is null or p_date_from<(now() at time zone tz)::date or p_date_to<p_date_from or p_date_to-p_date_from>30 then raise exception 'INVALID_DATE_RANGE';end if;
 select id into vid from public.services where business_id=bid and public_slug=p_service_slug and active;
 if p_staff_slug is not null then select id into sid from public.staff where business_id=bid and public_slug=p_staff_slug and active;if sid is null then raise exception 'INVALID_STAFF';end if;end if;
 if vid is null or (sid is not null and not exists(select 1 from public.staff_services where staff_id=sid and service_id=vid)) then raise exception 'INVALID_SERVICE';end if;
 ch:=md5(lower(trim(coalesce(p_email,'')))||'|'||regexp_replace(coalesce(p_phone,''),'[^0-9]','','g'));perform pg_advisory_xact_lock(hashtextextended('waitlist:'||bid::text||ch,0));
 if (select count(*) from public.public_booking_rate_limits where business_id=bid and contact_hash=ch and created_at>now()-interval '10 minutes')>=3 then raise exception 'RATE_LIMITED';end if;
 insert into public.public_booking_rate_limits(business_id,contact_hash) values(bid,ch);
 insert into public.waitlist_requests(business_id,service_id,staff_id,display_name,email,phone,date_from,date_to,contact_permission) values(bid,vid,sid,trim(p_name),nullif(trim(p_email),''),nullif(trim(p_phone),''),p_date_from,p_date_to,true) returning id,manage_token into rid,tok;
 return jsonb_build_object('id',rid,'manage_token',tok,'status','waiting');
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_prepare_business_action(p_kind text, p_subject_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$declare bid uuid:=kavelyq_private.require_business_owner();r jsonb;begin
 if p_kind in('reactivation','rebooking') then if not exists(select 1 from public.customers where id=p_subject_id and business_id=bid and marketing_consent and deleted_at is null) then raise exception 'CONSENT_REQUIRED';end if;
 elsif p_kind='waitlist' then if not exists(select 1 from public.waitlist_requests where id=p_subject_id and business_id=bid and status='waiting' and contact_permission and date_to>=current_date) then raise exception 'REQUEST_UNAVAILABLE';end if;
 else raise exception 'INVALID_ACTION';end if;
 insert into public.business_action_drafts(business_id,kind,subject_id,created_by) values(bid,p_kind,p_subject_id,auth.uid()) on conflict(business_id,kind,subject_id) do nothing;
 select to_jsonb(a) into r from public.business_action_drafts a where business_id=bid and kind=p_kind and subject_id=p_subject_id;return r;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_intelligence_snapshot()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO ''
AS $function$
declare bid uuid:=kavelyq_private.require_business_owner();tz text;today date;start_day date;end_day date;result jsonb;
begin
 select timezone into tz from public.businesses where id=bid;today:=(now() at time zone tz)::date;start_day:=date_trunc('month',today)::date;end_day:=(start_day+interval '1 month')::date;
 with totals as(select coalesce(sum(booked_price_cents) filter(where status='completed'),0) completed,coalesce(sum(booked_price_cents) filter(where status='confirmed' and starts_at>=now()),0) booked,count(*) filter(where status='completed') samples from public.bookings where business_id=bid and starts_at>=(start_day::timestamp at time zone tz) and starts_at<(end_day::timestamp at time zone tz))
 select jsonb_build_object('forecast',jsonb_build_object('completed_value_cents',completed,'confirmed_future_value_cents',booked,'estimate_cents',greatest(completed+booked,round(completed::numeric/greatest(1,today-start_day+1)*(end_day-start_day))),'completed_samples',samples,'method','Rules-based monthly pace; completed service value plus recorded bookings. Assumes recent pace continues. Not collected payments; cancellations and refunds may reduce value.','confidence',case when samples<20 then 'Low: limited completed history' else 'Uncalibrated: heuristic estimate' end),
 'overdue_customers',coalesce((select jsonb_agg(jsonb_build_object('id',id,'name',display_name,'due_at',next_due_at,'consent',marketing_consent)) from public.customers where business_id=bid and deleted_at is null and next_due_at<now()),'[]'::jsonb),
 'waitlist',coalesce((select jsonb_agg(jsonb_build_object('id',w.id,'name',w.display_name,'service',s.name,'from',w.date_from,'to',w.date_to,'contact_permission',w.contact_permission,'cancelled_slot_matches',(select count(*) from public.bookings b where b.business_id=bid and b.service_id=w.service_id and b.status='cancelled' and b.starts_at>now() and (b.starts_at at time zone tz)::date between w.date_from and w.date_to and (w.staff_id is null or b.staff_id=w.staff_id)))) from public.waitlist_requests w join public.services s on s.id=w.service_id where w.business_id=bid and w.status='waiting' and w.date_to>=today),'[]'::jsonb),
 'drafts',coalesce((select jsonb_agg(to_jsonb(a)) from public.business_action_drafts a where a.business_id=bid),'[]'::jsonb),'delivery_enabled',false) into result from totals;
 return result;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_approve_business_action(p_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare bid uuid:=kavelyq_private.require_business_owner();a public.business_action_drafts;r jsonb;
begin
 select * into a from public.business_action_drafts where id=p_id and business_id=bid and status='prepared' for update;
 if a.id is null then raise exception 'ACTION_UNAVAILABLE';end if;
 if a.kind in('reactivation','rebooking') then
  perform 1 from public.customers where id=a.subject_id and business_id=bid and marketing_consent and deleted_at is null for share;
  if not found then raise exception 'CONSENT_REQUIRED';end if;
 else
  perform 1 from public.waitlist_requests where id=a.subject_id and business_id=bid and status='waiting' and contact_permission and date_to>=current_date for share;
  if not found then raise exception 'REQUEST_UNAVAILABLE';end if;
 end if;
 update public.business_action_drafts set status='approved',approved_by=auth.uid(),approved_at=now() where id=p_id and business_id=bid returning to_jsonb(business_action_drafts.*) into r;
 return r||jsonb_build_object('delivery_enabled',false);
end $function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.can_manage_business(p_business_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
select exists(select 1 from public.business_members where business_id=p_business_id and user_id=(select auth.uid()) and role in('owner','manager'))
$function$
;
CREATE OR REPLACE FUNCTION public.refresh_rescheduled_notifications()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_export_customer(p_customer_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
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
end $function$
;
CREATE OR REPLACE FUNCTION public.claim_due_email_notifications(p_limit integer DEFAULT 20)
 RETURNS SETOF notification_queue
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
if coalesce(current_setting('request.jwt.claim.role',true),'')<>'service_role' and coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'SERVICE_ROLE_REQUIRED';end if;
return query with due as(
select q.id from public.notification_queue q
join kavelyq_private.communication_delivery cfg on cfg.business_id=q.business_id and cfg.transactional_enabled and cfg.provider_verified
where q.template in('booking_confirmation','booking_reminder','booking_cancelled') and q.channel='email' and q.destination is not null and q.scheduled_for<=now() and q.scheduled_for>now()-interval '24 hours' and q.attempt_count<5
and not exists(select 1 from kavelyq_private.demo_businesses d where d.business_id=q.business_id)
and (q.status='pending' or (q.status='failed' and coalesce(q.claimed_at,'epoch'::timestamptz)<now()-interval '10 minutes') or (q.status='processing' and q.claimed_at<now()-interval '15 minutes'))
and (q.customer_id is null or exists(select 1 from public.customers c where c.id=q.customer_id and c.deleted_at is null and c.email=q.destination))
and (q.booking_id is null or exists(select 1 from public.bookings b where b.id=q.booking_id and ((q.template='booking_cancelled' and b.status='cancelled') or (q.template in('booking_confirmation','booking_reminder') and b.status='confirmed' and b.starts_at>now()))))
order by q.scheduled_for for update of q skip locked limit greatest(1,least(coalesce(p_limit,20),100))
),upd as(update public.notification_queue q set status='processing',claimed_at=now(),attempt_count=attempt_count+1 from due where q.id=due.id returning q.*)select * from upd;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_delete_customer_data(p_customer_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end $function$
;
CREATE OR REPLACE FUNCTION kavelyq_private.validate_time_off()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
perform pg_advisory_xact_lock(hashtextextended('kavelyq-booking-staff:'||new.staff_id::text,0));
if new.starts_at is null or new.ends_at is null or not isfinite(new.starts_at) or not isfinite(new.ends_at) or new.ends_at<=new.starts_at then raise exception 'INVALID_TIME_OFF';end if;
if exists(select 1 from public.bookings b where b.staff_id=new.staff_id and b.status in('pending','confirmed') and tstzrange(b.starts_at,b.ends_at,'[)')&&tstzrange(new.starts_at,new.ends_at,'[)')) then raise exception 'TIME_OFF_CONFLICTS_WITH_BOOKING';end if;
if exists(select 1 from public.time_off t where t.staff_id=new.staff_id and t.id<>new.id and tstzrange(t.starts_at,t.ends_at,'[)')&&tstzrange(new.starts_at,new.ends_at,'[)')) then raise exception 'TIME_OFF_ALREADY_BLOCKED';end if;
return new;
end $function$
;
CREATE OR REPLACE FUNCTION public.owner_add_time_off_local(p_staff_id uuid, p_starts_local timestamp without time zone, p_ends_local timestamp without time zone, p_reason text)
 RETURNS uuid
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare bid uuid:=kavelyq_private.require_business_owner();tz text;s timestamptz;e timestamptz;
begin
select b.timezone into tz from public.businesses b join public.staff st on st.business_id=b.id where b.id=bid and st.id=p_staff_id;
if tz is null then raise exception 'FORBIDDEN';end if;
if p_starts_local is null or p_ends_local is null then raise exception 'INVALID_TIME_OFF';end if;
s:=p_starts_local at time zone tz;e:=p_ends_local at time zone tz;
if s at time zone tz<>p_starts_local or e at time zone tz<>p_ends_local then raise exception 'INVALID_LOCAL_TIME';end if;
return public.owner_add_time_off(p_staff_id,s,e,p_reason);
end $function$
;
alter table "public"."working_hours" add constraint "working_hours_pkey" PRIMARY KEY (id);
alter table "public"."time_off" add constraint "time_off_check" CHECK ((starts_at < ends_at));
alter table "public"."time_off" add constraint "time_off_pkey" PRIMARY KEY (id);
alter table "public"."customers" add constraint "customers_pkey" PRIMARY KEY (id);
alter table "public"."bookings" add constraint "bookings_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'completed'::text, 'cancelled'::text, 'no_show'::text])));
alter table "public"."businesses" add constraint "businesses_pkey" PRIMARY KEY (id);
alter table "public"."business_members" add constraint "business_members_role_check" CHECK ((role = ANY (ARRAY['owner'::text, 'manager'::text, 'staff'::text])));
alter table "public"."business_members" add constraint "business_members_pkey" PRIMARY KEY (business_id, user_id);
alter table "public"."staff" add constraint "staff_pkey" PRIMARY KEY (id);
alter table "public"."services" add constraint "services_duration_minutes_check" CHECK (((duration_minutes >= 5) AND (duration_minutes <= 720)));
alter table "public"."services" add constraint "services_price_cents_check" CHECK ((price_cents >= 0));
alter table "public"."services" add constraint "services_pkey" PRIMARY KEY (id);
alter table "public"."staff_services" add constraint "staff_services_pkey" PRIMARY KEY (staff_id, service_id);
alter table "public"."working_hours" add constraint "working_hours_weekday_check" CHECK (((weekday >= 0) AND (weekday <= 6)));
alter table "public"."working_hours" add constraint "working_hours_check" CHECK ((start_time < end_time));
alter table "public"."bookings" add constraint "bookings_source_check" CHECK ((source = ANY (ARRAY['guest'::text, 'owner'::text, 'operator'::text, 'import'::text])));
alter table "public"."bookings" add constraint "bookings_check" CHECK ((starts_at < ends_at));
alter table "public"."bookings" add constraint "bookings_pkey" PRIMARY KEY (id);
alter table "public"."cut_memory" add constraint "cut_memory_pkey" PRIMARY KEY (id);
alter table "public"."cut_memory" add constraint "cut_memory_business_id_customer_id_key" UNIQUE (business_id, customer_id);
alter table "public"."operator_decisions" add constraint "operator_decisions_pkey" PRIMARY KEY (id);
alter table "public"."bookings" add constraint "bookings_no_staff_overlap" EXCLUDE USING gist (staff_id WITH =, tstzrange(starts_at, ends_at, '[)'::text) WITH &&) WHERE ((status = ANY (ARRAY['pending'::text, 'confirmed'::text])));
alter table "public"."businesses" add constraint "businesses_public_slug_key" UNIQUE (public_slug);
alter table "public"."operator_outreach" add constraint "operator_outreach_channel_check" CHECK ((channel = ANY (ARRAY['email'::text, 'sms'::text, 'whatsapp'::text])));
alter table "public"."operator_outreach" add constraint "operator_outreach_status_check" CHECK ((status = ANY (ARRAY['prepared'::text, 'sent'::text, 'failed'::text, 'converted'::text])));
alter table "public"."operator_outreach" add constraint "operator_outreach_pkey" PRIMARY KEY (id);
alter table "public"."customers" add constraint "customers_crm_status_check" CHECK ((crm_status = ANY (ARRAY['active'::text, 'due'::text, 'overdue'::text, 'inactive'::text])));
alter table "public"."recovery_offers" add constraint "recovery_offers_pkey" PRIMARY KEY (id);
alter table "public"."recovery_offers" add constraint "recovery_offers_token_hash_key" UNIQUE (token_hash);
alter table "public"."businesses" add constraint "businesses_subscription_status_check" CHECK ((subscription_status = ANY (ARRAY['trialing'::text, 'active'::text, 'past_due'::text, 'canceled'::text, 'expired'::text])));
alter table "public"."businesses" add constraint "businesses_billing_interval_check" CHECK ((billing_interval = ANY (ARRAY['monthly'::text, 'annual'::text])));
alter table "public"."businesses" add constraint "businesses_cancel_window_check" CHECK (((cancellation_window_hours >= 0) AND (cancellation_window_hours <= 336)));
alter table "public"."businesses" add constraint "businesses_deposit_percent_check" CHECK (((deposit_percent >= 0) AND (deposit_percent <= 100)));
alter table "public"."notification_queue" add constraint "notification_queue_channel_check" CHECK ((channel = ANY (ARRAY['email'::text, 'sms'::text])));
alter table "public"."notification_queue" add constraint "notification_queue_template_check" CHECK ((template = ANY (ARRAY['booking_confirmation'::text, 'booking_reminder'::text, 'booking_cancelled'::text, 'rebook_invite'::text])));
alter table "public"."notification_queue" add constraint "notification_queue_pkey" PRIMARY KEY (id);
alter table "public"."public_booking_rate_limits" add constraint "public_booking_rate_limits_pkey" PRIMARY KEY (id);
alter table "public"."bookings" add constraint "booking_price_nonnegative" CHECK ((booked_price_cents >= 0));
alter table "kavelyq_private"."demo_businesses" add constraint "demo_businesses_pkey" PRIMARY KEY (business_id);
alter table "public"."business_branding" add constraint "business_branding_pkey" PRIMARY KEY (business_id);
alter table "public"."business_audit_log" add constraint "business_audit_log_operation_check" CHECK ((operation = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text])));
alter table "public"."business_audit_log" add constraint "business_audit_log_pkey" PRIMARY KEY (id);
alter table "public"."businesses" add constraint "businesses_business_type_valid" CHECK ((business_type = ANY (ARRAY['barber'::text, 'beauty'::text, 'tattoo'::text, 'nails'::text, 'wellness'::text, 'other'::text])));
alter table "public"."waitlist_requests" add constraint "waitlist_requests_display_name_check" CHECK (((length(display_name) >= 2) AND (length(display_name) <= 120)));
alter table "public"."waitlist_requests" add constraint "waitlist_requests_status_check" CHECK ((status = ANY (ARRAY['waiting'::text, 'withdrawn'::text, 'fulfilled'::text])));
alter table "public"."waitlist_requests" add constraint "waitlist_requests_check" CHECK (((date_to >= date_from) AND ((date_to - date_from) <= 30)));
alter table "public"."waitlist_requests" add constraint "waitlist_requests_pkey" PRIMARY KEY (id);
alter table "public"."waitlist_requests" add constraint "waitlist_requests_manage_token_key" UNIQUE (manage_token);
alter table "public"."business_action_drafts" add constraint "business_action_drafts_kind_check" CHECK ((kind = ANY (ARRAY['reactivation'::text, 'rebooking'::text, 'waitlist'::text])));
alter table "public"."business_action_drafts" add constraint "business_action_drafts_status_check" CHECK ((status = ANY (ARRAY['prepared'::text, 'approved'::text, 'cancelled'::text])));
alter table "public"."business_action_drafts" add constraint "business_action_drafts_pkey" PRIMARY KEY (id);
alter table "public"."business_action_drafts" add constraint "business_action_drafts_business_id_kind_subject_id_key" UNIQUE (business_id, kind, subject_id);
alter table "kavelyq_private"."communication_delivery" add constraint "communication_delivery_pkey" PRIMARY KEY (business_id);
alter table "public"."notification_queue" add constraint "notification_queue_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'sent'::text, 'failed'::text, 'cancelled'::text])));
alter table "public"."working_hours" add constraint "working_hours_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE;
alter table "public"."time_off" add constraint "time_off_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE;
alter table "public"."customers" add constraint "customers_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."business_members" add constraint "business_members_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."business_members" add constraint "business_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
alter table "public"."staff" add constraint "staff_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."services" add constraint "services_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."staff_services" add constraint "staff_services_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE;
alter table "public"."staff_services" add constraint "staff_services_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;
alter table "public"."bookings" add constraint "bookings_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."bookings" add constraint "bookings_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL;
alter table "public"."bookings" add constraint "bookings_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id);
alter table "public"."bookings" add constraint "bookings_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id);
alter table "public"."cut_memory" add constraint "cut_memory_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."cut_memory" add constraint "cut_memory_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;
alter table "public"."cut_memory" add constraint "cut_memory_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE SET NULL;
alter table "public"."operator_decisions" add constraint "operator_decisions_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."operator_outreach" add constraint "operator_outreach_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."operator_outreach" add constraint "operator_outreach_decision_id_fkey" FOREIGN KEY (decision_id) REFERENCES operator_decisions(id) ON DELETE CASCADE;
alter table "public"."operator_outreach" add constraint "operator_outreach_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL;
alter table "public"."bookings" add constraint "bookings_operator_decision_id_fkey" FOREIGN KEY (operator_decision_id) REFERENCES operator_decisions(id) ON DELETE SET NULL;
alter table "public"."bookings" add constraint "bookings_operator_outreach_id_fkey" FOREIGN KEY (operator_outreach_id) REFERENCES operator_outreach(id) ON DELETE SET NULL;
alter table "public"."customers" add constraint "customers_preferred_staff_id_fkey" FOREIGN KEY (preferred_staff_id) REFERENCES staff(id) ON DELETE SET NULL;
alter table "public"."customers" add constraint "customers_preferred_service_id_fkey" FOREIGN KEY (preferred_service_id) REFERENCES services(id) ON DELETE SET NULL;
alter table "public"."cut_memory" add constraint "cut_memory_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL;
alter table "public"."recovery_offers" add constraint "recovery_offers_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."recovery_offers" add constraint "recovery_offers_outreach_id_fkey" FOREIGN KEY (outreach_id) REFERENCES operator_outreach(id) ON DELETE CASCADE;
alter table "public"."notification_queue" add constraint "notification_queue_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."notification_queue" add constraint "notification_queue_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE;
alter table "public"."notification_queue" add constraint "notification_queue_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL;
alter table "public"."public_booking_rate_limits" add constraint "public_booking_rate_limits_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "kavelyq_private"."demo_businesses" add constraint "demo_businesses_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;
alter table "public"."business_branding" add constraint "business_branding_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id);
alter table "public"."business_audit_log" add constraint "business_audit_log_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id);
alter table "public"."waitlist_requests" add constraint "waitlist_requests_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id);
alter table "public"."waitlist_requests" add constraint "waitlist_requests_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id);
alter table "public"."waitlist_requests" add constraint "waitlist_requests_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id);
alter table "public"."business_action_drafts" add constraint "business_action_drafts_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id);
alter table "kavelyq_private"."communication_delivery" add constraint "communication_delivery_business_id_fkey" FOREIGN KEY (business_id) REFERENCES businesses(id);
CREATE INDEX operator_outreach_decision_idx ON public.operator_outreach USING btree (decision_id);
CREATE INDEX notification_queue_due_idx ON public.notification_queue USING btree (status, scheduled_for);
CREATE INDEX operator_decisions_business_idx ON public.operator_decisions USING btree (business_id);
CREATE INDEX operator_outreach_business_idx ON public.operator_outreach USING btree (business_id);
CREATE UNIQUE INDEX bookings_manage_token_uidx ON public.bookings USING btree (manage_token);
CREATE INDEX bookings_operator_decision_idx ON public.bookings USING btree (operator_decision_id);
CREATE INDEX bookings_service_idx ON public.bookings USING btree (service_id);
CREATE INDEX staff_business_idx ON public.staff USING btree (business_id);
CREATE INDEX recovery_offers_outreach_idx ON public.recovery_offers USING btree (outreach_id);
CREATE INDEX bookings_staff_time_idx ON public.bookings USING btree (staff_id, starts_at, ends_at) WHERE (status = ANY (ARRAY['pending'::text, 'confirmed'::text]));
CREATE INDEX time_off_staff_idx ON public.time_off USING btree (staff_id);
CREATE INDEX customers_business_idx ON public.customers USING btree (business_id);
CREATE INDEX business_members_user_idx ON public.business_members USING btree (user_id);
CREATE INDEX working_hours_staff_idx ON public.working_hours USING btree (staff_id);
CREATE INDEX cut_memory_customer_idx ON public.cut_memory USING btree (customer_id);
CREATE INDEX business_audit_log_business_time ON public.business_audit_log USING btree (business_id, occurred_at DESC);
CREATE INDEX waitlist_business_state ON public.waitlist_requests USING btree (business_id, status, date_to);
CREATE INDEX public_booking_rate_limits_lookup ON public.public_booking_rate_limits USING btree (business_id, contact_hash, created_at DESC);
CREATE INDEX bookings_operator_outreach_idx ON public.bookings USING btree (operator_outreach_id);
CREATE INDEX operator_outreach_customer_idx ON public.operator_outreach USING btree (customer_id);
CREATE INDEX recovery_offers_business_idx ON public.recovery_offers USING btree (business_id);
CREATE INDEX notification_queue_business_idx ON public.notification_queue USING btree (business_id);
CREATE INDEX notification_queue_customer_idx ON public.notification_queue USING btree (customer_id);
CREATE INDEX bookings_business_time_idx ON public.bookings USING btree (business_id, starts_at);
CREATE INDEX cut_memory_staff_idx ON public.cut_memory USING btree (staff_id);
CREATE INDEX customers_preferred_staff_idx ON public.customers USING btree (preferred_staff_id);
CREATE INDEX services_business_idx ON public.services USING btree (business_id);
CREATE INDEX staff_services_service_idx ON public.staff_services USING btree (service_id);
CREATE INDEX bookings_customer_idx ON public.bookings USING btree (customer_id);
CREATE INDEX cut_memory_service_idx ON public.cut_memory USING btree (service_id);
CREATE INDEX customers_preferred_service_idx ON public.customers USING btree (preferred_service_id);
CREATE INDEX notification_queue_booking_idx ON public.notification_queue USING btree (booking_id);
CREATE TRIGGER trg_queue_booking_notifications AFTER INSERT OR UPDATE OF status ON public.bookings FOR EACH ROW EXECUTE FUNCTION queue_booking_notifications();
CREATE TRIGGER capture_booking_price BEFORE INSERT OR UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION kavelyq_private.capture_booking_price();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.businesses FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.staff FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.services FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.working_hours FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.time_off FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.staff_services FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER record_business_audit AFTER INSERT OR DELETE OR UPDATE ON public.business_branding FOR EACH ROW EXECUTE FUNCTION kavelyq_private.record_business_audit();
CREATE TRIGGER refresh_rescheduled_notifications AFTER UPDATE OF starts_at ON public.bookings FOR EACH ROW EXECUTE FUNCTION refresh_rescheduled_notifications();
CREATE TRIGGER validate_time_off BEFORE INSERT OR UPDATE ON public.time_off FOR EACH ROW EXECUTE FUNCTION kavelyq_private.validate_time_off();
alter table "kavelyq_private"."communication_delivery" enable row level security;
alter table "public"."business_members" enable row level security;
alter table "public"."staff_services" enable row level security;
alter table "public"."working_hours" enable row level security;
alter table "public"."recovery_offers" enable row level security;
alter table "public"."bookings" enable row level security;
alter table "public"."businesses" enable row level security;
alter table "public"."operator_outreach" enable row level security;
alter table "public"."cut_memory" enable row level security;
alter table "public"."notification_queue" enable row level security;
alter table "kavelyq_private"."demo_businesses" enable row level security;
alter table "public"."public_booking_rate_limits" enable row level security;
alter table "public"."business_branding" enable row level security;
alter table "public"."customers" enable row level security;
alter table "public"."business_audit_log" enable row level security;
alter table "public"."waitlist_requests" enable row level security;
alter table "public"."business_action_drafts" enable row level security;
alter table "public"."time_off" enable row level security;
alter table "public"."staff" enable row level security;
alter table "public"."services" enable row level security;
alter table "public"."operator_decisions" enable row level security;
create policy "members read membership" on "public"."business_members" as PERMISSIVE for SELECT to "authenticated" using (((user_id = ( SELECT auth.uid() AS uid)) OR kavelyq_private.can_manage_business(business_id)));
create policy "members manage staff services" on "public"."staff_services" as PERMISSIVE for ALL to "authenticated" using ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = staff_services.staff_id) AND kavelyq_private.can_manage_business(s.business_id))))) with check ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = staff_services.staff_id) AND kavelyq_private.can_manage_business(s.business_id)))));
create policy "members manage working hours" on "public"."working_hours" as PERMISSIVE for ALL to "authenticated" using ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = working_hours.staff_id) AND kavelyq_private.can_manage_business(s.business_id))))) with check ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = working_hours.staff_id) AND kavelyq_private.can_manage_business(s.business_id)))));
create policy "recovery_offers_member_read" on "public"."recovery_offers" as PERMISSIVE for SELECT to "authenticated" using (kavelyq_private.can_manage_business(business_id));
create policy "members manage bookings" on "public"."bookings" as PERMISSIVE for ALL to "authenticated" using (kavelyq_private.can_manage_business(business_id)) with check (kavelyq_private.can_manage_business(business_id));
create policy "members read businesses" on "public"."businesses" as PERMISSIVE for SELECT to "authenticated" using (kavelyq_private.can_manage_business(id));
create policy "members manage operator outreach" on "public"."operator_outreach" as PERMISSIVE for ALL to "authenticated" using (kavelyq_private.can_manage_business(business_id)) with check (kavelyq_private.can_manage_business(business_id));
create policy "members manage cut memory" on "public"."cut_memory" as PERMISSIVE for ALL to "authenticated" using (kavelyq_private.can_manage_business(business_id)) with check (kavelyq_private.can_manage_business(business_id));
create policy "notification_queue_member_read" on "public"."notification_queue" as PERMISSIVE for SELECT to "authenticated" using (kavelyq_private.can_manage_business(business_id));
create policy "branding_owner" on "public"."business_branding" as PERMISSIVE for ALL to "authenticated" using ((EXISTS ( SELECT 1
   FROM business_members m
  WHERE ((m.business_id = business_branding.business_id) AND (m.user_id = ( SELECT auth.uid() AS uid)) AND (m.role = ANY (ARRAY['owner'::text, 'manager'::text])))))) with check ((EXISTS ( SELECT 1
   FROM business_members m
  WHERE ((m.business_id = business_branding.business_id) AND (m.user_id = ( SELECT auth.uid() AS uid)) AND (m.role = ANY (ARRAY['owner'::text, 'manager'::text]))))));
create policy "members manage customers" on "public"."customers" as PERMISSIVE for ALL to "authenticated" using (kavelyq_private.can_manage_business(business_id)) with check (kavelyq_private.can_manage_business(business_id));
create policy "audit_owner_read" on "public"."business_audit_log" as PERMISSIVE for SELECT to "authenticated" using ((EXISTS ( SELECT 1
   FROM business_members m
  WHERE ((m.business_id = business_audit_log.business_id) AND (m.user_id = ( SELECT auth.uid() AS uid)) AND (m.role = ANY (ARRAY['owner'::text, 'manager'::text]))))));
create policy "waitlist_owner_read" on "public"."waitlist_requests" as PERMISSIVE for SELECT to "authenticated" using ((EXISTS ( SELECT 1
   FROM business_members m
  WHERE ((m.business_id = waitlist_requests.business_id) AND (m.user_id = ( SELECT auth.uid() AS uid)) AND (m.role = ANY (ARRAY['owner'::text, 'manager'::text]))))));
create policy "action_owner" on "public"."business_action_drafts" as PERMISSIVE for ALL to "authenticated" using ((EXISTS ( SELECT 1
   FROM business_members m
  WHERE ((m.business_id = business_action_drafts.business_id) AND (m.user_id = ( SELECT auth.uid() AS uid)) AND (m.role = ANY (ARRAY['owner'::text, 'manager'::text])))))) with check ((EXISTS ( SELECT 1
   FROM business_members m
  WHERE ((m.business_id = business_action_drafts.business_id) AND (m.user_id = ( SELECT auth.uid() AS uid)) AND (m.role = ANY (ARRAY['owner'::text, 'manager'::text]))))));
create policy "members manage time off" on "public"."time_off" as PERMISSIVE for ALL to "authenticated" using ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = time_off.staff_id) AND kavelyq_private.can_manage_business(s.business_id))))) with check ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = time_off.staff_id) AND kavelyq_private.can_manage_business(s.business_id)))));
create policy "members manage staff" on "public"."staff" as PERMISSIVE for ALL to "authenticated" using (kavelyq_private.can_manage_business(business_id)) with check (kavelyq_private.can_manage_business(business_id));
create policy "members manage services" on "public"."services" as PERMISSIVE for ALL to "authenticated" using (kavelyq_private.can_manage_business(business_id)) with check (kavelyq_private.can_manage_business(business_id));
create policy "members manage decisions" on "public"."operator_decisions" as PERMISSIVE for ALL to "authenticated" using (kavelyq_private.can_manage_business(business_id)) with check (kavelyq_private.can_manage_business(business_id));
revoke all on all tables in schema public,kavelyq_private from public,anon,authenticated,service_role;
revoke all on all functions in schema public,kavelyq_private from public,anon,authenticated,service_role;
grant usage on schema public to anon,authenticated,service_role;
grant usage on schema kavelyq_private to authenticated,service_role;
grant usage on schema auth,extensions to anon,authenticated,service_role;
grant execute on all functions in schema auth to anon,authenticated,service_role;
grant INSERT on "public"."business_members" to "authenticated";
grant SELECT on "public"."business_members" to "authenticated";
grant UPDATE on "public"."business_members" to "authenticated";
grant DELETE on "public"."business_members" to "authenticated";
grant INSERT on "public"."business_members" to "service_role";
grant SELECT on "public"."business_members" to "service_role";
grant UPDATE on "public"."business_members" to "service_role";
grant DELETE on "public"."business_members" to "service_role";
grant TRUNCATE on "public"."business_members" to "service_role";
grant REFERENCES on "public"."business_members" to "service_role";
grant TRIGGER on "public"."business_members" to "service_role";
grant INSERT on "public"."staff_services" to "authenticated";
grant SELECT on "public"."staff_services" to "authenticated";
grant UPDATE on "public"."staff_services" to "authenticated";
grant DELETE on "public"."staff_services" to "authenticated";
grant INSERT on "public"."staff_services" to "service_role";
grant SELECT on "public"."staff_services" to "service_role";
grant UPDATE on "public"."staff_services" to "service_role";
grant DELETE on "public"."staff_services" to "service_role";
grant TRUNCATE on "public"."staff_services" to "service_role";
grant REFERENCES on "public"."staff_services" to "service_role";
grant TRIGGER on "public"."staff_services" to "service_role";
grant INSERT on "public"."working_hours" to "authenticated";
grant SELECT on "public"."working_hours" to "authenticated";
grant UPDATE on "public"."working_hours" to "authenticated";
grant DELETE on "public"."working_hours" to "authenticated";
grant INSERT on "public"."working_hours" to "service_role";
grant SELECT on "public"."working_hours" to "service_role";
grant UPDATE on "public"."working_hours" to "service_role";
grant DELETE on "public"."working_hours" to "service_role";
grant TRUNCATE on "public"."working_hours" to "service_role";
grant REFERENCES on "public"."working_hours" to "service_role";
grant TRIGGER on "public"."working_hours" to "service_role";
grant INSERT on "public"."recovery_offers" to "authenticated";
grant SELECT on "public"."recovery_offers" to "authenticated";
grant UPDATE on "public"."recovery_offers" to "authenticated";
grant DELETE on "public"."recovery_offers" to "authenticated";
grant INSERT on "public"."recovery_offers" to "service_role";
grant SELECT on "public"."recovery_offers" to "service_role";
grant UPDATE on "public"."recovery_offers" to "service_role";
grant DELETE on "public"."recovery_offers" to "service_role";
grant TRUNCATE on "public"."recovery_offers" to "service_role";
grant REFERENCES on "public"."recovery_offers" to "service_role";
grant TRIGGER on "public"."recovery_offers" to "service_role";
grant INSERT on "public"."bookings" to "authenticated";
grant SELECT on "public"."bookings" to "authenticated";
grant UPDATE on "public"."bookings" to "authenticated";
grant DELETE on "public"."bookings" to "authenticated";
grant INSERT on "public"."bookings" to "service_role";
grant SELECT on "public"."bookings" to "service_role";
grant UPDATE on "public"."bookings" to "service_role";
grant DELETE on "public"."bookings" to "service_role";
grant TRUNCATE on "public"."bookings" to "service_role";
grant REFERENCES on "public"."bookings" to "service_role";
grant TRIGGER on "public"."bookings" to "service_role";
grant INSERT on "public"."businesses" to "authenticated";
grant SELECT on "public"."businesses" to "authenticated";
grant UPDATE on "public"."businesses" to "authenticated";
grant DELETE on "public"."businesses" to "authenticated";
grant INSERT on "public"."businesses" to "service_role";
grant SELECT on "public"."businesses" to "service_role";
grant UPDATE on "public"."businesses" to "service_role";
grant DELETE on "public"."businesses" to "service_role";
grant TRUNCATE on "public"."businesses" to "service_role";
grant REFERENCES on "public"."businesses" to "service_role";
grant TRIGGER on "public"."businesses" to "service_role";
grant INSERT on "public"."operator_outreach" to "authenticated";
grant SELECT on "public"."operator_outreach" to "authenticated";
grant UPDATE on "public"."operator_outreach" to "authenticated";
grant DELETE on "public"."operator_outreach" to "authenticated";
grant INSERT on "public"."operator_outreach" to "service_role";
grant SELECT on "public"."operator_outreach" to "service_role";
grant UPDATE on "public"."operator_outreach" to "service_role";
grant DELETE on "public"."operator_outreach" to "service_role";
grant TRUNCATE on "public"."operator_outreach" to "service_role";
grant REFERENCES on "public"."operator_outreach" to "service_role";
grant TRIGGER on "public"."operator_outreach" to "service_role";
grant INSERT on "public"."cut_memory" to "authenticated";
grant SELECT on "public"."cut_memory" to "authenticated";
grant UPDATE on "public"."cut_memory" to "authenticated";
grant DELETE on "public"."cut_memory" to "authenticated";
grant INSERT on "public"."cut_memory" to "service_role";
grant SELECT on "public"."cut_memory" to "service_role";
grant UPDATE on "public"."cut_memory" to "service_role";
grant DELETE on "public"."cut_memory" to "service_role";
grant TRUNCATE on "public"."cut_memory" to "service_role";
grant REFERENCES on "public"."cut_memory" to "service_role";
grant TRIGGER on "public"."cut_memory" to "service_role";
grant INSERT on "public"."notification_queue" to "authenticated";
grant SELECT on "public"."notification_queue" to "authenticated";
grant UPDATE on "public"."notification_queue" to "authenticated";
grant DELETE on "public"."notification_queue" to "authenticated";
grant INSERT on "public"."notification_queue" to "service_role";
grant SELECT on "public"."notification_queue" to "service_role";
grant UPDATE on "public"."notification_queue" to "service_role";
grant DELETE on "public"."notification_queue" to "service_role";
grant TRUNCATE on "public"."notification_queue" to "service_role";
grant REFERENCES on "public"."notification_queue" to "service_role";
grant TRIGGER on "public"."notification_queue" to "service_role";
grant INSERT on "public"."public_booking_rate_limits" to "service_role";
grant SELECT on "public"."public_booking_rate_limits" to "service_role";
grant UPDATE on "public"."public_booking_rate_limits" to "service_role";
grant DELETE on "public"."public_booking_rate_limits" to "service_role";
grant TRUNCATE on "public"."public_booking_rate_limits" to "service_role";
grant REFERENCES on "public"."public_booking_rate_limits" to "service_role";
grant TRIGGER on "public"."public_booking_rate_limits" to "service_role";
grant INSERT on "public"."business_branding" to "authenticated";
grant SELECT on "public"."business_branding" to "authenticated";
grant UPDATE on "public"."business_branding" to "authenticated";
grant DELETE on "public"."business_branding" to "authenticated";
grant INSERT on "public"."business_branding" to "service_role";
grant SELECT on "public"."business_branding" to "service_role";
grant UPDATE on "public"."business_branding" to "service_role";
grant DELETE on "public"."business_branding" to "service_role";
grant TRUNCATE on "public"."business_branding" to "service_role";
grant REFERENCES on "public"."business_branding" to "service_role";
grant TRIGGER on "public"."business_branding" to "service_role";
grant INSERT on "public"."customers" to "authenticated";
grant SELECT on "public"."customers" to "authenticated";
grant UPDATE on "public"."customers" to "authenticated";
grant DELETE on "public"."customers" to "authenticated";
grant INSERT on "public"."customers" to "service_role";
grant SELECT on "public"."customers" to "service_role";
grant UPDATE on "public"."customers" to "service_role";
grant DELETE on "public"."customers" to "service_role";
grant TRUNCATE on "public"."customers" to "service_role";
grant REFERENCES on "public"."customers" to "service_role";
grant TRIGGER on "public"."customers" to "service_role";
grant INSERT on "public"."business_audit_log" to "service_role";
grant SELECT on "public"."business_audit_log" to "service_role";
grant UPDATE on "public"."business_audit_log" to "service_role";
grant DELETE on "public"."business_audit_log" to "service_role";
grant TRUNCATE on "public"."business_audit_log" to "service_role";
grant REFERENCES on "public"."business_audit_log" to "service_role";
grant TRIGGER on "public"."business_audit_log" to "service_role";
grant SELECT on "public"."business_audit_log" to "authenticated";
grant INSERT on "public"."waitlist_requests" to "service_role";
grant SELECT on "public"."waitlist_requests" to "service_role";
grant UPDATE on "public"."waitlist_requests" to "service_role";
grant DELETE on "public"."waitlist_requests" to "service_role";
grant TRUNCATE on "public"."waitlist_requests" to "service_role";
grant REFERENCES on "public"."waitlist_requests" to "service_role";
grant TRIGGER on "public"."waitlist_requests" to "service_role";
grant SELECT on "public"."waitlist_requests" to "authenticated";
grant INSERT on "public"."business_action_drafts" to "service_role";
grant SELECT on "public"."business_action_drafts" to "service_role";
grant UPDATE on "public"."business_action_drafts" to "service_role";
grant DELETE on "public"."business_action_drafts" to "service_role";
grant TRUNCATE on "public"."business_action_drafts" to "service_role";
grant REFERENCES on "public"."business_action_drafts" to "service_role";
grant TRIGGER on "public"."business_action_drafts" to "service_role";
grant INSERT on "public"."business_action_drafts" to "authenticated";
grant SELECT on "public"."business_action_drafts" to "authenticated";
grant UPDATE on "public"."business_action_drafts" to "authenticated";
grant INSERT on "public"."time_off" to "authenticated";
grant SELECT on "public"."time_off" to "authenticated";
grant UPDATE on "public"."time_off" to "authenticated";
grant DELETE on "public"."time_off" to "authenticated";
grant INSERT on "public"."time_off" to "service_role";
grant SELECT on "public"."time_off" to "service_role";
grant UPDATE on "public"."time_off" to "service_role";
grant DELETE on "public"."time_off" to "service_role";
grant TRUNCATE on "public"."time_off" to "service_role";
grant REFERENCES on "public"."time_off" to "service_role";
grant TRIGGER on "public"."time_off" to "service_role";
grant INSERT on "public"."staff" to "authenticated";
grant SELECT on "public"."staff" to "authenticated";
grant UPDATE on "public"."staff" to "authenticated";
grant DELETE on "public"."staff" to "authenticated";
grant INSERT on "public"."staff" to "service_role";
grant SELECT on "public"."staff" to "service_role";
grant UPDATE on "public"."staff" to "service_role";
grant DELETE on "public"."staff" to "service_role";
grant TRUNCATE on "public"."staff" to "service_role";
grant REFERENCES on "public"."staff" to "service_role";
grant TRIGGER on "public"."staff" to "service_role";
grant INSERT on "public"."services" to "authenticated";
grant SELECT on "public"."services" to "authenticated";
grant UPDATE on "public"."services" to "authenticated";
grant DELETE on "public"."services" to "authenticated";
grant INSERT on "public"."services" to "service_role";
grant SELECT on "public"."services" to "service_role";
grant UPDATE on "public"."services" to "service_role";
grant DELETE on "public"."services" to "service_role";
grant TRUNCATE on "public"."services" to "service_role";
grant REFERENCES on "public"."services" to "service_role";
grant TRIGGER on "public"."services" to "service_role";
grant INSERT on "public"."operator_decisions" to "authenticated";
grant SELECT on "public"."operator_decisions" to "authenticated";
grant UPDATE on "public"."operator_decisions" to "authenticated";
grant DELETE on "public"."operator_decisions" to "authenticated";
grant INSERT on "public"."operator_decisions" to "service_role";
grant SELECT on "public"."operator_decisions" to "service_role";
grant UPDATE on "public"."operator_decisions" to "service_role";
grant DELETE on "public"."operator_decisions" to "service_role";
grant TRUNCATE on "public"."operator_decisions" to "service_role";
grant REFERENCES on "public"."operator_decisions" to "service_role";
grant TRIGGER on "public"."operator_decisions" to "service_role";
grant execute on function kavelyq_private.is_business_member(uuid) to "authenticated";
grant execute on function kavelyq_private.is_business_member(uuid) to "service_role";
grant execute on function owner_operator_prepare() to "authenticated";
grant execute on function owner_operator_prepare() to "service_role";
grant execute on function owner_cancel_booking(uuid) to "authenticated";
grant execute on function owner_cancel_booking(uuid) to "service_role";
grant execute on function owner_operator_execute(uuid) to "authenticated";
grant execute on function owner_operator_execute(uuid) to "service_role";
grant execute on function owner_operator_measure(uuid) to "authenticated";
grant execute on function owner_operator_measure(uuid) to "service_role";
grant execute on function owner_set_marketing_consent(uuid,boolean) to "authenticated";
grant execute on function owner_set_marketing_consent(uuid,boolean) to "service_role";
grant execute on function owner_customer_crm() to "authenticated";
grant execute on function owner_customer_crm() to "service_role";
grant execute on function owner_rebooking_opportunities() to "authenticated";
grant execute on function owner_rebooking_opportunities() to "service_role";
grant execute on function owner_onboarding_snapshot() to "authenticated";
grant execute on function owner_onboarding_snapshot() to "service_role";
grant execute on function create_public_operator_booking(text,uuid,text,text,timestamp with time zone,text) to "service_role";
grant execute on function create_public_operator_booking_v2(text,text,text,text,timestamp with time zone) to "service_role";
grant execute on function create_owner_business(text,text,text,text,integer,integer) to "authenticated";
grant execute on function create_owner_business(text,text,text,text,integer,integer) to "service_role";
grant execute on function owner_add_time_off(uuid,timestamp with time zone,timestamp with time zone,text) to "authenticated";
grant execute on function owner_add_time_off(uuid,timestamp with time zone,timestamp with time zone,text) to "service_role";
grant execute on function owner_plan_access() to "authenticated";
grant execute on function owner_plan_access() to "service_role";
grant execute on function expire_finished_trials() to "service_role";
grant execute on function owner_business_settings() to "authenticated";
grant execute on function owner_business_settings() to "service_role";
grant execute on function owner_set_working_hours(uuid,integer,time without time zone,time without time zone,boolean) to "authenticated";
grant execute on function owner_set_working_hours(uuid,integer,time without time zone,time without time zone,boolean) to "service_role";
grant execute on function kavelyq_private.business_accepts_live_operations(uuid) to "authenticated";
grant execute on function kavelyq_private.business_accepts_live_operations(uuid) to "service_role";
grant execute on function get_public_booking_manage(uuid) to "authenticated";
grant execute on function get_public_booking_manage(uuid) to "anon";
grant execute on function get_public_booking_manage(uuid) to "service_role";
grant execute on function owner_update_business_settings(text,text,text,integer,integer,text,text,text) to "authenticated";
grant execute on function owner_update_business_settings(text,text,text,integer,integer,text,text,text) to "service_role";
grant execute on function owner_update_service(uuid,text,integer,integer,boolean) to "authenticated";
grant execute on function owner_update_service(uuid,text,integer,integer,boolean) to "service_role";
grant execute on function owner_subscription_snapshot() to "authenticated";
grant execute on function owner_subscription_snapshot() to "service_role";
grant execute on function get_public_booking_catalog(text) to "authenticated";
grant execute on function get_public_booking_catalog(text) to "anon";
grant execute on function get_public_booking_catalog(text) to "service_role";
grant execute on function owner_setup_snapshot() to "authenticated";
grant execute on function owner_setup_snapshot() to "service_role";
grant execute on function owner_set_staff_service(uuid,uuid,boolean) to "authenticated";
grant execute on function owner_set_staff_service(uuid,uuid,boolean) to "service_role";
grant execute on function owner_add_service(text,integer,integer) to "authenticated";
grant execute on function owner_add_service(text,integer,integer) to "service_role";
grant execute on function cancel_public_booking(uuid) to "authenticated";
grant execute on function cancel_public_booking(uuid) to "anon";
grant execute on function cancel_public_booking(uuid) to "service_role";
grant execute on function reschedule_public_booking(uuid,timestamp with time zone) to "service_role";
grant execute on function get_public_manage_availability(uuid,date) to "authenticated";
grant execute on function get_public_manage_availability(uuid,date) to "anon";
grant execute on function get_public_manage_availability(uuid,date) to "service_role";
grant execute on function owner_save_cut_memory(uuid,text,integer) to "authenticated";
grant execute on function owner_save_cut_memory(uuid,text,integer) to "service_role";
grant execute on function create_public_booking_local_v2(text,text,text,date,time without time zone,text,text,text) to "authenticated";
grant execute on function create_public_booking_local_v2(text,text,text,date,time without time zone,text,text,text) to "anon";
grant execute on function create_public_booking_local_v2(text,text,text,date,time without time zone,text,text,text) to "service_role";
grant execute on function reschedule_public_booking_local(uuid,date,time without time zone) to "authenticated";
grant execute on function reschedule_public_booking_local(uuid,date,time without time zone) to "anon";
grant execute on function reschedule_public_booking_local(uuid,date,time without time zone) to "service_role";
grant execute on function complete_email_notification(uuid,text) to "service_role";
grant execute on function fail_email_notification(uuid,text) to "service_role";
grant execute on function create_public_operator_booking(text,uuid,text,text,timestamp with time zone) to "service_role";
grant execute on function queue_booking_notifications() to "service_role";
grant execute on function owner_create_booking_local(uuid,uuid,uuid,date,time without time zone,text) to "authenticated";
grant execute on function owner_create_booking_local(uuid,uuid,uuid,date,time without time zone,text) to "service_role";
grant execute on function owner_reschedule_booking_local(uuid,date,time without time zone) to "authenticated";
grant execute on function owner_reschedule_booking_local(uuid,date,time without time zone) to "service_role";
grant execute on function owner_business_metrics() to "authenticated";
grant execute on function owner_business_metrics() to "service_role";
grant execute on function owner_operator_snapshot() to "authenticated";
grant execute on function owner_operator_snapshot() to "service_role";
grant execute on function get_public_availability(text,text,text,date) to "authenticated";
grant execute on function get_public_availability(text,text,text,date) to "anon";
grant execute on function get_public_availability(text,text,text,date) to "service_role";
grant execute on function create_public_booking(text,text,text,timestamp with time zone,text,text,text) to "service_role";
grant execute on function create_public_booking_v2(text,text,text,timestamp with time zone,text,text,text) to "service_role";
grant execute on function kavelyq_private.refresh_customer_crm(uuid) to "authenticated";
grant execute on function kavelyq_private.refresh_customer_crm(uuid) to "service_role";
grant execute on function kavelyq_private.assert_booking_slot(uuid,uuid,uuid,timestamp with time zone,uuid) to "authenticated";
grant execute on function kavelyq_private.assert_booking_slot(uuid,uuid,uuid,timestamp with time zone,uuid) to "service_role";
grant execute on function owner_communication_status() to "authenticated";
grant execute on function owner_communication_status() to "service_role";
grant execute on function owner_branding_snapshot() to "authenticated";
grant execute on function owner_branding_snapshot() to "service_role";
grant execute on function get_public_branding(text) to "authenticated";
grant execute on function get_public_branding(text) to "anon";
grant execute on function get_public_branding(text) to "service_role";
grant execute on function owner_import_records(text,jsonb,boolean) to "authenticated";
grant execute on function owner_import_records(text,jsonb,boolean) to "service_role";
grant execute on function owner_performance_report(date,date) to "authenticated";
grant execute on function owner_performance_report(date,date) to "service_role";
grant execute on function create_owner_business_industry(text,text,text,text,integer,integer,text) to "authenticated";
grant execute on function create_owner_business_industry(text,text,text,text,integer,integer,text) to "service_role";
grant execute on function create_owner_business_v2(text,text,text,text,integer,integer,text,text) to "authenticated";
grant execute on function create_owner_business_v2(text,text,text,text,integer,integer,text,text) to "service_role";
grant execute on function owner_industry_profile() to "authenticated";
grant execute on function owner_industry_profile() to "service_role";
grant execute on function owner_calendar_range(date,date,uuid) to "authenticated";
grant execute on function owner_calendar_range(date,date,uuid) to "service_role";
grant execute on function create_owner_business_industry_v2(text,text,text,text,integer,integer,text,text,text) to "authenticated";
grant execute on function create_owner_business_industry_v2(text,text,text,text,integer,integer,text,text,text) to "service_role";
grant execute on function kavelyq_private.require_business_owner() to "authenticated";
grant execute on function owner_add_staff(text) to "authenticated";
grant execute on function owner_add_staff(text) to "service_role";
grant execute on function owner_complete_onboarding() to "authenticated";
grant execute on function owner_complete_onboarding() to "service_role";
grant execute on function owner_create_booking(uuid,uuid,uuid,timestamp with time zone,text) to "authenticated";
grant execute on function owner_create_booking(uuid,uuid,uuid,timestamp with time zone,text) to "service_role";
grant execute on function owner_create_recovery_offer(uuid) to "authenticated";
grant execute on function owner_create_recovery_offer(uuid) to "service_role";
grant execute on function owner_operator_prepare_outreach(uuid) to "authenticated";
grant execute on function owner_operator_prepare_outreach(uuid) to "service_role";
grant execute on function owner_remove_time_off(uuid) to "authenticated";
grant execute on function owner_remove_time_off(uuid) to "service_role";
grant execute on function owner_reschedule_booking(uuid,timestamp with time zone) to "authenticated";
grant execute on function owner_reschedule_booking(uuid,timestamp with time zone) to "service_role";
grant execute on function owner_save_branding(jsonb) to "authenticated";
grant execute on function owner_save_branding(jsonb) to "service_role";
grant execute on function owner_update_booking_status(uuid,text) to "authenticated";
grant execute on function owner_update_booking_status(uuid,text) to "service_role";
grant execute on function owner_update_staff(uuid,text,boolean) to "authenticated";
grant execute on function owner_update_staff(uuid,text,boolean) to "service_role";
grant execute on function owner_dashboard() to "authenticated";
grant execute on function owner_dashboard() to "service_role";
grant execute on function withdraw_public_waitlist(uuid) to "authenticated";
grant execute on function withdraw_public_waitlist(uuid) to "anon";
grant execute on function withdraw_public_waitlist(uuid) to "service_role";
grant execute on function join_public_waitlist(text,text,text,text,text,text,date,date,boolean) to "authenticated";
grant execute on function join_public_waitlist(text,text,text,text,text,text,date,date,boolean) to "anon";
grant execute on function join_public_waitlist(text,text,text,text,text,text,date,date,boolean) to "service_role";
grant execute on function owner_prepare_business_action(text,uuid) to "authenticated";
grant execute on function owner_prepare_business_action(text,uuid) to "service_role";
grant execute on function owner_intelligence_snapshot() to "authenticated";
grant execute on function owner_intelligence_snapshot() to "service_role";
grant execute on function owner_approve_business_action(uuid) to "authenticated";
grant execute on function owner_approve_business_action(uuid) to "service_role";
grant execute on function kavelyq_private.can_manage_business(uuid) to "authenticated";
grant execute on function refresh_rescheduled_notifications() to "service_role";
grant execute on function owner_export_customer(uuid) to "authenticated";
grant execute on function owner_export_customer(uuid) to "service_role";
grant execute on function claim_due_email_notifications(integer) to "service_role";
grant execute on function owner_delete_customer_data(uuid) to "authenticated";
grant execute on function owner_delete_customer_data(uuid) to "service_role";
grant execute on function owner_add_time_off_local(uuid,timestamp without time zone,timestamp without time zone,text) to "authenticated";
grant execute on function owner_add_time_off_local(uuid,timestamp without time zone,timestamp without time zone,text) to "service_role";
grant all on all tables in schema public,kavelyq_private to service_role;
grant usage,select on all sequences in schema public to service_role;
