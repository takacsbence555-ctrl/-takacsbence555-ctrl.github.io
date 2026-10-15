-- Serialize booking validations for a professional before the GiST exclusion
-- constraint sees competing inserts. The exclusion constraint remains in place.
do $migration$
declare definition text;
begin
 select pg_get_functiondef('kavelyq_private.assert_booking_slot(uuid,uuid,uuid,timestamp with time zone,uuid)'::regprocedure) into definition;
 if position('kavelyq-booking-staff:' in definition)=0 then
  if position('begin if p_starts_at' in definition)=0 then raise exception 'UNEXPECTED_EXISTING_FUNCTION';end if;
  definition:=replace(definition,'begin if p_starts_at',
   'begin perform pg_advisory_xact_lock(hashtextextended(''kavelyq-booking-staff:''||p_staff_id::text,0)); if p_starts_at');
  execute definition;
 end if;
end
$migration$;
