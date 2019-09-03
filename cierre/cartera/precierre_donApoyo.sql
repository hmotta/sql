CREATE FUNCTION precierre(date) RETURNS integer
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

--Borrar el delete para que se pueda validar
  delete from precorte where fechacierre= pfechacorte;   

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
       p.montoprestamo-SUM(case when m.cuentaid=tp.cuentaactivo and
                                     po.fechapoliza<dcorte
                                then m.haber else 0 end) as saldoprestamo,
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

       p.tipoprestamoid,p.montoprestamo,p.clavefinalidad,p.tasanormal,p.tasa_moratoria,
       MAX(case when m.cuentaid=tp.cuentaactivo and po.fechapoliza<dcorte
                then po.fechapoliza else p.fecha_otorga end),
       (case when p.condicionid=0 then 89 else (case when p.condicionid=1 then 30 else (case when p.condicionid=2 then 89 else (case when p.condicionid=3 then 89 else  89 end) end) end) end),
       p.fecha_vencimiento,
       MAX(case when m.cuentaid=tp.cuentaintnormal and po.fechapoliza<dcorte
                then po.fechapoliza else (case when m.cuentaid=tp.cuentaactivo and
                                                       po.fechapoliza<dcorte
                then po.fechapoliza else p.fecha_otorga end) end),
       0 as interesdevmormenor,
       0 as interesdevmormayor,p.dias_de_cobro,p.meses_de_cobro,
--frecuencia con dias de gracia
(case when p.fecha_1er_pago > fechaultimapagada(p.prestamoid,pfechacorte) then p.fecha_1er_pago-p.fecha_otorga else (case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end) end)
,tp.clavefinalidad,p.fecha_otorga,0 as estatusvive,p.monto_garantia

    from prestamos p left join movicaja mc on p.prestamoid=mc.prestamoid 
                     left join polizas po on mc.polizaid = po.polizaid
                     left join movipolizas m on po.polizaid=m.polizaid, 
         tipoprestamo tp
   where p.fecha_otorga <= pfechacorte and
         p.claveestadocredito<>'008' and 
         tp.tipoprestamoid = p.tipoprestamoid
