-- Existing businesses intentionally have no direct client UPDATE policy.
-- This narrowly scoped onboarding wrapper can update only its newly created,
-- membership-verified business. Existing business privileges are not widened.
do $$ declare d text;begin
 select pg_get_functiondef('public.create_owner_business_v2(text,text,text,text,integer,integer,text,text)'::regprocedure) into d;
 d:=replace(d,'SECURITY INVOKER','SECURITY DEFINER');
 -- pg_get_functiondef omits SECURITY INVOKER when it is the default.
 if position('SECURITY DEFINER' in d)=0 then d:=replace(d,'LANGUAGE plpgsql','LANGUAGE plpgsql SECURITY DEFINER');end if;
 d:=replace(d,'if p_timezone is null','if auth.uid() is null then raise exception ''AUTH_REQUIRED'';end if; if p_timezone is null');
 d:=replace(d,'where id=bid;','where id=bid and exists(select 1 from public.business_members m where m.business_id=bid and m.user_id=auth.uid() and m.role=''owner'');');
 execute d;
end $$;
