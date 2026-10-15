do $$ declare d text;begin
 select pg_get_functiondef('public.owner_setup_snapshot()'::regprocedure) into d;
 d:=replace(d,'where user_id=auth.uid() limit 1','where user_id=auth.uid() and role in(''owner'',''manager'') limit 1');execute d;
 select pg_get_functiondef('public.owner_subscription_snapshot()'::regprocedure) into d;
 d:=replace(d,'where bm.user_id=auth.uid() limit 1','where bm.user_id=auth.uid() and bm.role in(''owner'',''manager'') limit 1');
 d:=replace(d,'''monthly_price_eur'',49,''annual_price_eur'',490','''monthly_price_eur'',null,''annual_price_eur'',null,''proposed_plans_gbp'',jsonb_build_object(''essential'',19,''intelligence'',39),''live_billing_enabled'',false');execute d;
end $$;
