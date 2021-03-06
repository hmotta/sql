CREATE OR REPLACE FUNCTION interesdevmoratorio(integer, date, numeric, integer, character) RETURNS numeric
    AS $_$
declare
	pprestamoid alias for $1;
	pfechacorte alias for $2;
	fsaldoinsoluto alias for $3;
	pdiastraspasovencida alias for $4;
	pmenorvencido alias for $5;

	fpagado numeric;
	fmoratorio numeric;
	fmormenor numeric;
	fmormayor numeric;
	ftasamoratorio numeric;
	r record;
	diasdespuesdevencido int4;
	diasvencidosletra int4;
	diasvencidosmenor int4;
	diasvencidosmayor int4;
	dfechaprimeradeudo date;
	sclaveestadocredito char(3);
	nrevolvente integer;
	dultimo_pago_capital date;
	
	dfechaf date;
	dfechai date;
	i integer;
	ncortes_vencidos integer;
	pdiastraspasovencida_linea integer;
begin

	--raise notice 'Procesando PrestamoID=%',pprestamoid;

	fmoratorio := 0;
	fmormenor := 0;
	fmormayor := 0;

	select p.montoprestamo-fsaldoinsoluto,p.tasa_moratoria,
		p.claveestadocredito,t.revolvente
	into fpagado,ftasamoratorio,sclaveestadocredito,nrevolvente
	from prestamos p, tipoprestamo t
	where p.prestamoid = pprestamoid and
		t.tipoprestamoid = p.tipoprestamoid;

	select max(po.fechapoliza) into dultimo_pago_capital from polizas po,movipolizas mp,prestamos p,cat_cuentas_tipoprestamo ct  where po.polizaid=mp.polizaid and mp.prestamoid=p.prestamoid and (ct.cat_cuentasid = p.cat_cuentasid) and mp.haber>0 and p.prestamoid=pprestamoid and (mp.cuentaid = ct.cta_cap_vig) and po.fechapoliza<=pfechacorte;
	
	-- Calcular solo para los prestamos activos

	if sclaveestadocredito='001' then
		if nrevolvente=0 then 
			--se busca la fecha mas antigua de letras incumplidas
			select min(fechadepago) into dfechaprimeradeudo from amortizaciones
			where prestamoid=pprestamoid and fechadepago<pfechacorte and importeamortizacion<>abonopagado;
			--se sacan los dias mayor a vencidos de la letra mas antigua es decir 1 dia si tiene 90, 2 si tiene 91,etc... con base a 89 dias --diasdespuesdevencido ya no cambia su valor
			if dfechaprimeradeudo<dultimo_pago_capital then
				dfechaprimeradeudo:=dultimo_pago_capital;
			end if;
			diasvencidosletra:=pfechacorte-dfechaprimeradeudo;
			
			if diasvencidosletra>pdiastraspasovencida then
				diasdespuesdevencido:=diasvencidosletra-pdiastraspasovencida;
			else
				diasdespuesdevencido:=0;
			end if;
			
			-- Recorrer amortizaciones para ver cuales son las no cubiertas
			-- ya vencidas
			for r in
				select * from amortizaciones
				where prestamoid=pprestamoid and fechadepago<pfechacorte
				order by fechadepago
			loop
				if fpagado<r.importeamortizacion then
					if r.fechadepago<pfechacorte then
						-- Calcular moratorio
						if r.fechadepago<dultimo_pago_capital then
							diasvencidosletra:= pfechacorte-dultimo_pago_capital;
						else
							diasvencidosletra:= pfechacorte-r.fechadepago;
						end if;
						--se calculan los diasvencidosmenor si la letra mayor tiene 120 la deja en 89 y el resto en el que le corresponda
						if (diasvencidosletra-diasdespuesdevencido)>0 then
							diasvencidosmenor:= diasvencidosletra-diasdespuesdevencido;
						else
							diasvencidosmenor:= 0;
						end if;

						--los dias vencidos mayor son los dias despues de vencida la letra y se van adicionando las letras que vayan cayendo
						diasvencidosmayor:= diasvencidosletra - diasvencidosmenor;
						if pmenorvencido='S'  then
							fmormenor := fmormenor+(r.importeamortizacion-fpagado)*diasvencidosmenor*ftasamoratorio/100/360;  
						else
							fmormayor := fmormayor+(r.importeamortizacion-fpagado)*diasvencidosmayor*ftasamoratorio/100/360;
						end if;
						fpagado:=0;
					end if;
				else
					fpagado := fpagado - r.importeamortizacion;
				end if;

			end loop;

			if pmenorvencido='S' then
				fmoratorio:=trunc(coalesce(fmormenor,0),6);
			else
				fmoratorio:=trunc(coalesce(fmormayor,0),6);
			end if;
		else
			--se busca la fecha mas antigua de los cortes incumplidas
			select min(fecha_limite) into dfechaprimeradeudo from corte_linea
			where lineaid=pprestamoid and fecha_limite<pfechacorte and (capital-capital_pagado)>0;
			raise notice 'dfechaprimeradeudo=%',dfechaprimeradeudo;
			dfechai:=dfechaprimeradeudo+1;
			
			select count(*) into ncortes_vencidos from corte_linea where (capital-capital_pagado)>0 and lineaid=pprestamoid and fecha_limite<pfechacorte;
			raise notice 'ncortes_vencidos=%',ncortes_vencidos;
			i:=0;
			if ncortes_vencidos>=2 then
				for r in 
					select fecha_limite from corte_linea where (capital-capital_pagado)>0 and 	lineaid=pprestamoid order by fecha_limite
				loop
					i:=i+1;
					if i=2 then
						dfechaf:=r.fecha_limite;
						dfechaf:=dfechaf+1;
						exit;
					end if;
				end loop;
				raise notice 'dfechai=%',dfechai;
				raise notice 'dfechaf=%',dfechaf;
				pdiastraspasovencida_linea:=dfechaf-dfechai;
			else
				pdiastraspasovencida_linea:=29;
			end if;
			
			
			raise notice 'pdiastraspasovencida=%',pdiastraspasovencida_linea;
			
			--se sacan los dias mayor a vencidos de la letra mas antigua es decir 1 dia si tiene 90, 2 si tiene 91,etc... con base a 89 dias --diasdespuesdevencido ya no cambia su valor
			if dfechaprimeradeudo<dultimo_pago_capital then
				dfechaprimeradeudo:=dultimo_pago_capital;
			end if;
			diasvencidosletra:=pfechacorte-dfechaprimeradeudo;
			raise notice 'dfechaprimeradeudo=%',dfechaprimeradeudo;
			if diasvencidosletra>pdiastraspasovencida_linea then
				diasdespuesdevencido:=diasvencidosletra-pdiastraspasovencida_linea;
			else
				diasdespuesdevencido:=0;
			end if;
			
			-- Recorrer corte_linea para ver cuales son las no cubiertas
			-- ya vencidas
			for r in
				select * from corte_linea
				where lineaid=pprestamoid and fecha_limite<pfechacorte and (capital-capital_pagado)>0
				order by fecha_limite
			loop
				--if fpagado<r.capital then
					--if r.fecha_limite<pfechacorte then
						-- Calcular moratorio
						if r.fecha_limite<dultimo_pago_capital then
							diasvencidosletra:= pfechacorte-dultimo_pago_capital;
						else
							diasvencidosletra:= pfechacorte-r.fecha_limite;
						end if;
						--se calculan los diasvencidosmenor si la letra mayor tiene 120 la deja en 89 y el resto en el que le corresponda
						if (diasvencidosletra-diasdespuesdevencido)>0 then
							diasvencidosmenor:= diasvencidosletra-diasdespuesdevencido;
						else
							diasvencidosmenor:= 0;
						end if;
						raise notice 'diasvencidosmenor=%',diasvencidosmenor;
						
						--los dias vencidos mayor son los dias despues de vencida la letra y se van adicionando las letras que vayan cayendo
						diasvencidosmayor:= diasvencidosletra - diasvencidosmenor;
						raise notice 'diasvencidosmayor=%',diasvencidosmayor;
						if pmenorvencido='S'  then
							fmormenor := fmormenor+(r.capital-r.capital_pagado)*diasvencidosmenor*ftasamoratorio/100/360;  
						else
							fmormayor := fmormayor+(r.capital-r.capital_pagado)*diasvencidosmayor*ftasamoratorio/100/360;
						end if;
						--fpagado:=0;
					--end if;
				--else
				--	fpagado := fpagado - r.capital;
				--end if;

			end loop;

			if pmenorvencido='S' then
				fmoratorio:=trunc(coalesce(fmormenor,0),6);
			else
				fmoratorio:=trunc(coalesce(fmormayor,0),6);
			end if;
		end if;
	end if;

return fmoratorio;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;