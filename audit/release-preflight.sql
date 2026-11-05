-- READ-ONLY release metadata. No credentials, user records, DDL or writes.
-- Run with an authorised administration connection. Review false/missing values;
-- do not apply migrations automatically to make this report green.
with required(signature) as(values
 ('public.owner_dashboard()'),('public.owner_onboarding_snapshot()'),
 ('public.create_owner_business_industry_v2(text,text,text,text,integer,integer,text,text,text)'),
 ('public.owner_create_booking_local(uuid,uuid,uuid,date,time without time zone,text)'),
 ('public.owner_reschedule_booking_local(uuid,date,time without time zone)'),
 ('public.owner_customer_crm()'),('public.owner_setup_snapshot()'),
 ('public.get_public_booking_manage(uuid)'),
 ('public.create_public_booking_local_v2(text,text,text,date,time without time zone,text,text,text)')),
client_grants as(select grantee,privilege_type,table_name from information_schema.role_table_grants where table_schema='public')
select jsonb_build_object(
 'public_tables_rls',coalesce((select bool_and(rowsecurity) from pg_tables where schemaname='public'),false),
 'anonymous_table_grants',(select count(*) from client_grants where grantee in('anon','PUBLIC')),
 'dangerous_authenticated_grants',(select count(*) from client_grants where grantee='authenticated' and privilege_type in('TRUNCATE','TRIGGER','REFERENCES')),
 'missing_functions',(select coalesce(jsonb_agg(signature),'[]') from required where to_regprocedure(signature) is null),
 'hours_are_local_time',(select data_type='time without time zone' from information_schema.columns where table_schema='public' and table_name='working_hours' and column_name='start_time'),
 'booking_exclusion_present',exists(select 1 from pg_constraint where conrelid=to_regclass('public.bookings') and contype='x'),
 'weekly_migration_present',to_regprocedure('public.owner_set_staff_week_hours(uuid,jsonb)') is not null,
 'notification_migration_present',to_regclass('kavelyq_private.notification_delivery_events') is not null,
 'anonymous_owner_rpc_denied',case when to_regprocedure('public.owner_dashboard()') is null then false else not has_function_privilege('anon','public.owner_dashboard()','EXECUTE') end
) as release_preflight;
