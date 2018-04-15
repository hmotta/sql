CREATE or replace FUNCTION precierre(date) RETURNS integer
    AS $_$
declare
  pfechacorte alias for $1;

  iejercicio int4;
  iperiodo   int4;

  iprocesado int4;

  r record;
  i record;
  so record;
  dcorte date;

  finteresdevengado numeric;
  finteresdevengadomenor numeric;
  fdevengadomayor numeric;
  fsaldovencidomen numeric;
  fsaldovencidomay numeric;
  idias int4;
  idiasvencidos int4;
  idiascapital int4;
  idiasinteres int4;
  dfechaprimeradeudo date;
  dultfechaexigibleint date;

  finteresdevmormenor numeric;
  finteresdevmormayor numeric;

  inoamorvencidas int4;
  scuentar char(24);
  stomaintervalo char(1);
  igeneracaptaciontotal integer;
  ifrecuencia integer;
  lUltimoPago date;
  swsostenido integer;
  dprimerpagointeres date;
  
begin

  select tomaintervalo
    into stomaintervalo
    from empresa
   where empresaid=1;

  select cuentadeposito
    into scuentar
    from tipomovimiento
   where tipomovimientoid='RG';

  dcorte := pfechacorte + 1;
  iejercicio := cast(date_part('year',pfechacorte) as int);
  iperiodo := cast(date_part('month',pfechacorte) as int);

  delete from precorte where ejercicio=iejercicio and periodo=iperiodo;   

  -- Validar que no se corra mas de una vez
  select count(*)
    into iprocesado
    from precorte
   where ejercicio = iejercicio and
         periodo = iperiodo;

  iprocesado := coalesce(iprocesado,0);
  if iprocesado>0 then
    raise exception 'La informacion para el ejercicio % y periodo % ya fue procesada anteriormente.',iejercicio,iperiodo;
  end if;

  insert into
  precorte (prestamoid,ejercicio,periodo,fechacierre,saldoprestamo,
            interesdevengadomenoravencido,interesdevengadomayoravencido,
            pagocapitalenperiodo,pagointeresenperiodo,pagomoratorioenperiodo,
            bonificacionintenperiodo,bonificacionmorenperiodo,noamorvencidas,
            saldovencidomenoravencido,saldovencidomayoravencido,
            fechaultamorpagada,tipoprestamoid,montoprestamo,clavefinalidad,tasanormal,
            tasa_moratoria,ultimoabono,diastraspasoavencida,fecha_vencimiento,
            ultimoabonointeres,interesdevmormenor,interesdevmormayor,dias_de_cobro,meses_de_cobro,frecuencia,finalidaddefault,fecha_otorga,estatusvive,depositogarantia,diasvencidos,renovado,tipo_cartera_est)

