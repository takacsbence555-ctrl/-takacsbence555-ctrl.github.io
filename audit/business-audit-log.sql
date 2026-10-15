create table public.business_audit_log (
 id uuid primary key default gen_random_uuid(),
 business_id uuid not null references public.businesses(id),
 actor_id uuid,
 entity text not null,
 record_id text not null,
 operation text not null check(operation in('INSERT','UPDATE','DELETE')),
 occurred_at timestamptz not null default now()
);
create index business_audit_log_business_time on public.business_audit_log(business_id,occurred_at desc);
alter table public.business_audit_log enable row level security;
revoke all on public.business_audit_log from public,anon,authenticated;
grant select on public.business_audit_log to authenticated;
create policy audit_owner_read on public.business_audit_log for select to authenticated using(exists(select 1 from public.business_members m where m.business_id=business_audit_log.business_id and m.user_id=(select auth.uid()) and m.role in('owner','manager')));
create function kavelyq_private.record_business_audit() returns trigger language plpgsql security definer set search_path='' as $$
declare row_data jsonb;bid uuid;rid text;
begin
 row_data:=case when tg_op='DELETE' then to_jsonb(old) else to_jsonb(new) end;
 if tg_table_name='businesses' then bid:=(row_data->>'id')::uuid;
 elsif row_data ? 'business_id' then bid:=(row_data->>'business_id')::uuid;
 else select business_id into bid from public.staff where id=(row_data->>'staff_id')::uuid;end if;
 rid:=coalesce(row_data->>'id',row_data->>'business_id',(row_data->>'staff_id')||':'||(row_data->>'service_id'));
 if bid is not null then insert into public.business_audit_log(business_id,actor_id,entity,record_id,operation) values(bid,auth.uid(),tg_table_name,coalesce(rid,'unknown'),tg_op);end if;
 if tg_op='DELETE' then return old;else return new;end if;
end $$;
revoke all on function kavelyq_private.record_business_audit() from public,anon,authenticated;
do $$ declare t text;begin foreach t in array array['businesses','staff','services','working_hours','time_off','staff_services','customers','bookings','business_branding'] loop execute format('create trigger record_business_audit after insert or update or delete on public.%I for each row execute function kavelyq_private.record_business_audit()',t);end loop;end $$;
-- Reject null import/branding payloads before optional JSON expressions.
do $$ declare d text;begin
 select pg_get_functiondef('public.owner_import_records(text,jsonb,boolean)'::regprocedure) into d;
 d:=replace(d,'if p_kind not in', 'if p_kind is null or p_records is null or p_preview is null or p_kind not in');execute d;
 select pg_get_functiondef('public.owner_save_branding(jsonb)'::regprocedure) into d;
 d:=replace(d,'if jsonb_typeof(p_config)','if p_config is null or jsonb_typeof(p_config)');execute d;
end $$;
