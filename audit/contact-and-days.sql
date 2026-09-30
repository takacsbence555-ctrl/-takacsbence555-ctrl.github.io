-- Reversible production audit fixes; preserve function signatures and grants.
do $audit$
declare definition text;
begin
 select pg_get_functiondef('public.assert_booking_slot(uuid,uuid,uuid,timestamptz,uuid)'::regprocedure) into definition;
 definition:=replace(definition,'extract(isodow from local_start)','extract(dow from local_start)');
 definition:=replace(definition,'if p_starts_at<=now()', 'if p_starts_at is null or p_starts_at<=now()');
 definition:=replace(definition,'local_end::time<=wh.end_time','local_end::time<=wh.end_time and local_start::date=local_end::date');
 execute definition;
 select pg_get_functiondef('public.create_public_booking_v2(text,text,text,timestamptz,text,text,text)'::regprocedure) into definition;
 definition:=replace(definition,'if p_starts_at<=now()', 'if p_starts_at is null or p_starts_at<=now()');
 definition:=replace(definition,'if length(trim(coalesce(p_display_name,', 'if length(p_display_name)>120 or length(trim(coalesce(p_display_name,');
 definition:=replace(definition,'ch:=md5(', E'if nullif(trim(p_email),\'\') is not null and trim(p_email) !~ \'^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$\' then raise exception \'INVALID_EMAIL\'; end if;\n if nullif(trim(p_phone),\'\') is not null and trim(p_phone) !~ \'^[+]?[0-9 ()-]{6,40}$\' then raise exception \'INVALID_PHONE\'; end if;\n ch:=md5(');
 definition:=replace(definition,'select count(*) into recent', 'perform pg_advisory_xact_lock(hashtextextended(bid::text||ch,0)); select count(*) into recent');
 execute definition;
 select pg_get_functiondef('public.cancel_public_booking(uuid)'::regprocedure) into definition;
 definition:=replace(definition,'where manage_token=p_token;', 'where manage_token=p_token for update;');execute definition;
 select pg_get_functiondef('public.reschedule_public_booking(uuid,timestamptz)'::regprocedure) into definition;
 definition:=replace(definition,'where manage_token=p_token;', 'where manage_token=p_token for update;');execute definition;
end
$audit$;