select p.prestamoid,
       iejercicio as ejercicio,
       iperiodo as periodo,
       pfechacorte as fechacierre,
       (case when p.claveestadocredito<>'002' then ( case when tp.revolvente=0 then (p.montoprestamo-(SUM(case when (m.cuentaid=tp.cuentaactivo or m.cuentaid=tp.cuentaactivoren) and po.fechapoliza<dcorte then m.haber else 0 end))) else (select spssaldoadeudolinea from spssaldoadeudolinea(p.prestamoid)) end) else 0 end) as saldoprestamo,
       0 as interesdevengadomenoravencido,
       0 as interesdevengadomayoravencido,

	   SUM(case when (m.cuentaid=tp.cuentaactivo or m.cuentaid=tp.cuentaactivoren) and po.periodo=iperiodo and po.ejercicio=iejercicio then m.haber else 0 end) as pagocapitalenperiodo,
	   SUM(case when (m.cuentaid=tp.cuentaintnormal or m.cuentaid=tp.cuentaintnormalren) and po.ejercicio=iejercicio and po.periodo=iperiodo then m.haber else 0 end) as pagointeresenperiodo,
	   SUM(case when (m.cuentaid=tp.cuentaintmora or m.cuentaid=tp.cuentaintmoraren) and po.ejercicio=iejercicio and po.periodo=iperiodo then m.haber else 0 end) as pagomoratorioenperiodo,
	   SUM(case when (m.cuentaid=tp.ordendeudornormalbonificado) and po.ejercicio=iejercicio and po.periodo=iperiodo then m.haber else 0 end) as bonificacionintenperiodo,
	   SUM(case when (m.cuentaid=tp.ordenacredornormalbonificado) and po.ejercicio=iejercicio and po.periodo=iperiodo then m.haber else 0 end) as bonificacionmorenperiodo,
		
       0 as noamorvencidas,
       0 as saldovencidomayoravencido,
       0 as saldovencidomenoravencido,
       
       ( case when tp.revolvente=0 then fechaultimapagada(p.prestamoid,pfechacorte) else NULL end) as fechaultamorpagada,
	   
       p.tipoprestamoid,p.montoprestamo,tp.clavefinalidad,p.tasanormal,p.tasa_moratoria,
	   MAX(case when ((m.cuentaid=tp.cuentaactivo or m.cuentaid=tp.cuentaactivoren) and m.haber>0) and po.fechapoliza<dcorte then po.fechapoliza else p.fecha_otorga end) AS ultimoabono,
       (case when (p.numero_de_amor=1) then 29 else (
			case when (select count(*) from amortizaciones where prestamoid=p.prestamoid and importeamortizacion<>0)=1 then -1 else 
				(case when p.dias_de_cobro=7 then 20 else 
					(case when p.dias_de_cobro=14 then 41 else 
						(case when p.dias_de_cobro=15 then 44 else 
							(case when (p.dias_de_cobro=30 or p.meses_de_cobro=1) then 89 else 59
							end)
						end)
					end)
				end)
			end)
		end) as diastraspasoavencida,
       p.fecha_vencimiento,
       MAX(case when (m.cuentaid=tp.cuentaintnormal or m.cuentaid=tp.cuentaintnormalren) and po.fechapoliza<dcorte
                then po.fechapoliza else (case when (m.cuentaid=tp.cuentaactivo or m.cuentaid=tp.cuentaactivoren) and
                                                       po.fechapoliza<dcorte
                then po.fechapoliza else p.fecha_otorga end) end) AS ultimoabonointeres,
       0 as interesdevmormenor,
       0 as interesdevmormayor,p.dias_de_cobro,p.meses_de_cobro,(case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end) as frecuencia,
	   tp.clavefinalidad,p.fecha_otorga,0 as estatusvive,p.monto_garantia,
       0 as diasvencidos,
	   p.renovado,
	   (case when p.tipo_cartera_est is not null and p.tipo_cartera_est<>'' then p.tipo_cartera_est else (select tipo_cartera_est from precorte where prestamoid=p.prestamoid order by fechacierre desc limit 1) end)

    from prestamos p left join movicaja mc on p.prestamoid=mc.prestamoid 
                     left join polizas po on mc.polizaid = po.polizaid
                     left join movipolizas m on po.polizaid=m.polizaid, 
         tipoprestamo tp
   where p.fecha_otorga <= pfechacorte and
         p.claveestadocredito<>'008' and 
         tp.tipoprestamoid = p.tipoprestamoid
