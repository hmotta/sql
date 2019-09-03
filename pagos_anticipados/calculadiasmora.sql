DROP TYPE "public"."rcalculadiasmora" cascade;

CREATE TYPE "public"."rcalculadiasmora" AS (
  "amortizacionid" int4,
  "numamortizacion" numeric(32),
  "diasmora" int4,
  "fechapago" date,
  "fechapagoreal" date
);

ALTER TYPE "public"."rcalculadiasmora" OWNER TO "sistema";

CREATE OR REPLACE FUNCTION "public"."calculadiasmora"(int4)
  RETURNS SETOF "public"."rcalculadiasmora" AS $BODY$
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
	indice_amort numeric;
	num_amort numeric; 
	tipo_producto character(3);
	clavecredito character(3);
	cuentas record;
 
begin
	select tipoprestamoid,claveestadocredito into tipo_producto,clavecredito from prestamos where prestamoid=pprestamoid;
	if tipo_producto <> 'N10' and tipo_producto <> 'V10' then
		select amortizacionid,numamortizacion,diasmora,fechadepago,fechadepagoreal into re from clasificacioncartera natural join amortizaciones where prestamoid=pprestamoid;
		if NOT FOUND then
			RAISE NOTICE 'not found';
			indice_amort := 1;
			capital_pagado:=0;
			select (case when pr.renovado=1 then t.cuentaactivoren else t.cuentaactivo end),(case when pr.renovado=1 then t.cuentaintmoraren else t.cuentaintmora end)  into cuentas from tipoprestamo t,prestamos pr where pr.prestamoid = pprestamoid  and t.tipoprestamoid = pr.tipoprestamoid;
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
				select sum(coalesce(haber-debe,0)) into fcapital from movipolizas where polizaid = r.polizaid and cuentaid = cuentas.cuentaactivo  and debe=0;
				select sum(coalesce(haber-debe,0)) into fmoratorio from movipolizas where polizaid = r.polizaid and cuentaid = cuentas.cuentaintmora ;
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
		end if;
	end if;
   ---By Hugo Mota, Coop. Yolomecatl
return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;