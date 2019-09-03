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

  finteresdevmormenor numeric;
  finteresdevmormayor numeric;

  inoamorvencidas int4;

  scuentar char(24);

  stomaintervalo char(1);
  igeneracaptaciontotal integer;

  periododemenos integer;
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
            diasvencidos,
            interesdevengadomenoravencido,interesdevengadomayoravencido,
            pagocapitalenperiodo,pagointeresenperiodo,pagomoratorioenperiodo,
            bonificacionintenperiodo,bonificacionmorenperiodo,noamorvencidas,
            saldovencidomenoravencido,saldovencidomayoravencido,
            fechaultamorpagada,tipoprestamoid,montoprestamo,clavefinalidad,tasanormal,
            tasa_moratoria,ultimoabono,diastraspasoavencida,fecha_vencimiento,
            ultimoabonointeres,interesdevmormenor,interesdevmormayor,dias_de_cobro,meses_de_cobro,frecuencia,finalidaddefault,fecha_otorga,estatusvive,depositogarantia)

select p.prestamoid,
       iejercicio as ejercicio,
       iperiodo as periodo,
       pfechacorte as fechacierre,
       (case when p.claveestadocredito<>'002' then (p.montoprestamo-(SUM(case when m.cuentaid=tp.cuentaactivo and
                                     po.fechapoliza<dcorte
                                then m.haber else 0 end))) else 0 end) as saldoprestamo,
       0 as diasvencidos,
       0 as interesdevengadomenoravencido,
       0 as interesdevengadomayoravencido,

       SUM(case when m.cuentaid=tp.cuentaactivo and
                     po.periodo=iperiodo and po.ejercicio=iejercicio 
                then m.haber else 0 end) as pagocapitalenperiodo,
       SUM(case when m.cuentaid=tp.cuentaintnormal and
                     po.ejercicio=iejercicio and po.periodo=iperiodo 
                then m.haber else 0 end) as pagointeresenperiodo,
       SUM(case when m.cuentaid=tp.cuentaintmora and
                     po.ejercicio=iejercicio and po.periodo=iperiodo 
                then m.haber else 0 end) as pagomoratorioenperiodo,       
       SUM(case when m.cuentaid=tp.ordendeudornormalbonificado and
                     po.ejercicio=iejercicio and po.periodo=iperiodo 
                then m.haber else 0 end) as bonificacionintenperiodo, 
       SUM(case when m.cuentaid=tp.ordenacredornormalbonificado and
                     po.ejercicio=iejercicio and po.periodo=iperiodo 
                then m.haber else 0 end) as bonificacionmorenperiodo,                
                
       0 as noamorvencidas,
       0 as saldovencidomayoravencido,
       0 as saldovencidomenoravencido,
       
       fechaultimapagada(p.prestamoid,pfechacorte)as fechaultamorpagada,
	   
       p.tipoprestamoid,p.montoprestamo,tp.clavefinalidad,p.tasanormal,p.tasa_moratoria,
       MAX(case when m.cuentaid=tp.cuentaactivo and po.fechapoliza<dcorte
                then po.fechapoliza else p.fecha_otorga end),
       tp.diastraspasoavencida,
       p.fecha_vencimiento,
       MAX(case when m.cuentaid=tp.cuentaintnormal and po.fechapoliza<dcorte
                then po.fechapoliza else (case when m.cuentaid=tp.cuentaactivo and
                                                       po.fechapoliza<dcorte
                then po.fechapoliza else p.fecha_otorga end) end),
       0 as interesdevmormenor,
       0 as interesdevmormayor,p.dias_de_cobro,p.meses_de_cobro,(case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end),tp.clavefinalidad,p.fecha_otorga,0 as estatusvive,p.monto_garantia

    from prestamos p left join movicaja mc on p.prestamoid=mc.prestamoid 
                     left join polizas po on mc.polizaid = po.polizaid
                     left join movipolizas m on po.polizaid=m.polizaid, 
         tipoprestamo tp
   where p.fecha_otorga <= pfechacorte and
         p.claveestadocredito<>'008' and 
         tp.tipoprestamoid = p.tipoprestamoid