group by p.prestamoid, p.tipoprestamoid,p.montoprestamo,
         p.clavefinalidad,p.tasanormal,p.tasa_moratoria,
         p.fecha_1er_pago,tp.diastraspasoavencida,p.fecha_vencimiento,p.condicionid,p.dias_de_cobro,p.meses_de_cobro,tp.clavefinalidad,p.fecha_otorga,p.monto_garantia                
   order by prestamoid;

   delete from precorte  where fechacierre=pfechacorte and saldoprestamo=0 and interesdevengadomenoravencido=0 and interesdevengadomayoravencido=0 and pagocapitalenperiodo=0 and pagointeresenperiodo=0 and pagomoratorioenperiodo=0 and saldovencidomenoravencido=0 and saldovencidomayoravencido=0;

   --delete from precorte  where fechacierre=pfechacorte and tipoprestamoid='CAS';
   
   update precorte set saldopromediodelmes=saldopromedioprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo);

  

   update precorte set primerincumplimiento=coalesce((select min(fechadepago) from amortizaciones where prestamoid=precorte.prestamoid and importeamortizacion > abonopagado),fechaultamorpagada) where fechacierre=pfechacorte;

   -- Dias vencidos 
   
   update precorte set diasvencidos = (case when (fechacierre-fechaultamorpagada)-frecuencia > 0 then (fechacierre-fechaultamorpagada)-frecuencia else 0 end) where fechacierre=pfechacorte; 

   update precorte set diasvencidos = (case when (fechacierre-ultimoabonointeres)-frecuencia > 0 then (fechacierre-ultimoabonointeres)-frecuencia else 0 end) where fechacierre=pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and numero_de_amor =1 and meses_de_cobro=1);

   -- Dias vencidos de Prestamos vencidos
   -- Para pago unico principal e interes
   
   update precorte set diasvencidos = pfechacorte-fecha_vencimiento,diastraspasoavencida=30 where fechacierre=pfechacorte and fecha_vencimiento < pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and condicionid=1);
   -- Para diferentes a pago unico principal e interes
   
   --update precorte set diasvencidos = pfechacorte-fecha_vencimiento,diastraspasoavencida=30 where fechacierre=pfechacorte and fecha_vencimiento < pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and condicionid in (3,2)) and fecha_vencimiento < ultimoabonointeres ;
   
   update precorte set diastraspasoavencida = 89 where fechacierre=pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and condicionid in (3,2) and fecha_vencimiento>pfechacorte);
   
   -- Los que no han pagado nada   

   --update precorte set diasvencidos = (case when (fechacierre-fechaultamorpagada) > 0 then (fechacierre-fechaultamorpagada) else 0 end) where fechacierre=pfechacorte and fechaultamorpagada <= (fecha_otorga+frecuencia) and (fecha_otorga+frecuencia)< fecha_vencimiento ;

   -- Los que van adelantados con interes vencido

   --update precorte set diasvencidos = (fechaultamorpagada-ultimoabonointeres)-frecuencia, estatusvive=3 where fechacierre=pfechacorte and (fechaultamorpagada-ultimoabonointeres)>frecuencia;

   -- Los etiquetados como renovados y reestructurados
   
   
   update precorte set tipocartera='11' where finalidaddefault='002' and fechacierre=pfechacorte;
   update precorte set tipocartera='13' where finalidaddefault='001' and fechacierre=pfechacorte;
   update precorte set tipocartera='14' where finalidaddefault='001' and prestamoid in (select prestamoid from prestamos where clasificacioncreditoid=3) and  fechacierre=pfechacorte;
   update precorte set tipocartera='17' where finalidaddefault='003' and fechacierre=pfechacorte;
   
   -- Validar los creditos reestructurados se agrega en la revision CNBV

   for r in
     select p.precorteid,p.saldoprestamo,p.fechaultamorpagada,p.prestamoid,p.tipoprestamoid,
            p.ultimoabono,p.diastraspasoavencida,p.ultimoabonointeres,p.frecuencia
       from precorte p
      where p.fechacierre=pfechacorte and p.tipoprestamoid in (select tipoprestamores from tipoprestamo group by tipoprestamores)

   loop

     update precorte set diastraspasoavencida = -1 where precorteid=r.precorteid;
     -- Cambiando a cartera reestructurada.
     update precorte set tipocartera='14' where precorteid=r.precorteid and finalidaddefault='001';
     
     -- Verificar el pago sostenido por tres ocasiones a capital
      
     if (select count(movicajaid) from movicaja mc, polizas p, movipolizas mp where mc.prestamoid=r.prestamoid and mc.polizaid=p.polizaid and mc.polizaid=mp.polizaid and p.fechapoliza<=pfechacorte and mp.cuentaid = (select cuentaactivo from tipoprestamo where tipoprestamoid=r.tipoprestamoid)) >= 3 then

       swsostenido:=0;
       
        -- recorrer los ultimos 3 pagos
       for so in select p.fechapoliza,mp.haber from movicaja mc, polizas p, movipolizas mp where mc.prestamoid=r.prestamoid and mc.polizaid=p.polizaid and mc.polizaid=mp.polizaid and p.fechapoliza<=pfechacorte and mp.cuentaid = (select cuentaactivo from tipoprestamo where tipoprestamoid=r.tipoprestamoid) order by p.fechapoliza desc
       loop

           if so.fechapoliza =(select fechadepago from amortizaciones where prestamoid=r.prestamoid and fechadepago=so.fechapoliza) and so.haber >= (select importeamortizacion from amortizaciones where prestamoid=r.prestamoid and fechadepago=so.fechapoliza) then
                swsostenido:=swsostenido+1;
           end if;
       end loop;

       if swsostenido >=3 then
          
           update precorte set diastraspasoavencida=30 where precorteid=r.precorteid and prestamoid in (select prestamoid from prestamos where prestamoid=r.prestamoid and condicionid=1);
           
           update precorte set diastraspasoavencida=89 where precorteid=r.precorteid and prestamoid in (select prestamoid from prestamos where prestamoid=r.prestamoid and condicionid in (3,2));
           --Cambio a cartera reestructurada en comercial
           
           
       end if;
        
     end if;

     
   end loop;
   
   
   for r in
     select p.precorteid,p.saldoprestamo,p.fechaultamorpagada,p.prestamoid,
            p.ultimoabono,p.diasvencidos,p.diastraspasoavencida,p.ultimoabonointeres,p.tipocartera
       from precorte p
      where p.fechacierre=pfechacorte

   loop

     -- Clasificacion de interes devengado

     finteresdevengadomenor := 0;
     fdevengadomayor := 0;
     finteresdevmormayor:=0;
     finteresdevmormenor:=0;
     
     --raise notice 'ultima amortizacion  %  %  %',r.prestamoid,r.fechaultamorpagada,periododemenos;

     if r.saldoprestamo>0 then

       select idncvigente,idncvencido into finteresdevengadomenor,fdevengadomayor from  rinteresdevengado(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo);
       if r.tipocartera = '14' then
          fdevengadomayor:=0;
       end if;

     end if;

     update precorte
        set interesdevengadomenoravencido=finteresdevengadomenor,
            interesdevengadomayoravencido=fdevengadomayor,           
            interesdevmormenor = finteresdevmormenor,
            interesdevmormayor = finteresdevmormayor
      where precorteid=r.precorteid;

      finteresdevmormenor:=0;
      finteresdevmormayor:=0;
        
   end loop;

   update precorte set interesdevengadomes=interesdevengadoprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo);
    
   update precorte set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and diasvencidos<=diastraspasoavencida;

   update precorte set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and diasvencidos>diastraspasoavencida ;

   update precorte set pagosvencidos = (select (case when diasvencidos=0 and diasvencidos<=diastraspasoavencida then 0 else (case when diasvencidos>0 and diasvencidos<=diastraspasoavencida then 1 else 2 end) end)) where fechacierre=pfechacorte;

   --Comentada por que no hay valores nuevos para este 2011
   --update  tablareserva set factordisminucion=(select porcentaje/100  from porcreserva where pfechacorte >= fechainicial and pfechacorte <= fechafinal);

   -- Campos del buro de credito

   update precorte set  importeultimaamort=coalesce((select importeamortizacion from amortizaciones where prestamoid=precorte.prestamoid and fechadepago=precorte.fechaultamorpagada),(select min(importeamortizacion) from amortizaciones where prestamoid=precorte.prestamoid )) where fechacierre>=pfechacorte;

   update precorte set  importevencidoamort=coalesce(((select sum(importeamortizacion-abonopagado) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<=precorte.fechacierre)-(select sum(importeamortizacion-abonopagado) from amortizaciones where prestamoid=precorte.prestamoid and fechadepago<precorte.fechaultamorpagada)),0) where fechacierre>=pfechacorte;
   
   for r in
     select p.precorteid,t.porcentajereserva,
            (p.saldoprestamo-p.depositogarantia)*t.porcentajereserva as reservacalculada,
            (p.interesdevengadomenoravencido+p.interesdevmormenor)*t.porcentajereservaidnc as reservaidnc,
            t.factordisminucion,t.tablareservaid,p.prestamoid,
            p.diasvencidos,p.finalidaddefault
       from precorte p, tablareserva t
      where p.fechacierre=pfechacorte and p.finalidaddefault=t.finalidaddefault and p.tipocartera=t.tipocartera and p.diasvencidos>=t.diainicial and p.diasvencidos<=t.diafinal 
            

   loop

        update precorte set tablareservaid = r.tablareservaid,
            porcentajeaplicado=r.porcentajereserva,
            reservacalculada=r.reservacalculada,
            reservaidnc=r.reservaidnc,
            factoraplicado=r.factordisminucion
        where precorteid=r.precorteid;

   end loop;
 
   
   -- generar la captacion total
   -- select generacaptaciontotal into igeneracaptaciontotal from generacaptaciontotal(pfechacorte);

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;