group by p.prestamoid, p.tipoprestamoid,p.montoprestamo,
         p.clavefinalidad,p.tasanormal,p.tasa_moratoria,
         p.fecha_1er_pago,tp.diastraspasoavencida,p.fecha_vencimiento,p.dias_de_cobro,p.meses_de_cobro,tp.clavefinalidad,p.fecha_otorga,p.monto_garantia,p.claveestadocredito,p.numero_de_amor,p.renovado,tp.revolvente,p.tipo_cartera_est
   order by prestamoid;

   --Con los parametros calculados anteriormente se calculan los interesesdevengados y los dias vencidos (creditos ordinarios)
   ---------------------------------------------------------------------------------------------------------------------------------------------------------
   for r in
     select p.precorteid,p.saldoprestamo,p.fechaultamorpagada,p.prestamoid,
            p.ultimoabono,p.diastraspasoavencida,p.ultimoabonointeres,p.frecuencia
       from precorte p
      where p.fechacierre=pfechacorte and p.tipoprestamoid in (select tipoprestamoid from tipoprestamo where revolvente=0)
   looP
     finteresdevengadomenor := 0;
     fdevengadomayor := 0;
	 finteresdevmormenor:=0;
     finteresdevmormayor:=0;
     if r.saldoprestamo>0 then
			select fechaprimeradeudo into dfechaprimeradeudo from fechaprimeradeudo(r.prestamoid,pfechacorte);
			idiascapital:=(case when (pfechacorte-dfechaprimeradeudo) > 0 then (pfechacorte-dfechaprimeradeudo) else 0 end);
			--Poner 1 dia de mora cuando le toca pagar al cierre
			if pfechacorte=dfechaprimeradeudo then
				idiascapital:=1;
			end if;
			idiasinteres:=(case when (select fechadepago from amortizaciones where prestamoid=r.prestamoid and interesnormal>0 order by fechadepago  limit 1)<=pfechacorte then (case when (r.fechaultamorpagada-r.ultimoabonointeres)-r.frecuencia > 0 then (r.fechaultamorpagada-r.ultimoabonointeres)-r.frecuencia else 0 end) else 0 end);
			-- Asignar a los dias vencidos lo que sea mayor interes o capital 
			if idiascapital>idiasinteres then
				idiasvencidos:=idiascapital;
			else
				idiasvencidos:=idiasinteres;
			end if;
			
			if pfechacorte-r.ultimoabonointeres>0 then
				 -- Interes Normal y Moratorio
				finteresdevengadomenor := interesdevengado(r.prestamoid,pfechacorte,idiasvencidos,idiascapital,r.ultimoabonointeres,r.saldoprestamo,r.diastraspasoavencida,'S');
				finteresdevmormenor := interesdevmoratorio(r.prestamoid,pfechacorte,r.saldoprestamo,r.diastraspasoavencida,'S');
				
				--if pfechacorte-r.ultimoabonointeres>r.diastraspasoavencida then
				fdevengadomayor := interesdevengado(r.prestamoid,pfechacorte,idiasvencidos,idiascapital,r.ultimoabonointeres,r.saldoprestamo,r.diastraspasoavencida,'N');
				finteresdevmormayor := interesdevmoratorio(r.prestamoid,pfechacorte,r.saldoprestamo,r.diastraspasoavencida,'N');
				--end if;
		   end if;
			
			update precorte set interesdevengadomenoravencido=finteresdevengadomenor,interesdevengadomayoravencido=fdevengadomayor,interesdevmormenor=finteresdevmormenor,
				interesdevmormayor=finteresdevmormayor,diascapital=idiascapital,diasinteres=idiasinteres,diasvencidos=idiasvencidos where precorteid=r.precorteid;
			
			if idiasvencidos>r.diastraspasoavencida then
				update precorte set saldovencidomenoravencido=0, saldovencidomayoravencido=saldoprestamo where precorteid=r.precorteid;
			else
				update precorte set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where precorteid=r.precorteid;
			end if;
     end if;
	 update precorte set saldopromediodelmes=saldopromedioprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo) where fechacierre=pfechacorte and prestamoid=r.prestamoid;
	 update precorte set interesdevengadomes=interesdevengadoprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo) where fechacierre=pfechacorte and prestamoid=r.prestamoid; 
     update precorte set primerincumplimiento=fechaultamorpagada+frecuencia where fechacierre=pfechacorte and prestamoid=r.prestamoid;
	 
	 update precorte set pagosvencidos = (select (case when diasvencidos=0 then 0 else (case when diasvencidos>0 and diasvencidos<=diastraspasoavencida then 1 else 2 end) end)) where fechacierre=pfechacorte;
   
	 update precorte set  importeultimaamort=coalesce((select importeamortizacion from amortizaciones where prestamoid=precorte.prestamoid and fechadepago=precorte.fechaultamorpagada),(select min(importeamortizacion) from amortizaciones where prestamoid=precorte.prestamoid )) where fechacierre=pfechacorte;

	 update precorte set  importevencidoamort=coalesce(((select sum(importeamortizacion-abonopagado) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<=precorte.fechacierre)-(select coalesce(sum(importeamortizacion-abonopagado),0) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<precorte.fechaultamorpagada)),0) where fechacierre=pfechacorte;

	 update precorte set noamorvencidas=(select count(*) from amortizaciones where prestamoid=precorte.prestamoid and importeamortizacion<>abonopagado and fechadepago<=precorte.fechacierre) where fechacierre>=pfechacorte;
   
   end loop;
   
   
   --Con los parametros calculados anteriormente se calculan los interesesdevengados y los dias vencidos (Lineas de crédito)
   ---------------------------------------------------------------------------------------------------------------------------------------------------------
   for r in
     select p.precorteid,p.saldoprestamo,p.fechaultamorpagada,p.prestamoid,
            p.ultimoabono,p.diastraspasoavencida,p.ultimoabonointeres,p.frecuencia
       from precorte p
      where p.fechacierre=pfechacorte and p.tipoprestamoid in (select tipoprestamoid from tipoprestamo where revolvente=1)
   loop
     finteresdevengadomenor := 0;
     fdevengadomayor := 0;
	 finteresdevmormenor:=0;
     finteresdevmormayor:=0;
     if r.saldoprestamo>0 then
			select int_ord_dev_balance,int_ord_dev_cuent_orden,int_mor_dev_balance,int_mor_dev_cuent_orden,dias_capital,dias_interes into finteresdevengadomenor,fdevengadomayor,finteresdevmormenor,finteresdevmormayor,idiascapital,idiasinteres from corte_linea where fecha_corte=pfechacorte and lineaid=r.prestamoid;
			-- Asignar a los dias vencidos lo que sea mayor interes o capital 
			if idiascapital>idiasinteres then
				idiasvencidos:=idiascapital;
			else
				idiasvencidos:=idiasinteres;
			end if;
			update precorte set interesdevengadomenoravencido=finteresdevengadomenor,interesdevengadomayoravencido=fdevengadomayor,interesdevmormenor=finteresdevmormenor,
				interesdevmormayor=finteresdevmormayor,diascapital=idiascapital,diasinteres=idiasinteres,diasvencidos=idiasvencidos where precorteid=r.precorteid;
			
			if idiasvencidos>r.diastraspasoavencida then
				update precorte set saldovencidomenoravencido=0, saldovencidomayoravencido=saldoprestamo where precorteid=r.precorteid;
			else
				update precorte set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where precorteid=r.precorteid;
			end if;
     end if;
	 update precorte set saldopromediodelmes=(select saldo_promedio from corte_linea where prestamoid=r.prestamoid and fecha_corte=pfechacorte) where fechacierre=pfechacorte and prestamoid=r.prestamoid;
	 update precorte set interesdevengadomes=(select int_ord_dev_balance+int_ord_dev_cuent_orden from corte_linea where prestamoid=r.prestamoid and fecha_corte=pfechacorte) where fechacierre=pfechacorte and prestamoid=r.prestamoid; 
     update precorte set primerincumplimiento=(select fecha_limite from corte_linea where fecha_corte<=(select fecha_corte from corte_linea where capital_vencido>0 and lineaid=r.prestamoid order by fecha_corte limit 1) and lineaid=r.prestamoid order by fecha_corte limit 1) where fechacierre=pfechacorte and prestamoid=r.prestamoid;
	 
	 update precorte set pagosvencidos = (select (case when diasvencidos=0 then 0 else (case when diasvencidos>0 and diasvencidos<=diastraspasoavencida then 1 else 2 end) end)) where fechacierre=pfechacorte;
   
	 update precorte set  importeultimaamort=coalesce((select capital from corte_linea where lineaid=precorte.prestamoid and fecha_corte<=precorte.fechacierre order by fecha_corte desc limit 1),0) where fechacierre=pfechacorte;

	 update precorte set  importevencidoamort=coalesce((select (capital+coalesce(capital_vencido,0)) from corte_linea where lineaid=precorte.prestamoid and (capital-capital_pagado)>0 and fecha_limite<=precorte.fechacierre and estatus=1 order by fecha_corte desc limit 1),0) where fechacierre=pfechacorte;

	 update precorte set noamorvencidas=(select count(*) from corte_linea where lineaid=precorte.prestamoid and (capital-capital_pagado)>0 and fecha_limite<=precorte.fechacierre and estatus=1) where fechacierre>=pfechacorte;
   end loop;
   
   delete from precorte  where fechacierre=pfechacorte and saldoprestamo=0 and interesdevengadomenoravencido=0 and interesdevengadomayoravencido=0 and pagocapitalenperiodo=0 and pagointeresenperiodo=0 and pagomoratorioenperiodo=0 and saldovencidomenoravencido=0 and saldovencidomayoravencido=0;
   
   
   
   update precorte set diascapital = 0 where fechacierre=pfechacorte and diascapital=0 and saldoprestamo=0;
   update precorte set diascapital = 0 where fechacierre=pfechacorte and saldoprestamo=0;
   --and primerincumplimiento > (fecha_otorga+frecuencia);

   -- Los que no han pagado nada dias capital

   --update precorte set diascapital = (case when (fechacierre-fechaultamorpagada) > 0 then (fechacierre-fechaultamorpagada) else 0 end) where fechacierre=pfechacorte and primerincumplimiento <= (fecha_otorga+frecuencia);

	-- Establecer el tipo de cartera para efectos de la estimación
	--Comercial
	--update precorte set tipocartera='13' where finalidaddefault='001' and fechacierre=pfechacorte;
	--Consumo
	update precorte set tipocartera='10' where finalidaddefault='002' and fechacierre=pfechacorte;
	--update precorte set tipo_cartera_est='tipo 1' where finalidaddefault='002' and fechacierre=pfechacorte;
	--Hipotecarios (no se utiliza)
		--002

	--Vivienda (no se utiliza)
	--update precorte set tipocartera='16' where finalidaddefault='003' and fechacierre=pfechacorte;
	
	
   -- Borrar el moratorio devengado de los que no tienen atraso

   update precorte
     set interesdevmormenor=0,interesdevmormayor=0
     where fechacierre=pfechacorte and diasvencidos=0;
   