group by p.prestamoid, p.tipoprestamoid,p.montoprestamo,
         p.clavefinalidad,p.tasanormal,p.tasa_moratoria,
         p.fecha_1er_pago,tp.diastraspasoavencida,p.fecha_vencimiento,p.dias_de_cobro,p.meses_de_cobro,tp.clavefinalidad,p.fecha_otorga,p.monto_garantia,p.claveestadocredito
   order by prestamoid;

   for r in
     select p.precorteid,p.saldoprestamo,p.fechaultamorpagada,p.prestamoid,
            p.ultimoabono,p.diastraspasoavencida,p.ultimoabonointeres
       from precorte p
      where p.fechacierre=pfechacorte

   loop

     -- Clasificacion de interes devengado

     finteresdevengadomenor := 0;
     fdevengadomayor := 0;
	 finteresdevmormenor:=0;
     finteresdevmormayor:=0;
	  
     --raise notice 'ultima amortizacion  %  %  %',r.prestamoid,r.fechaultamorpagada,periododemenos;

     if r.saldoprestamo>0 then

       if pfechacorte-r.ultimoabonointeres>0 then

         --
         -- Interes Normal y Moratorio
         --

         finteresdevengadomenor := interesdevengado(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo,'S');

         if pfechacorte-r.fechaultamorpagada-periododemenos>0 and r.saldoprestamo>0 then
		--if pfechacorte-r.fechaultamorpagada>0 and r.saldoprestamo>0 then
           
             finteresdevmormenor := interesdevmoratorio(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo,'S');
             finteresdevmormenor := 0;

         else
           finteresdevmormenor:=0;
         end if;

         if pfechacorte-r.ultimoabonointeres>r.diastraspasoavencida then
 
           fdevengadomayor := interesdevengado(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo,'N');

           if pfechacorte-r.fechaultamorpagada-periododemenos>0 and r.saldoprestamo>0 then
			--if pfechacorte-r.fechaultamorpagada>0 and r.saldoprestamo>0 then
             finteresdevmormayor := interesdevmoratorio(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo,'N');
             finteresdevmormayor := 0;
           else
             finteresdevmormayor := 0;
           end if;
         end if;

       end if;

     end if;

     update precorte
        set interesdevengadomenoravencido=finteresdevengadomenor,
            interesdevengadomayoravencido=fdevengadomayor,           
            interesdevmormenor = finteresdevmormenor,
            interesdevmormayor = finteresdevmormayor
      where precorteid=r.precorteid;

      

        
   end loop;
   
   delete from precorte  where fechacierre=pfechacorte and saldoprestamo=0 and interesdevengadomenoravencido=0 and interesdevengadomayoravencido=0 and pagocapitalenperiodo=0 and pagointeresenperiodo=0 and pagomoratorioenperiodo=0 and saldovencidomenoravencido=0 and saldovencidomayoravencido=0;
   
   update precorte set saldopromediodelmes=saldopromedioprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo);

   update precorte set interesdevengadomes=interesdevengadoprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo); 

   update precorte set primerincumplimiento=fechaultamorpagada+frecuencia where fechacierre=pfechacorte;

   -- Dias vencidos capital
   
   update precorte set diascapital = (case when (fechacierre-(select fechaprimeradeudo from fechaprimeradeudo(precorte.prestamoid,pfechacorte))) > 0 then (fechacierre-(select fechaprimeradeudo from fechaprimeradeudo(precorte.prestamoid,pfechacorte))) else 0 end), diasinteres=0  where fechacierre=pfechacorte and saldoprestamo>0;
   
   --Poner 1 dia de mora cuando le toca pagar al cierre
   --update precorte set diascapital = (case when fechacierre=(select fechaprimeradeudo from fechaprimeradeudo(precorte.prestamoid,pfechacorte)) then 1 else diascapital end) where fechacierre=pfechacorte and diascapital=0 and saldoprestamo>0;
   
   update precorte set diascapital = 0 where fechacierre=pfechacorte and diascapital=0 and saldoprestamo=0;
   update precorte set diascapital = 0 where fechacierre=pfechacorte and saldoprestamo=0;
   --and primerincumplimiento > (fecha_otorga+frecuencia);

   -- Los que no han pagado nada dias capital

   --update precorte set diascapital = (case when (fechacierre-fechaultamorpagada) > 0 then (fechacierre-fechaultamorpagada) else 0 end) where fechacierre=pfechacorte and primerincumplimiento <= (fecha_otorga+frecuencia);

   -- Dias de interes vencido

   -- Los dias de interes interes vencidos
   
   update precorte set diasinteres = (case when (select fechadepago from amortizaciones where prestamoid=precorte.prestamoid and interesnormal>0 order by fechadepago limit 1)<=pfechacorte then (case when (fechaultamorpagada-ultimoabonointeres)-frecuencia > 0 then (fechaultamorpagada-ultimoabonointeres)-frecuencia else 0 end) else 0 end), estatusvive=3 where fechacierre=pfechacorte;
	
   -- Asignar a los dias vencido lo que sea mayor interes o capital para los que no van adelantados.

   --update precorte set diasvencidos = (case when diasinteres > diascapital and (fechaultamorpagada-ultimoabonointeres)>frecuencia and diascapital > 0  then diasinteres else diascapital end) where fechacierre=pfechacorte;
   update precorte set diasvencidos = (case when diasinteres > diascapital and (fechaultamorpagada-ultimoabonointeres)>frecuencia  then diasinteres else diascapital end) where fechacierre=pfechacorte;

   -- Los etiquetados como renovados y reestructurados

  -- update precorte set diasvencidos=diasvencidos+diastraspasoavencida
    -- where fechacierre=pfechacorte and  tipoprestamoid
    -- in ('I1','T1','T2','T3','R1','R2','R3');

	-- Establecer el tipo de cartera para efectos de la estimación
	--Comercial
	update precorte set tipocartera='13' where finalidaddefault='001' and fechacierre=pfechacorte;
	--Consumo
	update precorte set tipocartera='10' where finalidaddefault='002' and fechacierre=pfechacorte;
	--Hipotecarios
		--002
		update precorte set tipocartera=12 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('006772-','006770-','006771-')) and fechacierre=pfechacorte and exists (select sucid from empresa where sucid='002-');
		--005
		update precorte set tipocartera=12 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('010019-','003922-','011608-','010452-')) and fechacierre=pfechacorte and exists (select sucid from empresa where sucid='005-');
		--003
		update precorte set tipocartera=12 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('010452-')) and fechacierre=pfechacorte and exists (select sucid from empresa where sucid='003-');

	--Vivienda
	update precorte set tipocartera='16' where finalidaddefault='003' and fechacierre=pfechacorte;
	
	
   -- Borrar el moratorio devengado de los que no tienen atraso

   update precorte
     set interesdevmormenor=0,interesdevmormayor=0
     where fechacierre=pfechacorte and diasvencidos=0;
   
