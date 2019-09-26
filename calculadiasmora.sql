CREATE OR REPLACE FUNCTION calculadiasmora(integer)
  RETURNS SETOF rcalculadiasmora AS
$BODY$
declare
	pprestamoid alias for $1;
	re rcalculadiasmora;
	r record;
	l record;
	fcapital numeric;
	fnormal numeric;
	fmoratorio numeric;
	fiva numeric;
	fecha_amort date;
	capital_pagado numeric;
	importe_amort numeric;
	indice_amort integer;
	num_amort integer; 
	tipo_producto character(3);
	clavecredito character(3);
	cuentas record;
 
begin
	select tipoprestamoid,claveestadocredito into tipo_producto,clavecredito from prestamos where prestamoid=pprestamoid;
	if tipo_producto <> 'N10' and tipo_producto <> 'V10' then
		/*select amortizacionid,numamortizacion,diasmora,fechadepago,fechadepagoreal into re from clasificacioncartera natural join amortizaciones where prestamoid=pprestamoid;
		if NOT FOUND then
			RAISE NOTICE 'not found';
			indice_amort := 1;
			capital_pagado:=0;
			select ct.cta_cap_vig,ct.cta_mora_vig_resultados  into cuentas from cat_cuentas_tipoprestamo ct,prestamos pr where pr.prestamoid = pprestamoid  and ct.cat_cuentasid=pr.cat_cuentasid;
			select count(*) into num_amort from amortizaciones where prestamoid=pprestamoid;
			select importeamortizacion,fechadepago,amortizacionid into importe_amort,fecha_amort,re.amortizacionid from amortizaciones where prestamoid=pprestamoid and numamortizacion = indice_amort;
			for r in select mc.polizaid,p.fechapoliza,m.debe,m.haber,mc.movicajaid from movicaja mc,polizas p, movipolizas m,tipomovimiento t where p.polizaid = mc.polizaid and m.movipolizaid = mc.movipolizaid and mc.tipomovimientoid='00' and t.tipomovimientoid = mc.tipomovimientoid and mc.prestamoid = pprestamoid order by p.fechapoliza
			loop
				fcapital := 0;
				fnormal := 0;
				fmoratorio := 0;
				fiva := 0;
				--for l in
				--  select m.polizaid from movicaja m where m.movicajaid = r.movicajaid
				--loop
				select sum(coalesce(haber-debe,0)) into fcapital from movipolizas where polizaid = r.polizaid and cuentaid = cuentas.cta_cap_vig  and debe=0;
				select sum(coalesce(haber-debe,0)) into fmoratorio from movipolizas where polizaid = r.polizaid and cuentaid = cuentas.cta_mora_vig_resultados ;
				--end loop;
				--raise notice 'capital_pagado = %',fcapital;
				capital_pagado := fcapital;
				--raise notice 'capital_pagado = %',capital_pagado;
				while ( capital_pagado > 0 and indice_amort <= num_amort  )
				loop
					capital_pagado := capital_pagado - importe_amort;
					--raise notice 'capital_pagado = %, importe_amort=%',capital_pagado,importe_amort;
					if capital_pagado < 0 then
						importe_amort := capital_pagado * (-1);
					else
						if fmoratorio <> 0 and fecha_amort < r.fechapoliza then
							re.numamortizacion = indice_amort; re.diasmora = r.fechapoliza-fecha_amort; re.fechapago=fecha_amort; re.fechapagoreal=r.fechapoliza; 
							if clavecredito='002' then
								raise notice 'Amortizacionid = %',re.amortizacionid;
								insert into clasificacioncartera values(re.amortizacionid,re.diasmora,re.fechapagoreal);
							end if;
							return next re;
						else
							re.numamortizacion = indice_amort; re.diasmora = 0; re.fechapago=fecha_amort; re.fechapagoreal=r.fechapoliza;
							if clavecredito='002' then
								raise notice 'Amortizacionid = %',re.amortizacionid;
								insert into clasificacioncartera values(re.amortizacionid,re.diasmora,re.fechapagoreal);
							end if;
							return next re;
						end if;
						indice_amort := indice_amort + 1;
						select importeamortizacion,fechadepago,amortizacionid into importe_amort,fecha_amort,re.amortizacionid from amortizaciones where prestamoid=pprestamoid and numamortizacion = indice_amort;
					end if;
				end loop;
			end loop;

			raise notice 'Salgo del while amortizacion: %',indice_amort;
			for r in select numamortizacion,importeamortizacion,fechadepago,amortizacionid from amortizaciones where prestamoid=pprestamoid and numamortizacion >= indice_amort and fechadepago <= CURRENT_DATE order by numamortizacion limit 1
			loop
				re.numamortizacion = r.numamortizacion; re.diasmora = current_date-r.fechadepago; re.fechapago=r.fechadepago; re.fechapagoreal=current_date; re.amortizacionid=r.amortizacionid;
				--if clavecredito='002' then
					--insert into clasificacioncartera values(re.amortizacionid,re.diasmora,re.fechapagoreal);
				--end if;
				return next re;
			end loop;
		else
			RAISE NOTICE 'found';
			for re in
				select amortizacionid,numamortizacion,diasmora,fechadepago,fechadepagoreal from amortizaciones natural join clasificacioncartera where prestamoid=pprestamoid order by numamortizacion
			loop
				return next re;
			end loop;
		end if;*/
		for re in
			select amortizacionid,numamortizacion,dias_mora_capital,fechadepago,ultimoabono from amortizaciones where prestamoid=pprestamoid order by numamortizacion
		loop
			return next re;
		end loop;
	end if;
return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;