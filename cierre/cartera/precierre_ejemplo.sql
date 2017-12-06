
-- Modificado para el pago sostenido 24/04/2010
-- Modificado con fecha 10 de marzo del 2010, considerar fecha de vencimiento en días de mora.
-- Modificado para caja santa maria, considerar creditos con pagos de interes, a 90 días.
-- Modificado para Cooperativa Juventino, con tablas de reserva correspondiente 5-12-2008
-- 
-- select sum(saldovencidomenoravencido),sum(saldovencidomayoravencido) from precorte where fechacierre ='2009-12-31';
--

CREATE or replace  FUNCTION precierre(date) RETURNS integer
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
       0 as interesdevmormayor,p.dias_de_cobro,p.meses_de_cobro,(case when p.condicionid=2 then p.meses_de_cobro*30 else (case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end) end),tp.clavefinalidad,p.fecha_otorga,0 as estatusvive,p.monto_garantia

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
  
   update precorte set saldopromediodelmes=saldopromedioprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo);

   update precorte set interesdevengadomes=interesdevengadoprecorte(precorte.prestamoid,precorte.ejercicio,precorte.periodo); 

   update precorte set primerincumplimiento=coalesce((select min(fechadepago) from amortizaciones where prestamoid=precorte.prestamoid and importeamortizacion > abonopagado),fechaultamorpagada) where fechacierre=pfechacorte;

   -- Dias vencidos 
   
   update precorte set diasvencidos = (case when (fechacierre-fechaultamorpagada)-frecuencia > 0 then (fechacierre-fechaultamorpagada)-frecuencia else 0 end) where fechacierre=pfechacorte; 

   update precorte set diasvencidos = (case when (fechacierre-ultimoabonointeres)-frecuencia > 0 then (fechacierre-ultimoabonointeres)-frecuencia else 0 end) where fechacierre=pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and numero_de_amor =1 and meses_de_cobro=1);

   -- Dias vencidos de Prestamos vencidos

   -- Para pago unico principal e interes
   
   update precorte set diasvencidos = pfechacorte-fecha_vencimiento,diastraspasoavencida=30 where fechacierre=pfechacorte and fecha_vencimiento < pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and condicionid=1);

   -- Para diferentes a pago unico principal e interes
   
   update precorte set diasvencidos = pfechacorte-fecha_vencimiento,diastraspasoavencida=30 where fechacierre=pfechacorte and fecha_vencimiento < pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and condicionid in (3,2)) and fecha_vencimiento < ultimoabonointeres ;
   
   update precorte set diastraspasoavencida = 89 where fechacierre=pfechacorte and prestamoid in (select prestamoid from prestamos where prestamoid=precorte.prestamoid and condicionid in (3,2) and fecha_vencimiento>pfechacorte);
   
   -- Los que no han pagado nada   

   --update precorte set diasvencidos = (case when (fechacierre-fechaultamorpagada) > 0 then (fechacierre-fechaultamorpagada) else 0 end) where fechacierre=pfechacorte and fechaultamorpagada <= (fecha_otorga+frecuencia) and (fecha_otorga+frecuencia)< fecha_vencimiento ;

   -- Los que van adelantados con interes vencido

   --update precorte set diasvencidos = (fechaultamorpagada-ultimoabonointeres)-frecuencia, estatusvive=3 where fechacierre=pfechacorte and (fechaultamorpagada-ultimoabonointeres)>frecuencia;

   -- Los etiquetados como renovados y reestructurados


   update precorte set tipocartera='11' where finalidaddefault='002' and fechacierre=pfechacorte;
   update precorte set tipocartera='13' where finalidaddefault='001'  and fechacierre=pfechacorte;
   update precorte set tipocartera='17' where finalidaddefault='003' and fechacierre=pfechacorte;
   
   -- Validar los creditos reestructurados se agrega en la revisión CNBV

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
            p.ultimoabono,p.diasvencidos,p.diastraspasoavencida,p.ultimoabonointeres
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

       if r.diasvencidos <= r.diastraspasoavencida then

          --
          -- Interes Normal y Moratorio
          --
          finteresdevengadomenor := interesdevengado(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo,'S');

       else
       
          finteresdevengadomenor := interesdevengado(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo,'S');
          fdevengadomayor := interesdevengado(r.prestamoid,pfechacorte,r.ultimoabonointeres,r.saldoprestamo,'N');

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
      
   update precorte set saldovencidomenoravencido=saldoprestamo, saldovencidomayoravencido=0 where fechacierre=pfechacorte and diasvencidos<=diastraspasoavencida;

   update precorte set saldovencidomenoravencido=0,saldovencidomayoravencido=saldoprestamo where fechacierre=pfechacorte and diasvencidos>diastraspasoavencida ;

   update precorte set pagosvencidos = (select (case when diasvencidos=0 then 0 else (case when diasvencidos>0 and diasvencidos<=diastraspasoavencida then 1 else 2 end) end)) where fechacierre=pfechacorte;


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



