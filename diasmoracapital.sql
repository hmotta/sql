CREATE OR REPLACE FUNCTION diasmoracapital(integer, date)
RETURNS integer AS
$BODY$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
	ncapitaltablaamort numeric;
	ncapitalpolizas numeric;
	ncapitalapagar numeric;
	ndias integer;
	dfechaprimeradeudo date;
begin
	select coalesce(sum(importeamortizacion),0) into ncapitalapagar from amortizaciones where  prestamoid = pprestamoid and fechadepago<=pfecha;
	
	if ncapitalapagar>0 then --creditos que ya debieron o deben pagar capital 
		select coalesce(sum(abonopagado),0) into ncapitaltablaamort from amortizaciones where  prestamoid = pprestamoid; --el monto que tienen pagado de capital segun la tabla de amortizaciones
		select sum(case when m.cuentaid=ct.cta_cap_vig then m.haber else 0 end) into ncapitalpolizas from movicaja mc, movipolizas m, polizas p, prestamos pr,  cat_cuentas_tipoprestamo ct where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and ct.cat_cuentasid = pr.cat_cuentasid and m.polizaid = mc.polizaid and m.polizaid=p.polizaid; --el monto que tienen pagado de capital segun las polizas
		--raise notice 'pprestamoid=%',pprestamoid;
		--raise notice 'ncapitaltablaamort=%',ncapitaltablaamort;
		--raise notice 'ncapitalpolizas=%',ncapitalpolizas;
		if ncapitaltablaamort=ncapitalpolizas then
			select coalesce(current_date-min(fechadepago),0) into ndias from amortizaciones where abonopagado<>importeamortizacion and prestamoid=pprestamoid and fechadepago<=pfecha; --se toman los dias de la tabla de amort
			if ndias<0 then
				return 0;
			end if;
		else
			select fechaprimeradeudo into dfechaprimeradeudo from fechaprimeradeudo(pprestamoid,pfecha);
			if (pfecha-dfechaprimeradeudo)>0 then --se toma el proceso de calcular todo de acuerdo al capital pagado
				ndias:=pfecha-dfechaprimeradeudo;
			else
				return 0;
			end if;
		end if;
		
	else --Creditos nuevos o que aun no les toca su primer pago o pagar capital
		return 0;
	end if;
	return ndias;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;