-->>
-- Validar los creditos reestructurados 

   for r in
     select p.precorteid,p.saldoprestamo,p.fechaultamorpagada,p.prestamoid,p.tipoprestamoid,
            p.ultimoabono,p.diastraspasoavencida,p.frecuencia,p.diasvencidos,pr.pagosostenido,pr.diasmoraorigen,pr.renovado
       from precorte p, prestamos pr
      where p.prestamoid=pr.prestamoid and p.fechacierre=pfechacorte and (p.tipoprestamoid in (select tipoprestamores from tipoprestamo group by tipoprestamores) or pr.renovado=1)

   loop

     --update precorte set diastraspasoavencida = -1 where precorteid=r.precorteid;
     -- Cambiando a cartera reestructurada.
	 if (r.tipoprestamoid = 'T2') then -- si es un credito reestructurado se pone como Tipo II para la Estimacion
		update precorte set tipocartera='11' where precorteid=r.precorteid and finalidaddefault='002';
		--update precorte set tipo_cartera_est='tipo 2' where precorteid=r.precorteid;
	end if;
	
	if (r.renovado=1 and r.diasmoraorigen>0) then --si es renovado emproblemado
		update precorte set tipocartera='11' where precorteid=r.precorteid and finalidaddefault='002';
		--update precorte set tipo_cartera_est='tipo 2' where precorteid=r.precorteid;
	end if;

     -- Verificar el pago sostenido por tres ocasiones a capital
      		--Dias vencidos
		if r.pagosostenido<3 then
			--select diasvencidos into idiasvencidos from precorte where fechacierre=pfechacorte and prestamoid=r.prestamoid;
			idiasvencidos:=r.diasvencidos+(select diasmoraorigen from prestamos where prestamoid=r.prestamoid);
			update precorte set diasvencidos = idiasvencidos where fechacierre=pfechacorte and prestamoid=r.prestamoid;
			if idiasvencidos>r.diastraspasoavencida then
				update precorte set saldovencidomenoravencido=0, saldovencidomayoravencido=saldoprestamo where precorteid=r.precorteid;
			end if;
			
		end if;
     
   end loop;