-->>
-- Validar los creditos reestructurados se agrega en la revisión CNBV

   for r in
     select p.precorteid,p.saldoprestamo,p.fechaultamorpagada,p.prestamoid,p.tipoprestamoid,
            p.ultimoabono,p.diastraspasoavencida,p.ultimoabonointeres,p.frecuencia
       from precorte p
      where p.fechacierre=pfechacorte and p.tipoprestamoid in (select tipoprestamores from tipoprestamo group by tipoprestamores)

   loop

     --update precorte set diastraspasoavencida = -1 where precorteid=r.precorteid;
     -- Cambiando a cartera reestructurada.
     update precorte set tipocartera='11' where precorteid=r.precorteid and finalidaddefault='002';
	
	
     
     -- Verificar el pago sostenido por tres ocasiones a capital
      
     if (select count(movicajaid) from movicaja mc, polizas p, movipolizas mp where mc.prestamoid=r.prestamoid and mc.polizaid=p.polizaid and mc.polizaid=mp.polizaid and p.fechapoliza<=pfechacorte and mp.cuentaid = (select cuentaactivo from tipoprestamo where tipoprestamoid=r.tipoprestamoid)) >= 3 then

       swsostenido:=0;
       
        -- recorrer los ultimos 3 pagos
       for so in select p.fechapoliza,mp.haber from movicaja mc, polizas p, movipolizas mp where mc.prestamoid=r.prestamoid and mc.polizaid=p.polizaid and mc.polizaid=mp.polizaid and p.fechapoliza<=pfechacorte and mp.cuentaid = (select cuentaactivo from tipoprestamo where tipoprestamoid=r.tipoprestamoid) order by p.fechapoliza desc
       loop

           if so.fechapoliza =(select fechadepago from amortizaciones where prestamoid=r.prestamoid and fechadepago=so.fechapoliza) and so.haber >= (select importeamortizacion from amortizaciones where prestamoid=r.prestamoid and fechadepago=so.fechapoliza) then
				raise notice 'swsostenido = % ',swsostenido;
                swsostenido:=swsostenido+1;
           end if;
       end loop;

       if swsostenido >=3 then
          
           update precorte set diastraspasoavencida=30 where precorteid=r.precorteid and prestamoid in (select prestamoid from prestamos where prestamoid=r.prestamoid and condicionid=1);
           
           update precorte set diastraspasoavencida=89 where precorteid=r.precorteid and prestamoid in (select prestamoid from prestamos where prestamoid=r.prestamoid and condicionid in (3,2));
           --Cambio a cartera reestructurada en comercial
           
       end if;
     else
		--Dias vencidos
		update precorte set diasvencidos = diasvencidos+(select diasreestructura from diasreestructura(r.prestamoid)) where fechacierre=pfechacorte and prestamoid=r.prestamoid;
     end if;

     
   end loop;
