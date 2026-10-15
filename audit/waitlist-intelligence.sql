create table public.waitlist_requests(
 id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),service_id uuid not null references public.services(id),staff_id uuid references public.staff(id),
 display_name text not null check(length(display_name) between 2 and 120),email text,phone text,date_from date not null,date_to date not null,
 contact_permission boolean not null default false,status text not null default 'waiting' check(status in('waiting','withdrawn','fulfilled')),
 manage_token uuid not null default gen_random_uuid() unique,created_at timestamptz not null default now(),check(date_to>=date_from and date_to-date_from<=30)
);
alter table public.waitlist_requests enable row level security;
revoke all on public.waitlist_requests from public,anon,authenticated;grant select on public.waitlist_requests to authenticated;
create policy waitlist_owner_read on public.waitlist_requests for select to authenticated using(exists(select 1 from public.business_members m where m.business_id=waitlist_requests.business_id and m.user_id=(select auth.uid()) and m.role in('owner','manager')));
create index waitlist_business_state on public.waitlist_requests(business_id,status,date_to);
create function public.join_public_waitlist(p_business_slug text,p_service_slug text,p_staff_slug text,p_name text,p_email text,p_phone text,p_date_from date,p_date_to date,p_contact_permission boolean) returns jsonb language plpgsql security definer set search_path='' as $$
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
end $$;
create function public.withdraw_public_waitlist(p_token uuid) returns boolean language plpgsql security definer set search_path='' as $$begin update public.waitlist_requests set status='withdrawn',contact_permission=false where manage_token=p_token and status='waiting';return found;end $$;
revoke all on function public.join_public_waitlist(text,text,text,text,text,text,date,date,boolean),public.withdraw_public_waitlist(uuid) from public;
grant execute on function public.join_public_waitlist(text,text,text,text,text,text,date,date,boolean),public.withdraw_public_waitlist(uuid) to anon,authenticated;

create table public.business_action_drafts(id uuid primary key default gen_random_uuid(),business_id uuid not null references public.businesses(id),kind text not null check(kind in('reactivation','rebooking','waitlist')),subject_id uuid not null,status text not null default 'prepared' check(status in('prepared','approved','cancelled')),created_by uuid not null,approved_by uuid,created_at timestamptz not null default now(),approved_at timestamptz,unique(business_id,kind,subject_id));
alter table public.business_action_drafts enable row level security;revoke all on public.business_action_drafts from public,anon,authenticated;grant select,insert,update on public.business_action_drafts to authenticated;
create policy action_owner on public.business_action_drafts for all to authenticated using(exists(select 1 from public.business_members m where m.business_id=business_action_drafts.business_id and m.user_id=(select auth.uid()) and m.role in('owner','manager'))) with check(exists(select 1 from public.business_members m where m.business_id=business_action_drafts.business_id and m.user_id=(select auth.uid()) and m.role in('owner','manager')));
create function public.owner_prepare_business_action(p_kind text,p_subject_id uuid) returns jsonb language plpgsql security invoker set search_path='' as $$declare bid uuid:=kavelyq_private.require_business_owner();r jsonb;begin
 if p_kind in('reactivation','rebooking') then if not exists(select 1 from public.customers where id=p_subject_id and business_id=bid and marketing_consent and deleted_at is null) then raise exception 'CONSENT_REQUIRED';end if;
 elsif p_kind='waitlist' then if not exists(select 1 from public.waitlist_requests where id=p_subject_id and business_id=bid and status='waiting' and contact_permission and date_to>=current_date) then raise exception 'REQUEST_UNAVAILABLE';end if;
 else raise exception 'INVALID_ACTION';end if;
 insert into public.business_action_drafts(business_id,kind,subject_id,created_by) values(bid,p_kind,p_subject_id,auth.uid()) on conflict(business_id,kind,subject_id) do nothing;
 select to_jsonb(a) into r from public.business_action_drafts a where business_id=bid and kind=p_kind and subject_id=p_subject_id;return r;
end $$;
create function public.owner_approve_business_action(p_id uuid) returns jsonb language plpgsql security invoker set search_path='' as $$declare bid uuid:=kavelyq_private.require_business_owner();r jsonb;begin
 update public.business_action_drafts set status='approved',approved_by=auth.uid(),approved_at=now() where id=p_id and business_id=bid and status='prepared' returning to_jsonb(business_action_drafts.*) into r;
 if r is null then raise exception 'ACTION_UNAVAILABLE';end if;return r||jsonb_build_object('delivery_enabled',false);
end $$;
create function public.owner_intelligence_snapshot() returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare bid uuid:=kavelyq_private.require_business_owner();tz text;today date;start_day date;end_day date;result jsonb;
begin
 select timezone into tz from public.businesses where id=bid;today:=(now() at time zone tz)::date;start_day:=date_trunc('month',today)::date;end_day:=(start_day+interval '1 month')::date;
 with totals as(select coalesce(sum(booked_price_cents) filter(where status='completed'),0) completed,coalesce(sum(booked_price_cents) filter(where status='confirmed' and starts_at>=now()),0) booked,count(*) filter(where status='completed') samples from public.bookings where business_id=bid and starts_at>=(start_day::timestamp at time zone tz) and starts_at<(end_day::timestamp at time zone tz))
 select jsonb_build_object('forecast',jsonb_build_object('completed_value_cents',completed,'confirmed_future_value_cents',booked,'estimate_cents',greatest(completed+booked,round(completed::numeric/greatest(1,today-start_day+1)*(end_day-start_day))),'completed_samples',samples,'method','Rules-based monthly pace; completed service value plus recorded bookings. Assumes recent pace continues. Not collected payments; cancellations and refunds may reduce value.','confidence',case when samples<20 then 'Low: limited completed history' else 'Uncalibrated: heuristic estimate' end),
 'overdue_customers',coalesce((select jsonb_agg(jsonb_build_object('id',id,'name',display_name,'due_at',next_due_at,'consent',marketing_consent)) from public.customers where business_id=bid and deleted_at is null and next_due_at<now()),'[]'::jsonb),
 'waitlist',coalesce((select jsonb_agg(jsonb_build_object('id',w.id,'name',w.display_name,'service',s.name,'from',w.date_from,'to',w.date_to,'contact_permission',w.contact_permission,'cancelled_slot_matches',(select count(*) from public.bookings b where b.business_id=bid and b.service_id=w.service_id and b.status='cancelled' and b.starts_at>now() and (b.starts_at at time zone tz)::date between w.date_from and w.date_to and (w.staff_id is null or b.staff_id=w.staff_id)))) from public.waitlist_requests w join public.services s on s.id=w.service_id where w.business_id=bid and w.status='waiting' and w.date_to>=today),'[]'::jsonb),
 'drafts',coalesce((select jsonb_agg(to_jsonb(a)) from public.business_action_drafts a where a.business_id=bid),'[]'::jsonb),'delivery_enabled',false) into result from totals;
 return result;
end $$;
revoke all on function public.owner_prepare_business_action(text,uuid),public.owner_approve_business_action(uuid),public.owner_intelligence_snapshot() from public,anon;
grant execute on function public.owner_prepare_business_action(text,uuid),public.owner_approve_business_action(uuid),public.owner_intelligence_snapshot() to authenticated;