CREATE or replace FUNCTION interesdevengado(integer, date, date, numeric, character) RETURNS numeric
    AS $_$
declare
  pprestamoid alias for $1;
  pfechacorte alias for $2;
  dfecha      alias for $3;
  fsaldoinsoluto alias for $4;
  pmenorvencido alias for $5;

  dfecha_otorga date;
  dfechaf date;
  dfechavencimiento date;
  idiastraspasoavencida int4;
  fmontoprestamo numeric;
  ftasanormal numeric;
  ftasareciprocidad numeric;
  finteres numeric;
  itantos int4;
  idias   int4;
  icalculonormalid int4;
  icondicionid integer;

  sformula text;
  rec record;

  gdiasanualesprestamo numeric;

  intervalo int4;
  saplicareciprocidad char(1);

begin

  select diasanualesprestamo, aplicareciprocidad
    into gdiasanualesprestamo, saplicareciprocidad
    from empresa
   where empresaid=1;

  finteres:=0;

    select p.montoprestamo,p.tasanormal,p.fecha_otorga,
           p.calculonormalid,tp.diastraspasoavencida,
           (p.fecha_vencimiento-p.fecha_otorga)/p.numero_de_amor,p.fecha_vencimiento,condicionid
      into fmontoprestamo,ftasanormal,dfecha_otorga,
           icalculonormalid,idiastraspasoavencida,
           intervalo,dfechavencimiento,icondicionid
      from prestamos p, precorte tp
     where p.prestamoid = pprestamoid and
           tp.prestamoid = p.prestamoid;

  --raise exception 'Fecha %',dfecha;
  
  if dfecha<pfechacorte then

    dfechaf := pfechacorte;

    --raise exception 'Fecha Final para calculo de interes %',dfechaf;
    -- Calcular interes devengado hasta la fecha final

    if pmenorvencido='S' then
    
      idias := dfechaf - dfecha;      
      if idias<1 then
        finteres := 0;
        return finteres;
      end if;

      raise notice ' % % % % ',idias, dfechaf,dfechavencimiento,icondicionid;
      
      if idias>idiastraspasoavencida and icondicionid <> 1 or (icondicionid=1 and dfechaf >dfechavencimiento) then
        if idias > idiastraspasoavencida then 
           idias := idiastraspasoavencida;
        end if; 
      end if;
      
    else
      
      idias := dfechaf - dfecha - idiastraspasoavencida;
      
      if idias<1 then
        finteres := 0;
        return finteres;
      end if;

    end if;

    raise notice 'Interes Devengado Saldo Insoluto %   Tasa %  Dias %  %',fsaldoinsoluto,ftasanormal,idias,idiastraspasoavencida;

    finteres := fsaldoinsoluto*idias*((ftasanormal/100)/gdiasanualesprestamo);
    
    if round(finteres,2)-trunc(round(finteres,2))>=0.50 then
      finteres := round(trunc(finteres)+1,2);
    else
      finteres := round(trunc(finteres),2);
    end if;

  end if;

return finteres;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE FUNCTION devengaintereses(date, date) RETURNS integer
    AS $_$
declare
  pfecha1 alias for $1;
  pfecha2 alias for $2;

  r record;
  r1 record;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  scuentaid char(24);
  debehaber1 numeric;
  debehaber2 numeric;
  debehaber21 numeric;
  debehaber3 numeric;
  debehaber4 numeric;
  debehaber5 numeric;

  sserie_user char(2);

  bprimer bool;
  diniciadevengamiento date;