--<<--

	--Correccion de reestructurado vigente en arteaga (le pagaron el mismo dia de la reestructura)
	update precorte set diascapital=63,diasvencidos=63 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('010774-S')) and fechacierre=pfechacorte and exists (select sucid from empresa where sucid='003-');
	--update precorte set diascapital=174,diasvencidos=174 where prestamoid in (select prestamoid from prestamos where referenciaprestamo in ('015155-S')) and fechacierre=pfechacorte and exists (select sucid from empresa where sucid='005-');
	
   -->>Se agrega a vigente o vencida de acuerdo a la variable diasvencidos
	
	------> pr.condicionid=3 'Pagos periodicos de principal e intereses'
	---------> Semanales Vigentes
	update precorte p set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=7 and diasvencidos<21;
	---------> Semanales Vencidos
	update precorte p set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=7 and diasvencidos>=21;
	
	update precorte p set diastraspasoavencida=20 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=7 and tipoprestamoid not in ('T1','T2','T3','R1','R2','R3');
	
	---------> Catorcenales Vigentes
	update precorte p set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=14 and diasvencidos<42;
	---------> Catorcenales Vencidos
	update precorte p set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=14 and diasvencidos>=42;
	
	---------------> updetear dias trasoaso vencida de acuerdo a la frecuencia (por los demás cálculos)
	update precorte p set diastraspasoavencida=41 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=14 and tipoprestamoid not in ('T1','T2','T3','R1','R2','R3');
	
	---------> Quincenales Vigentes
	update precorte p set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=15 and diasvencidos<45;
	---------> Quincenales Vencidos
	update precorte p set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=15 and diasvencidos>=45;
	
	update precorte p set diastraspasoavencida=44 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia=15 and tipoprestamoid not in ('T1','T2','T3','R1','R2','R3');
	
	---------> Distintos a (Semanal,Catorcenal,Quincenal) Vigentes
	update precorte p set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia not in (7,14,15) and diasvencidos<90;
	---------> Distintos a (Semanal,Catorcenal,Quincenal) Vencidos
	update precorte p set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and  frecuencia not in (7,14,15) and diasvencidos>=90;
	
	update precorte p set diastraspasoavencida=89 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)>1 and frecuencia not in (7,14,15) and  tipoprestamoid not in ('T1','T2','T3','R1','R2','R3');
	
	------> pr.condicionid=1 'Pago unico de principal e intereses'
	---------> Vigentes
	update precorte p set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)=1 and  diasvencidos<30;
	---------> Vencidos
	update precorte p set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)=1 and  diasvencidos>=30;
	
	--update precorte set p.diastraspasoavencida=30 where fechacierre=pfechacorte and (select numero_de_amor from prestamos where prestamoid=p.prestamoid)=1 and  frecuencia=15 and diasvencidos>=30 and  tipoprestamoid not in ('T1','T2','T3','R1','R2','R3');
	
	------> pr.condicionid=2 'Pago unico de principal y pagos periodicos de intereses'
	---------> Vigentes
	--update precorte set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and (select condicionid from prestamos where prestamoid=p.prestamoid)=2 and  diasinteres<90 and diascapital<30;
	---------> Vencidos
	--update precorte set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and (select condicionid from prestamos where prestamoid=p.prestamoid)=2 and  diasinteres>=90 or diascapital>=30;
	
	--revisar 14 dias
	
   --update precorte set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and diasvencidos<=5;
   

   --update precorte set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and diasvencidos>5;

   update precorte set pagosvencidos = (select (case when diasvencidos=0 then 0 else (case when diasvencidos>0 and diasvencidos<=diastraspasoavencida then 1 else 2 end) end)) where fechacierre=pfechacorte;
   
   --<<

   --Campos del Buro
   
   update precorte set  importeultimaamort=coalesce((select importeamortizacion from amortizaciones where prestamoid=precorte.prestamoid and fechadepago=precorte.fechaultamorpagada),(select min(importeamortizacion) from amortizaciones where prestamoid=precorte.prestamoid )) where fechacierre=pfechacorte;
	--Modificacion by Hmota el dia 07/10/2011
   update precorte set  importevencidoamort=coalesce(((select sum(importeamortizacion-abonopagado) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<=precorte.fechacierre)-(select coalesce(sum(importeamortizacion-abonopagado),0) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<precorte.fechaultamorpagada)),0) where fechacierre=pfechacorte;
  
   update precorte set noamorvencidas=(select count(*) from amortizaciones where prestamoid=precorte.prestamoid and importeamortizacion<>abonopagado and fechadepago<=precorte.fechacierre) where fechacierre>=pfechacorte;
   -- Asignar porcentaje de reserva

   for r in
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
   end loop;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;