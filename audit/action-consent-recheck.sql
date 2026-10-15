create or replace function public.owner_approve_business_action(p_id uuid) returns jsonb language plpgsql security definer set search_path='' as $$
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
end $$;
