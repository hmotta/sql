CREATE OR REPLACE FUNCTION corrige_tablas_amortizaciones()
RETURNS integer AS
$BODY$
declare
	r record;
	ncapitaltablaamort numeric;
	ncapitalpolizas numeric;
	amor record;
	fAplicar numeric;
	fAbono numeric;
begin

	for r in 
		select prestamoid from prestamos where claveestadocredito='001' and saldoprestamo>0
	loop
		select coalesce(sum(abonopagado),0) into ncapitaltablaamort from amortizaciones where  prestamoid = r.prestamoid; --el monto que tienen pagado de capital segun la tabla de amortizaciones
		select sum(case when (m.cuentaid=ct.cuentaactivo) then m.haber else 0 end) into ncapitalpolizas from movicaja mc, movipolizas m, polizas p, prestamos pr,  cat_cuentas_tipoprestamo ct where mc.prestamoid=r.prestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and (ct.cat_cuentasid=pr.cat_cuentasid) and m.polizaid = mc.polizaid and m.polizaid=p.polizaid; --el monto que tienen pagado de capital segun las polizas
		ncapitaltablaamort:=coalesce(ncapitaltablaamort,0);
		ncapitalpolizas:=coalesce(ncapitalpolizas,0);
		if ncapitalpolizas<>ncapitaltablaamort then
			raise notice 'Corrigiendo Prestamoid %',r.prestamoid;
			update amortizaciones set abonopagado=0 where prestamoid=r.prestamoid;
			fAbono:=ncapitalpolizas;
			if fAbono>0 then
				for amor in
					select *
					from amortizaciones
					where prestamoid=r.prestamoid and importeamortizacion-abonopagado>0
					order by fechadepago
				loop
					fAplicar := amor.importeamortizacion - amor.abonopagado;

					if fAbono>=fAplicar then
						update amortizaciones
						set abonopagado = importeamortizacion
						where amortizacionid=amor.amortizacionid;
						fAbono := fAbono - fAplicar;
					else
						if fAbono>0 then
							update amortizaciones
							set abonopagado = abonopagado+fAbono
							where amortizacionid=amor.amortizacionid;
							fAbono := 0;
						end if;
					end if;
				end loop;
			end if;
		end if;
	end loop;
return 1;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;