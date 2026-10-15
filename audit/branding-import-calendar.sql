-- Additive product features. Existing business/booking tables and RLS retained.
create table public.business_branding (
 business_id uuid primary key references public.businesses(id),
 config jsonb not null default '{}'::jsonb,
 updated_at timestamptz not null default now()
);
alter table public.business_branding enable row level security;
revoke all on public.business_branding from public,anon;
grant select,insert,update on public.business_branding to authenticated;
create policy branding_owner on public.business_branding for all to authenticated
using(exists(select 1 from public.business_members m where m.business_id=business_branding.business_id and m.user_id=(select auth.uid()) and m.role in('owner','manager')))
with check(exists(select 1 from public.business_members m where m.business_id=business_branding.business_id and m.user_id=(select auth.uid()) and m.role in('owner','manager')));
create function public.owner_branding_snapshot() returns jsonb language sql stable security invoker set search_path='' as $$
 select coalesce((select b.config from public.business_branding b join public.business_members m on m.business_id=b.business_id where m.user_id=(select auth.uid()) and m.role in('owner','manager') limit 1),'{}'::jsonb)
$$;
create function public.owner_save_branding(p_config jsonb) returns jsonb language plpgsql security invoker set search_path='' as $$
declare bid uuid;cfg jsonb;k text;v text;
begin
 select business_id into bid from public.business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if jsonb_typeof(p_config)<>'object' then raise exception 'INVALID_BRANDING';end if;
 cfg:=jsonb_build_object('accent',coalesce(p_config->>'accent','#c8e986'),'font',coalesce(p_config->>'font','system'),'logo_url',coalesce(p_config->>'logo_url',''),'hero_url',coalesce(p_config->>'hero_url',''),'description',coalesce(p_config->>'description',''));
 if cfg->>'accent' !~ '^#[0-9a-fA-F]{6}$' or cfg->>'font' not in('system','georgia','arial') or length(cfg->>'description')>1000 then raise exception 'INVALID_BRANDING';end if;
 foreach k in array array['logo_url','hero_url'] loop v:=cfg->>k;if length(v)>2048 or (v<>'' and v !~ '^https://[^[:space:]]+$') then raise exception 'INVALID_IMAGE_URL';end if;end loop;
 insert into public.business_branding(business_id,config) values(bid,cfg) on conflict(business_id) do update set config=excluded.config,updated_at=now();return cfg;
end $$;
create function public.get_public_branding(p_business_slug text) returns jsonb language sql stable security definer set search_path='' as $$
 select coalesce(br.config,'{}'::jsonb) from public.businesses b left join public.business_branding br on br.business_id=b.id where b.public_slug=p_business_slug and kavelyq_private.business_accepts_live_operations(b.id)
$$;
revoke all on function public.owner_branding_snapshot(),public.owner_save_branding(jsonb),public.get_public_branding(text) from public,anon,authenticated;
grant execute on function public.owner_branding_snapshot(),public.owner_save_branding(jsonb) to authenticated;
grant execute on function public.get_public_branding(text) to anon,authenticated;

create function public.owner_calendar_range(p_start date,p_end date,p_staff_id uuid default null) returns jsonb language plpgsql stable security invoker set search_path='' as $$
declare bid uuid;tz text;out jsonb;
begin
 select b.id,b.timezone into bid,tz from public.businesses b join public.business_members m on m.business_id=b.id where m.user_id=auth.uid() limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if p_start is null or p_end is null or p_end<=p_start or p_end-p_start>62 then raise exception 'INVALID_DATE_RANGE';end if;
 select coalesce(jsonb_agg(jsonb_build_object('id',b.id,'starts_at',b.starts_at,'ends_at',b.ends_at,'status',b.status,'customer',c.display_name,'staff',s.display_name,'service',v.name,'price_cents',b.booked_price_cents) order by b.starts_at),'[]'::jsonb) into out
 from public.bookings b join public.staff s on s.id=b.staff_id join public.services v on v.id=b.service_id left join public.customers c on c.id=b.customer_id
 where b.business_id=bid and b.starts_at>=(p_start::timestamp at time zone tz) and b.starts_at<(p_end::timestamp at time zone tz) and (p_staff_id is null or b.staff_id=p_staff_id);
 return out;
end $$;
revoke all on function public.owner_calendar_range(date,date,uuid) from public,anon;
grant execute on function public.owner_calendar_range(date,date,uuid) to authenticated;

create function public.owner_import_records(p_kind text,p_records jsonb,p_preview boolean default true) returns jsonb language plpgsql security invoker set search_path='' as $$
declare bid uuid;r jsonb;i int:=0;issues jsonb:='[]';seen text[]:=array[]::text[];key text;nm text;em text;ph text;n int;price int;inserted int:=0;
begin
 select business_id into bid from public.business_members where user_id=auth.uid() and role in('owner','manager') limit 1;
 if bid is null then raise exception 'AUTH_REQUIRED';end if;
 if p_kind not in('customers','staff','services') or jsonb_typeof(p_records)<>'array' or jsonb_array_length(p_records) not between 1 and 1000 then raise exception 'INVALID_IMPORT';end if;
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
end $$;
revoke all on function public.owner_import_records(text,jsonb,boolean) from public,anon;
grant execute on function public.owner_import_records(text,jsonb,boolean) to authenticated;