begin

  select iniciadevengamiento
    into diniciadevengamiento
    from empresa;

  if pfecha2=diniciadevengamiento then
    bprimer:=true;
  else
    bprimer:=false;
  end if;
  
  sserie_user := 'ZA';

-- 
-- Borrar poliza del mismo día, serie y tipo=V
--

  delete from movipolizas where polizaid in (select polizaid from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfecha1);

  delete from polizas where seriepoliza=sserie_user and tipo='V' and fechapoliza=pfecha1;

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),'V',sserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'V',pnumero_poliza,cast(date_part('year',pfecha1) as int),cast(date_part('month',pfecha1) as int),' ',pfecha1,'D',' ',' ','Devenga Intereses',pfecha1);

  for r in

select p.tipoprestamoid,t.cuentaactivo,t.cuentaactivovencida,t.cuentaintdevnocobres,
       t.cuentaintnormalnocob,t.cuentaordeninteres,t.ordeninteresacreedor,
       t.cuentaintnormal,t.cuentaintmora,t.cuentaintnormalresvencida,
       t.cuentaintnormalvencida,t.cuentaintmoravencida,t.cuentaintnormalresvigente,
       sum((case when p.fechacierre= pfecha1
                 then p.saldovencidomenoravencido else 0 end)) as A, 
       sum((case when p.fechacierre= pfecha1
                 then p.saldovencidomayoravencido else 0 end)) as B,
       sum((case when p.diasvencidos <= p.diastraspasoavencida
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as C,
       sum((case when p.diasvencidos > p.diastraspasoavencida
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as CC,
       sum((case when p.diasvencidos <= p.diastraspasoavencida
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as D,
       sum((case when p.diasvencidos > p.diastraspasoavencida
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as DD,       
       sum((case when p.diasvencidos > p.diastraspasoavencida
                 then p.pagointeresenperiodo else 0 end)) as interes,
       sum((case when p.diasvencidos > p.diastraspasoavencida
                 then p.pagomoratorioenperiodo else 0 end)) as moratorio
  from precorte p, tipoprestamo t
 where p.fechacierre = pfecha1 and
       t.tipoprestamoid = p.tipoprestamoid 
group by p.tipoprestamoid,t.cuentaactivo,t.cuentaactivovencida,t.cuentaintdevnocobres,
       t.cuentaintnormalnocob,t.cuentaordeninteres,t.ordeninteresacreedor,
       t.cuentaintnormal,t.cuentaintmora,t.cuentaintnormalresvencida,
       t.cuentaintnormalvencida,t.cuentaintmoravencida,t.cuentaintnormalresvigente
  loop

    for r1 in
  select t.tipoprestamoid,
       sum((case when p.fechacierre=pfecha2
                 then p.saldovencidomenoravencido else 0 end)) as A1, 
       sum((case when p.fechacierre=pfecha2
                 then p.saldovencidomayoravencido else 0 end)) as B1,     
       sum((case when p.diasvencidos <= p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.saldoprestamo else 0 end)) as A1, 
       sum((case when p.diasvencidos > p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.saldoprestamo else 0 end)) as B1, 
       sum((case when p.diasvencidos <= p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as C1,
       sum((case when p.diasvencidos > p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomenoravencido+p.interesdevmormenor else 0 end)) as CC1,
       sum((case when p.diasvencidos <= p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as D1,
       sum((case when p.diasvencidos > p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.interesdevengadomayoravencido+p.interesdevmormayor else 0 end)) as DD1,       
       sum((case when p.diasvencidos > p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.pagointeresenperiodo else 0 end)) as interes1,
       sum((case when p.diasvencidos > p.diastraspasoavencida and
                      p.fechacierre=pfecha2
                 then p.pagomoratorioenperiodo else 0 end)) as moratorio1
  from tipoprestamo t left join precorte p on t.tipoprestamoid=p.tipoprestamoid
 where t.tipoprestamoid=r.tipoprestamoid
group by t.tipoprestamoid  

    loop

      -- 1era Parte
      if bprimer then
        debehaber1 := r.b;
      else
        debehaber1 := r.b-r1.b1;
      end if;

      if debehaber1<>0 then
      if debehaber1>0 then
        scuentaid := r.cuentaactivovencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber1,0,' ',' ',
                             'Trasp. activo vig. a vencida');
        scuentaid := r.cuentaactivo;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber1,' ',' ',
                             'Disminuir la cartera vigente');
      else
        scuentaid := r.cuentaactivo;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber1),0,' ',
                             ' ','Trasp. activo vig. a vencida');
        scuentaid := r.cuentaactivovencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber1),' ',
                             ' ','Disminuir la cartera vigente');
      end if;
      end if;

      -- 2da Parte
      if bprimer then
        debehaber2 := r.c;
        debehaber21 := r.cc;
      else
        debehaber2 := r.c-r1.c1;
        debehaber21 := r.cc-r1.cc1;
      end if;

      if debehaber2<>0 then
      if debehaber2>0 then
        scuentaid := r.cuentaintdevnocobres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber2,0,' ',' ',
                             'Activo int. dev. no cobrados');
        scuentaid := r.cuentaintnormalnocob;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber2,' ',' ',
                             'Ingreso int. dev. no cobrados'); 
      else
        scuentaid := r.cuentaintnormalnocob;        
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber2),0,' ',
               ' ','Activo int. dev. no cobrados');
        scuentaid := r.cuentaintdevnocobres;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber2),' ',
               ' ','Ingreso int. dev. no cobrados'); 
      end if;
      end if;

      if debehaber21<>0 then
        if debehaber21>0 then
          scuentaid := r.cuentaintnormalvencida;
          select *
            into pmovipolizaid
           from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber21,0,' ',' ',
                             'Orden int. dev. cartera venc.');
 	   scuentaid := r.CuentaIntNormalResVigente;
        
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber21,' ',' ',
                             'Orden int. dev. cartera venc.');         
        else 

	  scuentaid := r.CuentaIntNormalResVigente;
          
          select *
            into pmovipolizaid
            from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber21),0,' ',
               ' ','Orden int. dev. cartera venc.');
          --scuentaid := r.cuentaintdevnocobres;  Esta cuenta estaba mal
          scuentaid := r.cuentaintnormalvencida;
          select *
            into pmovipolizaid
            from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber21),' ',
               ' ','Orden int. dev. cartera venc.'); 
        end if;

      end if;

      -- 3era Parte

      if bprimer then
        debehaber3 := r.d + r.dd;
      else
        debehaber3 := r.d + r.dd - r1.d1 - r1.dd1;
      end if;

      if debehaber3<>0 then
        if debehaber3>0 then
          scuentaid := r.cuentaordeninteres;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber3,0,' ',' ',
                             'CuentaOrdenInteres');
          scuentaid := r.ordeninteresacreedor;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber3,' ',' ',
                             'OrdenInteresAcreedor'); 
        else
          scuentaid := r.ordeninteresacreedor;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',abs(debehaber3),0,' ',
               ' ','OrdenInteresAcreedor');
          scuentaid := r.cuentaordeninteres;
          select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,abs(debehaber3),' ',
               ' ','CuentaOrdenInteres'); 
        end if;
      end if;
      
      debehaber4 := r.interes;
      debehaber5 := r.moratorio;

      if debehaber4>0 then
        scuentaid := r.cuentaintnormal;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber4,0,' ',' ',
                             'CuentaIntNormal');
      end if;
      if debehaber5>0 then
        scuentaid := r.cuentaintmora;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','C',debehaber5,0,' ',' ',
                             'CuentaIntMora');
      end if;
      if debehaber4>0 then
        scuentaid := r.cuentaintnormalresvencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber4,
               ' ',' ','cuentaintnormalresvencida'); 
      end if;
      if debehaber5>0 then
        scuentaid := r.cuentaintmoravencida;
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,scuentaid,' ','A',0,debehaber5,
               ' ',' ','cuentaintmroavencida'); 
      end if;

    end loop;
  end loop;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