--<<--
	
	for r in 
		select e.prestamoid,precorteid from emproblemados e, precorte p where p.prestamoid=e.prestamoid and p.fechacierre=pfechacorte
	loop
		update precorte set tipocartera='11' where precorteid=r.precorteid;
		--update precorte set tipo_cartera_est='tipo 2' where precorteid=r.precorteid;
	end loop;
	
	--for r in 
	--	select prestamoid from prestamos where socioid in (select socioid from precorte p inner join prestamos pr on (p.prestamoid=pr.prestamoid) where p.tipo_cartera_est='tipo 2' limit 1)
	--loop
	--	update precorte set tipocartera='11' where prestamoid=r.prestamoid and fechacierre=pfechacorte;
	--	update precorte set tipo_cartera_est='tipo 2' where prestamoid=r.prestamoid and fechacierre=pfechacorte;
	--end loop;

	--Correccion de reestructurado vigente en arteaga (le pagaron el mismo dia de la reestructura)
	--update precorte set diascapital=174,diasvencidos=174 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('015155-S')) and fechacierre=pfechacorte and exists (select sucid from empresa where sucid='005-');
	
   
   
   -- Asignar porcentaje de reserva
	--calculo anterior
   /*for r in
     select p.precorteid,t.porcentajereserva,
			t.factordisminucion,t.tablareservaid,p.prestamoid,
            p.diasvencidos,p.finalidaddefault,p.tipocartera,p.depositogarantia,p.saldovencidomenoravencido,p.saldovencidomayoravencido,(case when  p.diasvencidos <= p.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as devengadovigente
       from precorte p, tablareserva t
      where p.fechacierre=pfechacorte and p.finalidaddefault=t.finalidaddefault and p.tipocartera=t.tipocartera and
            p.diasvencidos>=t.diainicial and
            p.diasvencidos<=t.diafinal
   loop
        update precorte set tablareservaid = r.tablareservaid,
            porcentajeaplicado=r.porcentajereserva,
            reservacalculada=(r.depositogarantia-(trunc(r.depositogarantia/500)*500))*(select min(porcentajereserva) from tablareserva where tipocartera=r.tipocartera),
            reservaidnc=(r.saldovencidomenoravencido+r.saldovencidomayoravencido+r.devengadovigente-(r.depositogarantia-(trunc(r.depositogarantia/500)*500)))*r.porcentajereserva,
            factoraplicado=r.factordisminucion
        where precorteid=r.precorteid;
   end loop;*/
   
   --nuevo calculo 2017/05/11
   for r in
     select p.precorteid,
			t.porcentajereserva,
			t.tablareservaid,
			p.prestamoid,
            p.diasvencidos,
			p.finalidaddefault,
			p.tipocartera,
			(p.saldovencidomenoravencido+p.saldovencidomayoravencido) as total_capital,
			(case when  p.diasvencidos <= p.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as total_devengadovigente,
			(case when  p.diasvencidos <= p.diastraspasoavencida then 0 else interesdevengadomenoravencido+interesdevmormenor end) as total_devengadovencido
       from precorte p, tablareserva t
      where p.fechacierre=pfechacorte and p.finalidaddefault=t.finalidaddefault and p.tipocartera=t.tipocartera and
            p.diasvencidos>=t.diainicial and
            p.diasvencidos<=t.diafinal
   loop
        update precorte set 
			tablareservaid = r.tablareservaid,
            porcent_eprc=r.porcentajereserva,
            monto_eprc_cap=(r.total_capital+r.total_devengadovigente)*r.porcentajereserva,
            monto_eprc_intven=r.total_devengadovencido,
			total_eprc=((r.total_capital+r.total_devengadovigente)*r.porcentajereserva)+r.total_devengadovencido
        where precorteid=r.precorteid;
   end loop;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;