-- Modificado 03-11-2009 verificacion de dias mora
--

CREATE or replace FUNCTION spscalculopago(integer) RETURNS SETOF tcalculopago
    AS $_$
declare
  lprestamoid alias for $1;
  r tcalculopago%rowtype;
  rec record;
  amor record;

  famortizacion numeric;
  fvencidas     numeric;
  idiasint      integer;
  fcapital      numeric;
  finteres      numeric;
  fmoratorio    numeric;
  fiva          numeric;
  ftotal        numeric;

  fmontoprestamo   numeric;
  fsaldoprestamo   numeric;
  dfechaultimopago date;
  ftasanormal      numeric;
  ftasa_moratoria  numeric;
  dfecha_otorga    date;
  dfecha_1er_pago  date;

  fsaldoinsoluto   numeric;

  saplicaiva       char(1);
  sformula text;
  icalculonormalid int4;
  icalculomoratorioid int4;

  finteresminimo numeric;

  itantos int4;
  freciprocidad numeric;

  dultimoabono date;

  saplicareciprocidad char(1);

  fsaldoact numeric;
  fsaldocalculado numeric;

  sclaveestadocredito char(3);

  gIVA numeric;
  gcobrardiainicial int4;

  dfechaprestamo date;

  dfechacobroiva date;

  dfecha2 date;

  gmoratoriopormonto int4;
  gdiasmoratoriopormonto int4;
  gdiasanualesprestamo int4;


  fpagado numeric;
  idiastraspasoavencida numeric;
  idias numeric;
  fmormenor numeric;
  fmormayor numeric;
  swmora numeric;
  dfechapago date;
  dfecha_vencimiento date;

begin

  select iva,cobrardiainicial,aplicareciprocidad,fechacobroiva,moratoriopormonto,diasmoratoriopormonto,diasanualesprestamo
    into gIVA,gcobrardiainicial,saplicareciprocidad,dfechacobroiva,gmoratoriopormonto,gdiasmoratoriopormonto,gdiasanualesprestamo
    from empresa where empresaid=1;

--raise notice 'Calculando';

select fecha_otorga,fechaultimopago
  into dfechaprestamo,dfecha2
  from prestamos where prestamoid=lprestamoid;


  if dfecha2<dfechaprestamo then

    -- La fecha del ultimo pago es menor que la fecha del prestamo

    update prestamos
       set fechaultimopago=dfechaprestamo
     where prestamoid=lprestamoid;

  end if;

if dfechaprestamo<dfechacobroiva then
  gIVA:=0;
  saplicaiva:='N';
end if;


-- Recalcular el saldo en base a pagos
select p.saldoprestamo, p.montoprestamo-sum(m.haber),p.claveestadocredito
  into fsaldoact,fsaldocalculado,sclaveestadocredito
  from prestamos p, tipoprestamo tp, movicaja mc, movipolizas m
 where p.prestamoid = lprestamoid and
       tp.tipoprestamoid = p.tipoprestamoid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.cuentaid = tp.cuentaactivo
group by p.saldoprestamo,p.montoprestamo,p.claveestadocredito;

  fsaldoact:=coalesce(fsaldoact,0);
  fsaldocalculado:=coalesce(fsaldocalculado,0);

  --raise notice ' Saldo Actual %  Saldo Calculado %',fsaldoact,fsaldocalculado;
  if fsaldoact<>fsaldocalculado then
    update prestamos
       set saldoprestamo = fsaldocalculado
     where prestamoid=lprestamoid;
  end if;

  select aplicareciprocidad
    into saplicareciprocidad
    from empresa
   where empresaid=1;

  famortizacion := 0;
  fvencidas     := 0;
  idiasint      := 0;
  fcapital      := 0;
  finteres      := 0;
  fmoratorio    := 0;
  fiva          := 0;
  ftotal        := 0;

  select interesminimo
    into finteresminimo
    from empresa
   where empresaid=1;
  finteresminimo := coalesce(finteresminimo,0);

  select p.montoprestamo,p.saldoprestamo,p.tasanormal,p.tasa_moratoria,p.fecha_otorga,p.fecha_1er_pago,
         tp.aplicaivaprestamo,p.calculonormalid,p.calculomoratorioid,tp.tantos,p.fecha_vencimiento
    into fmontoprestamo,fsaldoprestamo,ftasanormal,ftasa_moratoria,dfecha_otorga,dfecha_1er_pago,
         saplicaiva,icalculonormalid,icalculomoratorioid,itantos,dfecha_vencimiento
    from prestamos p, tipoprestamo tp
   where p.prestamoid=lprestamoid and
         tp.tipoprestamoid = p.tipoprestamoid;


   itantos:=coalesce(itantos,1);
   if itantos>0 then
     freciprocidad := fmontoprestamo/itantos;
   else
     freciprocidad := fmontoprestamo;
   end if;


if dfechaprestamo<dfechacobroiva then
  gIVA:=0;
  saplicaiva:='N';
end if;



--
-- Validar que el saldo insoluto del prestamo se encuentre calculado correctamente
--
--  select fmontoprestamo-coalesce(sum(capitalpagoprestammo),0)
--    into fsaldoinsoluto
--    from pagoprestamo
--   where prestamoid=lprestamoid;

   fsaldoinsoluto := fsaldoprestamo;

   if fsaldoprestamo<>fsaldoinsoluto then
     raise exception 'Error Saldos, verifique saldos del prestamo ... % %',fsaldoprestamo,fsaldoinsoluto;
   end if;

--
-- Fecha de ultimo pago, donde pago a capital o interes normal
--
  select coalesce(MAX(fechaultimopago),dfecha_otorga-1)
    into dfechaultimopago
    from prestamos
   where prestamoid=lprestamoid;

   --
   -- Verificar la fecha de ultimo abono
   -- en caso de estar erronea correguirla
   --
   select max(p.fechapoliza)
     into dultimoabono
     from movicaja mc,polizas p, movipolizas m
    where mc.prestamoid = lprestamoid and             
          p.polizaid = mc.polizaid and
          m.movipolizaid = mc.movipolizaid and
          mc.estatusmovicaja='A' and
          mc.tipomovimientoid='00' and
          m.debe>0;

   dultimoabono := coalesce(dultimoabono,dfechaultimopago);

   --raise notice 'ult. abo. % - ult. pag. %',dultimoabono,dfechaultimopago;
   if dultimoabono<>dfechaultimopago then

     dfechaultimopago := dultimoabono;
     update prestamos
        set fechaultimopago = dultimoabono
      where prestamoid = lprestamoid;

   end if;

--
-- Buscar amortizacion actual
--
   select coalesce(SUM(importeamortizacion-abonopagado),0.00)
     into famortizacion
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago=CURRENT_DATE and importeamortizacion-abonopagado>0;
    
--
-- Buscar amortizaciones vencidas
--
   select coalesce(SUM(round(importeamortizacion-abonopagado,2)),0.00)
     into fvencidas
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago<CURRENT_DATE and importeamortizacion-abonopagado>0;
  
  idiasint := CURRENT_DATE - dfechaultimopago;
  fcapital := round( famortizacion + fvencidas, 2);
  
  if dfechaultimopago=dfecha_otorga then
    --
    -- Para el caso de la 1era amortizacion agregar un dia de interes
    --
    if gcobrardiainicial=1 then
      idiasint := idiasint + 1;
    end if;
    --raise exception ' % %  %',dfechaultimopago,dfecha_otorga,idiasint;
  end if;

--
-- Calculo de interes Normal
--

  if ftasanormal>0 then
    ftasanormal := tasareciprocidad(lprestamoid);
  end if;

  if idiasint<0 then
    idiasint := 0;
  end if;

  update calculo
     set saldoinsoluto = fsaldoinsoluto,
         dias = idiasint,
         tasaintnormal = ftasanormal,
         tasaintmoratorio = ftasa_moratoria
   where calculoid=icalculonormalid;

  SELECT formula into sformula from calculo where calculoid=icalculonormalid;

  for rec in execute
      'SELECT round(' || sformula || ',2) as interes FROM calculo where calculoid='||icalculonormalid
  loop

    if round(rec.interes,2)-trunc(round(rec.interes,2))>=0.50 then
      finteres := round(trunc(rec.interes)+1,2);
    else
      finteres := round(trunc(rec.interes),2);
    end if;
  end loop;

--
-- Calculo de interes moratorio
--

  fpagado:= fmontoprestamo - fsaldoinsoluto ;

  select t.diastraspasoavencida into idiastraspasoavencida
    from prestamos p, tipoprestamo t
   where p.prestamoid = lprestamoid and
         t.tipoprestamoid = p.tipoprestamoid;

  -- idiastraspasoavencida:=90;

   --raise notice ' mora menor *** 1 ';

  swmora:=0;
  fmormenor :=0;
  fmormayor :=0;
  dfechapago:=CURRENT_DATE;

  if dfechaultimopago >=  dfecha_vencimiento then

    fmormayor:=fsaldoinsoluto*idiasint*ftasa_moratoria/100/360;

  else

    for amor in
      select * from amortizaciones
      where prestamoid=lprestamoid
      order by fechadepago
    loop

      if fpagado<amor.importeamortizacion then

      --raise notice ' fpagado % amortizacion % --% --%--%',fpagado,amor.importeamortizacion,amor.fechadepago,fmormenor,dfechaultimopago;

      if amor.fechadepago<dfechapago then
        -- Calcular moratorio
        if amor.fechadepago-dfechaultimopago<=idiastraspasoavencida then
          --raise notice ' mora menor 1 ';
          if dfechapago-amor.fechadepago>0 then
            
            if dfechaultimopago > amor.fechadepago then 
              idias:= dfechapago-dfechaultimopago;
            else 
              idias:= dfechapago-amor.fechadepago;
            --idias:= amor.fechadepago-dfechaultimopago;
            end if;

            if idias < 0 then
               idias:=0;
            end if;

            fmoratorio:=(amor.importeamortizacion-fpagado)*idias*ftasa_moratoria/100/360;

            --raise notice ' mora menor 2 %  -- % -- idiasven %',idias,fmoratorio,idiastraspasoavencida;

            if round(fmoratorio,2)-trunc(round(fmoratorio,2))>=0.50 then
               fmormenor := fmormenor + round(trunc(fmoratorio)+1,2);
            else
               fmormenor := fmormenor + round(trunc(fmoratorio),2);
            end if;

            fpagado:=0;
                     
          end if;
        end if;

        if amor.fechadepago-dfechaultimopago>idiastraspasoavencida then
            --raise notice ' mora mayor 1 * %', fmoratorio;
            if dfechapago-amor.fechadepago>0 then
              --raise noce ' mora mayor 2 ';
              -- Aqui se agrega el calculo especial de credimax
            
                 if swmora=0 and amor.fechadepago-dfechaultimopago > idiastraspasoavencida then
                      idias:= dfechapago-amor.fechadepago;
                      fmoratorio:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;
                      --raise notice ' mora mayor 2 ** % % %',fsaldoinsoluto,idias,fmoratorio;
                      swmora:=1;
                      -- Lo hacemos una vez y prendemos el switch
                  else
                      fmoratorio:=0;
                  end if;

              --raise notice ' mora menor 3 %  -- % -- idiasven %',idias,fmoratorio,idiastraspasoavencida;
          
              -- Aqui termina 

              if round(fmoratorio,2)-trunc(round(fmoratorio,2))>=0.50 then
                 fmormayor := fmormayor+ round(trunc(fmoratorio)+1,2);
              else
                 fmormayor := fmormayor+ round(trunc(fmoratorio),2);
              end if;
              
              fpagado:=0;

           end if;
         
        end if;

      else
        exit;
      end if;
    else
      fpagado := fpagado - amor.importeamortizacion;
    end if;
    
    end loop;

  end if;

  if fmormayor = 0 and dfecha_vencimiento < dfechapago then
      idias:= dfechapago-dfechaultimopago;
      --idias:= dfechapago-dfecha_vencimiento;
      fmormayor:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;
      raise notice ' mora menor 4 %  -- % -- idiasven %',idias,fmormayor,idiastraspasoavencida;
  end if;

  fmoratorio:=coalesce(fmormenor,0)+coalesce(fmormayor,0);


  if CURRENT_DATE-dfechaultimopago>gdiasmoratoriopormonto and gmoratoriopormonto=1 then
    -- Calcular el moratrio en base al saldo
    fmoratorio:=(CURRENT_DATE-dfechaultimopago)*fsaldoinsoluto*ftasa_moratoria/100/gdiasanualesprestamo;
  end if;


  -- No cobrar si la reciprocidad >= saldoprestamo
  if freciprocidad>=fsaldoprestamo and saplicareciprocidad='S' then
    fmoratorio := 0;
  end if;

  -- Iva y pago minimo


if dfechaprestamo<dfechacobroiva then
  gIVA:=0;
  saplicaiva:='N';
end if;


  if ftasanormal>0 then
    if (1+gIVA)*(finteres+fmoratorio)<finteresminimo and dfechaultimopago<>CURRENT_DATE then
      -- Tomar el interes minimo como interes normal    
      finteres := finteresminimo;
      fmoratorio := 0;
    end if;
  end if;

  if saplicaiva='S' then

      fiva := round( (finteres+fmoratorio)*gIVA , 2);

  else
    if ftasanormal>0 then
    if (finteres+fmoratorio)<finteresminimo and dfechaultimopago<>CURRENT_DATE then
      -- Tomar el interes minimo como interes normal
      finteres := finteresminimo;
      fmoratorio := 0;
      fiva:=0;
    end if;
    end if;
  end if;


  ftotal := round(fcapital + finteres + fmoratorio + fiva, 2);

  idiasint := CURRENT_DATE - dfechaultimopago;

  if dfechaultimopago=dfecha_otorga then
    --
    -- Para el caso de la 1era amortizacion agregar un dia de interes
    --
    if gcobrardiainicial=1 then
      idiasint := idiasint + 1;
    end if;
    --raise exception ' % %  %',dfechaultimopago,dfecha_otorga,idiasint;
  end if;

  if idiasint<0 then
    idiasint := 0;
  end if;

  r.prestamoid   := lprestamoid;
  r.amortizacion := round(famortizacion,2);
  r.vencidas     := fvencidas;
  r.diasint      := idiasint;
  r.capital      := round(fcapital,2);
  r.interes      := round(finteres,2);
  r.moratorio    := round(fmoratorio,2);
  r.iva          := round(fiva,2);
  r.total        := round(ftotal,2);

  return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE or replace FUNCTION spscalculopagocartera(integer, date) RETURNS SETOF tcalculopagocartera
    AS $_$
declare
  lprestamoid alias for $1;
  dfechapago  alias for $2;

  r tcalculopagocartera%rowtype;
  rec record;
  amor record;

  famortizacion numeric;
  fvencidas     numeric;
  idiasint      integer;
  fcapital      numeric;
  finteres      numeric;
  fmoratorio    numeric;
  fiva          numeric;
  ftotal        numeric;
  
  fmontoprestamo   numeric;
  fsaldoprestamo   numeric;
  dfechaultimopago date;
  ftasanormal      numeric;
  ftasa_moratoria  numeric;
  dfecha_otorga    date;
  dfecha_1er_pago  date;

  fsaldoinsoluto   numeric;

  saplicaiva       char(1);
  sformula text;
  icalculonormalid int4;
  icalculomoratorioid int4;

  finteresminimo numeric;

  itantos int4;
  freciprocidad numeric;

  dultimoabono date;

  gIVA numeric;
  gcobrardiainicial int4;
  saplicareciprocidad char(1);

  dfechaprestamo date;  

  dfechacobroiva date;

  fpagado numeric;
  idiastraspasoavencida numeric;
  idias numeric;
  idiasmora integer;
  fmormenor numeric;
  fmormayor numeric;
  swmora numeric;
  dfecha_vencimiento date;
  nvencidas integer;
  tamortizaciones numeric;
  swdiasmora integer;

  -- Dias de capital
  ifrecuencia integer;
  dfechaultimapagada date;

begin

  select iva,cobrardiainicial,aplicareciprocidad,fechacobroiva
    into gIVA,gcobrardiainicial,saplicareciprocidad,dfechacobroiva
    from empresa where empresaid=1;

select fecha_otorga into dfechaprestamo from prestamos where prestamoid=lprestamoid;

if dfechaprestamo<dfechacobroiva then
  gIVA:=0;
end if;


  famortizacion := 0;
  fvencidas     := 0;
  idiasint      := 0;
  fcapital      := 0;
  finteres      := 0;
  fmoratorio    := 0;
  fiva          := 0;
  ftotal        := 0;

  select interesminimo
    into finteresminimo
    from empresa
   where empresaid=1;
  finteresminimo := coalesce(finteresminimo,0);

  select p.montoprestamo,p.saldoprestamo,p.tasanormal,p.tasa_moratoria,p.fecha_otorga,p.fecha_1er_pago,
         tp.aplicaivaprestamo,p.calculonormalid,p.calculomoratorioid,tp.tantos,p.fecha_vencimiento,
         (case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end)
    into fmontoprestamo,fsaldoprestamo,ftasanormal,ftasa_moratoria,dfecha_otorga,dfecha_1er_pago,
         saplicaiva,icalculonormalid,icalculomoratorioid,itantos,dfecha_vencimiento,ifrecuencia
    from prestamos p, tipoprestamo tp
   where p.prestamoid=lprestamoid and
         tp.tipoprestamoid = p.tipoprestamoid;


   itantos:=coalesce(itantos,1);
   if itantos>0 then
     freciprocidad := fmontoprestamo/itantos;
   else
     freciprocidad := fmontoprestamo;
   end if;

--
-- Validar que el saldo insoluto del prestamo se encuentre calculado correctamente
--
--  select fmontoprestamo-coalesce(sum(capitalpagoprestammo),0)
--    into fsaldoinsoluto
--    from pagoprestamo
--   where prestamoid=lprestamoid;

   fsaldoinsoluto := fsaldoprestamo;

   if fsaldoprestamo<>fsaldoinsoluto then
     raise exception 'Error Saldos, verifique saldos del prestamo ... % %',fsaldoprestamo,fsaldoinsoluto;
   end if;

--
-- Fecha de ultimo pago, donde pago a capital o interes normal
--
  select coalesce(MAX(fechaultimopago),dfecha_otorga-1)
    into dfechaultimopago
    from prestamos
   where prestamoid=lprestamoid;


   --
   -- Verificar la fecha de ultimo abono
   -- en caso de estar erronea correguirla
   --
   select max(p.fechapoliza)
     into dultimoabono
     from movicaja mc,polizas p, movipolizas m
    where mc.prestamoid = lprestamoid and             
          p.polizaid = mc.polizaid and
          m.movipolizaid = mc.movipolizaid and
          mc.estatusmovicaja='A' and
          mc.tipomovimientoid='00' and
          m.debe+m.haber>0;

   dultimoabono := coalesce(dultimoabono,dfechaultimopago);

--raise notice 'ult. abo. % - ult. pag. %',dultimoabono,dfechaultimopago;
   if dultimoabono>dfechaultimopago then

     dfechaultimopago := dultimoabono;
     update prestamos
        set fechaultimopago = dultimoabono
      where prestamoid = lprestamoid;

   end if;

--
-- Buscar amortizacion actual
--
   select coalesce(SUM(importeamortizacion-abonopagado),0.00)
     into famortizacion
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago=dfechapago and importeamortizacion-abonopagado>0;
    
--
-- Buscar amortizaciones vencidas
--
   select coalesce(SUM(round(importeamortizacion-abonopagado,2)),0.00)
     into fvencidas
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago<dfechapago and importeamortizacion-abonopagado>0;

--raise exception ' Vencidas % ',fvencidas;

  idiasint := dfechapago - dfechaultimopago;
  fcapital := round( famortizacion + fvencidas, 2);
  
  if dfechaultimopago=dfecha_otorga then
    --
    -- Para el caso de la 1era amortizacion agregar un dia de interes
    --
    if gcobrardiainicial=1 then
      idiasint := idiasint + 1;
    end if;
    --raise exception ' % %  %',dfechaultimopago,dfecha_otorga,idiasint;
  end if;

--
-- Calculo de interes Normal
--

  ftasanormal := tasareciprocidad(lprestamoid);

  if idiasint<0 then
    idiasint := 0;
  end if;

  update calculo
     set saldoinsoluto = fsaldoinsoluto,
         dias = idiasint,
         tasaintnormal = ftasanormal,
         tasaintmoratorio = ftasa_moratoria
   where calculoid=icalculonormalid;

  SELECT formula into sformula from calculo where calculoid=icalculonormalid;

  for rec in execute
      'SELECT round(' || sformula || ',2) as interes FROM calculo where calculoid='||icalculonormalid
  loop
    -- Preguntar a Juan lo del redondeo
    --raise exception '% -  % % % -  %',sformula,fsaldoinsoluto,idiasint,ftasanormal,rec.interes;

    if round(rec.interes,2)-trunc(round(rec.interes,2))>=0.50 then
      finteres := round(trunc(rec.interes)+1,2);
    else
      finteres := round(trunc(rec.interes),2);
    end if;
  end loop;


--
-- Calculo de interes moratorio
--

  fpagado:= fmontoprestamo - fsaldoinsoluto ;

  select t.diastraspasoavencida into idiastraspasoavencida
    from prestamos p, tipoprestamo t
   where p.prestamoid = lprestamoid and
         t.tipoprestamoid = p.tipoprestamoid;

  swmora:=0;
  fmormenor :=0;
  fmormayor :=0;

  nvencidas:=0;
  idiasmora:=0;
  tamortizaciones:=0;
  swdiasmora:=0;

  if dfechaultimopago >=  dfecha_vencimiento then

    fmormayor:=fsaldoinsoluto*idiasint*ftasa_moratoria/100/360;
    if swdiasmora=0 then
              idiasmora:= idiasint;
              swdiasmora:=1;            
              raise notice ' 1 dias mora %',idiasmora;
    end if;           

  else

    for amor in
      select * from amortizaciones
      where prestamoid=lprestamoid
      order by fechadepago
    loop


      if swdiasmora=0 and amor.importeamortizacion > amor.abonopagado and amor.fechadepago <dfechapago then
              idiasmora:= dfechapago-amor.fechadepago;
              swdiasmora:=1;
              raise notice ' 2 dias mora %  %  %',idiasmora,dfechapago,amor.fechadepago;
      end if;           


    if fpagado<amor.importeamortizacion then

      --raise notice ' fpagado % amortizacion % --% --%--%',fpagado,amor.importeamortizacion,amor.fechadepago,fmormenor,dfechaultimopago;

      if amor.fechadepago<dfechapago then
        -- Calcular moratorio
        if amor.fechadepago-dfechaultimopago<=idiastraspasoavencida then
          --raise notice ' mora menor 1 ';
          if dfechapago-amor.fechadepago>0 then

            if dfechaultimopago > amor.fechadepago then 
              idias:= dfechapago-dfechaultimopago;
            else 
              idias:= dfechapago-amor.fechadepago;
            --idias:= amor.fechadepago-dfechaultimopago;
            end if;

            if idias < 0 then
               idias:=0;
            end if;
           
            nvencidas=nvencidas+1;
            tamortizaciones=tamortizaciones+amor.importeamortizacion;

            fmoratorio:=(amor.importeamortizacion-fpagado)*idias*ftasa_moratoria/100/360;

            --raise notice ' mora menor 2 %  -- %',idias,fmoratorio;

            if round(fmoratorio,2)-trunc(round(fmoratorio,2))>=0.50 then
               fmormenor := fmormenor + round(trunc(fmoratorio)+1,2);
            else
               fmormenor := fmormenor + round(trunc(fmoratorio),2);
            end if;

            fpagado:=0;
                     
          end if;
        end if;

        if amor.fechadepago-dfechaultimopago>idiastraspasoavencida then
            --raise notice ' mora mayor 1 ';
            if dfechapago-amor.fechadepago>0 then
              --   raise notice ' mora mayor 2 ';
              -- Aqui se agrega el calculo especial de credimax
            
                 if swmora=0 and amor.fechadepago-dfechaultimopago > idiastraspasoavencida then
                      idias:= dfechapago-amor.fechadepago;
                      fmoratorio:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;
                      swmora:=1;
                      -- Lo hacemos una vez y prendemos el switch
                  else
                      fmoratorio:=0;
                  end if;

                  --raise notice ' mora menor 3 %  -- %',idias,fmoratorio;
          
              -- Aqui termina 

              if round(fmoratorio,2)-trunc(round(fmoratorio,2))>=0.50 then
                 fmormayor := fmormayor+ round(trunc(fmoratorio)+1,2);
              else
                 fmormayor := fmormayor+ round(trunc(fmoratorio),2);
              end if;
              
              fpagado:=0;

           end if;
         
        end if;

      else
        exit;
      end if;
    else
      fpagado := fpagado - amor.importeamortizacion;
    end if;
    
    end loop;

  end if;

  if fmormayor = 0 and dfecha_vencimiento < dfechapago then
      --idias:= dfechapago-dfecha_vencimiento;
      idias:= dfechapago-dfechaultimopago;
      fmormayor:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;    
  end if;


  fmoratorio:=coalesce(fmormenor,0)+coalesce(fmormayor,0);

-- Aqui termina el procedimiento
--

  -- No cobrar si la reciprocidad >= saldoprestamo

  if freciprocidad>=fsaldoprestamo and saplicareciprocidad='S' then
    fmoratorio := 0;
  end if;


if dfechaprestamo<dfechacobroiva then
  gIVA:=0;
  saplicaiva:='N';
end if;


  -- Iva y pago minimo

  if (1+gIVA)*(finteres+fmoratorio)<finteresminimo and dfechaultimopago<>dfechapago then
    -- Tomar el interes minimo como interes normal
    finteres := finteresminimo;
    fmoratorio := 0;
  end if;

  if saplicaiva='S' then
    fiva := round( (finteres+fmoratorio)*gIVA , 2);
  else
    if (finteres+fmoratorio)<finteresminimo and dfechaultimopago<>dfechapago then
      -- Tomar el interes minimo como interes normal
      finteres := finteresminimo;
      fmoratorio := 0;
      fiva:=0;
    end if;
  end if;


  ftotal := round(fcapital + finteres + fmoratorio + fiva, 2);

  idiasint := dfechapago - dfechaultimopago;

  if dfechaultimopago=dfecha_otorga then
    --
    -- Para el caso de la 1era amortizacion agregar un dia de interes
    --
    if gcobrardiainicial=1 then
      idiasint := idiasint + 1;
    end if;
    --raise exception ' % %  %',dfechaultimopago,dfecha_otorga,idiasint;
  end if;

  raise notice ' 3 dias mora %',idiasmora;

  if idiasint<0 then
    idiasint := 0;
  end if;

  r.prestamoid   := lprestamoid;
  if nvencidas > 0 then 
        r.amortizacion := round(tamortizaciones/nvencidas,2);
  else
        select min(importeamortizacion) into r.amortizacion from amortizaciones where prestamoid=lprestamoid;
        nvencidas:=trunc(fcapital/r.amortizacion);
  end if;

  dfechaultimapagada:=fechaultimapagada(lprestamoid,dfechapago);  
  idiasmora:=(case when (dfechapago-dfechaultimapagada)-ifrecuencia > 0 then (dfechapago-dfechaultimapagada)-ifrecuencia else 0 end);
  
  r.vencidas     := nvencidas;
  r.diasint      := idiasmora;
  r.capital      := round(fcapital,2);
  r.interes      := round(finteres,2);
  r.moratorio    := round(fmoratorio,2);
  r.iva          := round(fiva,2);
  r.total        := round(ftotal,2);
  r.saldoprestamo:= fsaldoinsoluto;
  r.fechaultimopago:= dfechaultimopago;

  return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION spscalculopagod(integer, date) RETURNS SETOF tcalculopago
    AS $_$
declare
  lprestamoid alias for $1;
  dfechapago  alias for $2;

  r tcalculopago%rowtype;
  rec record;
  amor record;

  famortizacion numeric;
  fvencidas     numeric;
  idiasint      integer;
  fcapital      numeric;
  finteres      numeric;
  fmoratorio    numeric;
  fiva          numeric;
  ftotal        numeric;
  
  fmontoprestamo   numeric;
  fsaldoprestamo   numeric;
  dfechaultimopago date;
  ftasanormal      numeric;
  ftasa_moratoria  numeric;
  dfecha_otorga    date;
  dfecha_1er_pago  date;

  fsaldoinsoluto   numeric;

  saplicaiva       char(1);
  sformula text;
  icalculonormalid int4;
  icalculomoratorioid int4;

  finteresminimo numeric;

  itantos int4;
  freciprocidad numeric;

  dultimoabono date;

  gIVA numeric;
  gcobrardiainicial int4;
  saplicareciprocidad char(1);

  dfechaprestamo date;  

  dfechacobroiva date;

  fpagado numeric;
  idiastraspasoavencida numeric;
  idias numeric;
  fmormenor numeric;
  fmormayor numeric;
  swmora numeric;
  dfecha_vencimiento date;

begin

  select iva,cobrardiainicial,aplicareciprocidad,fechacobroiva
    into gIVA,gcobrardiainicial,saplicareciprocidad,dfechacobroiva
    from empresa where empresaid=1;

select fecha_otorga into dfechaprestamo from prestamos where prestamoid=lprestamoid;

if dfechaprestamo<dfechacobroiva then
  gIVA:=0;
end if;


  famortizacion := 0;
  fvencidas     := 0;
  idiasint      := 0;
  fcapital      := 0;
  finteres      := 0;
  fmoratorio    := 0;
  fiva          := 0;
  ftotal        := 0;

  select interesminimo
    into finteresminimo
    from empresa
   where empresaid=1;
  finteresminimo := coalesce(finteresminimo,0);

  select p.montoprestamo,p.saldoprestamo,p.tasanormal,p.tasa_moratoria,p.fecha_otorga,p.fecha_1er_pago,
         tp.aplicaivaprestamo,p.calculonormalid,p.calculomoratorioid,tp.tantos,p.fecha_vencimiento 
    into fmontoprestamo,fsaldoprestamo,ftasanormal,ftasa_moratoria,dfecha_otorga,dfecha_1er_pago,
         saplicaiva,icalculonormalid,icalculomoratorioid,itantos,dfecha_vencimiento
    from prestamos p, tipoprestamo tp
   where p.prestamoid=lprestamoid and
         tp.tipoprestamoid = p.tipoprestamoid;


   itantos:=coalesce(itantos,1);
   if itantos>0 then
     freciprocidad := fmontoprestamo/itantos;
   else
     freciprocidad := fmontoprestamo;
   end if;

--
-- Validar que el saldo insoluto del prestamo se encuentre calculado correctamente
--
--  select fmontoprestamo-coalesce(sum(capitalpagoprestammo),0)
--    into fsaldoinsoluto
--    from pagoprestamo
--   where prestamoid=lprestamoid;

   fsaldoinsoluto := fsaldoprestamo;

   if fsaldoprestamo<>fsaldoinsoluto then
     raise exception 'Error Saldos, verifique saldos del prestamo ... % %',fsaldoprestamo,fsaldoinsoluto;
   end if;

--
-- Fecha de ultimo pago, donde pago a capital o interes normal
--
  select coalesce(MAX(fechaultimopago),dfecha_otorga-1)
    into dfechaultimopago
    from prestamos
   where prestamoid=lprestamoid;


   --
   -- Verificar la fecha de ultimo abono
   -- en caso de estar erronea correguirla
   --
   select max(p.fechapoliza)
     into dultimoabono
     from movicaja mc,polizas p, movipolizas m
    where mc.prestamoid = lprestamoid and             
          p.polizaid = mc.polizaid and
          m.movipolizaid = mc.movipolizaid and
          mc.estatusmovicaja='A' and
          mc.tipomovimientoid='00' and
          m.debe+m.haber>0;

   dultimoabono := coalesce(dultimoabono,dfechaultimopago);

--raise notice 'ult. abo. % - ult. pag. %',dultimoabono,dfechaultimopago;
   if dultimoabono>dfechaultimopago then

     dfechaultimopago := dultimoabono;
     update prestamos
        set fechaultimopago = dultimoabono
      where prestamoid = lprestamoid;

   end if;

--
-- Buscar amortizacion actual
--
   select coalesce(SUM(importeamortizacion-abonopagado),0.00)
     into famortizacion
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago=dfechapago and importeamortizacion-abonopagado>0;
    
--
-- Buscar amortizaciones vencidas
--
   select coalesce(SUM(round(importeamortizacion-abonopagado,2)),0.00)
     into fvencidas
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago<dfechapago and importeamortizacion-abonopagado>0;

--raise exception ' Vencidas % ',fvencidas;

  idiasint := dfechapago - dfechaultimopago;
  fcapital := round( famortizacion + fvencidas, 2);
  
  if dfechaultimopago=dfecha_otorga then
    --
    -- Para el caso de la 1era amortizacion agregar un dia de interes
    --
    if gcobrardiainicial=1 then
      idiasint := idiasint + 1;
    end if;
    --raise exception ' % %  %',dfechaultimopago,dfecha_otorga,idiasint;
  end if;

--
-- Calculo de interes Normal
--

  ftasanormal := tasareciprocidad(lprestamoid);

  if idiasint<0 then
    idiasint := 0;
  end if;

  update calculo
     set saldoinsoluto = fsaldoinsoluto,
         dias = idiasint,
         tasaintnormal = ftasanormal,
         tasaintmoratorio = ftasa_moratoria
   where calculoid=icalculonormalid;

  SELECT formula into sformula from calculo where calculoid=icalculonormalid;

  for rec in execute
      'SELECT round(' || sformula || ',2) as interes FROM calculo where calculoid='||icalculonormalid
  loop
    -- Preguntar a Juan lo del redondeo
    --raise exception '% -  % % % -  %',sformula,fsaldoinsoluto,idiasint,ftasanormal,rec.interes;

    if round(rec.interes,2)-trunc(round(rec.interes,2))>=0.50 then
      finteres := round(trunc(rec.interes)+1,2);
    else
      finteres := round(trunc(rec.interes),2);
    end if;
  end loop;


--
-- Calculo de interes moratorio
--

  fpagado:= fmontoprestamo - fsaldoinsoluto ;

  select t.diastraspasoavencida into idiastraspasoavencida
    from prestamos p, tipoprestamo t
   where p.prestamoid = lprestamoid and
         t.tipoprestamoid = p.tipoprestamoid;

  swmora:=0;
  fmormenor :=0;
  fmormayor :=0;

  if dfechaultimopago >=  dfecha_vencimiento then

    fmormayor:=fsaldoinsoluto*idiasint*ftasa_moratoria/100/360;

  else


    for amor in
      select * from amortizaciones
      where prestamoid=lprestamoid
      order by fechadepago
    loop

    if fpagado<amor.importeamortizacion then

      --raise notice ' fpagado % amortizacion % --% --%--%',fpagado,amor.importeamortizacion,amor.fechadepago,fmormenor,dfechaultimopago;

      if amor.fechadepago<dfechapago then
        -- Calcular moratorio
        if amor.fechadepago-dfechaultimopago<=idiastraspasoavencida then
          --raise notice ' mora menor 1 ';
          if dfechapago-amor.fechadepago>0 then

            if dfechaultimopago > amor.fechadepago then 
              idias:= dfechapago-dfechaultimopago;
            else 
              idias:= dfechapago-amor.fechadepago;
            --idias:= amor.fechadepago-dfechaultimopago;
            end if;

            if idias < 0 then
               idias:=0;
            end if;

            fmoratorio:=(amor.importeamortizacion-fpagado)*idias*ftasa_moratoria/100/360;

            --raise notice ' mora menor 2 %  -- %',idias,fmoratorio;

            if round(fmoratorio,2)-trunc(round(fmoratorio,2))>=0.50 then
               fmormenor := fmormenor + round(trunc(fmoratorio)+1,2);
            else
               fmormenor := fmormenor + round(trunc(fmoratorio),2);
            end if;

            fpagado:=0;
                     
          end if;
        end if;

        if amor.fechadepago-dfechaultimopago>idiastraspasoavencida then
            --raise notice ' mora mayor 1 ';
            if dfechapago-amor.fechadepago>0 then
              --   raise notice ' mora mayor 2 ';
              -- Aqui se agrega el calculo especial de credimax
            
                 if swmora=0 and amor.fechadepago-dfechaultimopago > idiastraspasoavencida then
                      idias:= dfechapago-amor.fechadepago;
                      fmoratorio:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;
                      swmora:=1;
                      -- Lo hacemos una vez y prendemos el switch
                  else
                      fmoratorio:=0;
                  end if;

                  --raise notice ' mora menor 3 %  -- %',idias,fmoratorio;
          
              -- Aqui termina 

              if round(fmoratorio,2)-trunc(round(fmoratorio,2))>=0.50 then
                 fmormayor := fmormayor+ round(trunc(fmoratorio)+1,2);
              else
                 fmormayor := fmormayor+ round(trunc(fmoratorio),2);
              end if;
              
              fpagado:=0;

           end if;
         
        end if;

      else
        exit;
      end if;
    else
      fpagado := fpagado - amor.importeamortizacion;
    end if;
    
    end loop;

  end if;

  if fmormayor = 0 and dfecha_vencimiento < dfechapago then
      idias:= dfechapago-dfechaultimopago;
      --idias:= dfechapago-dfecha_vencimiento;
      fmormayor:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;
      raise notice ' mora menor 4 %  -- % -- idiasven %',idias,fmormayor,idiastraspasoavencida;
  end if;

  fmoratorio:=coalesce(fmormenor,0)+coalesce(fmormayor,0);


-- Aqui termina el procedimiento
--

  -- No cobrar si la reciprocidad >= saldoprestamo

  if freciprocidad>=fsaldoprestamo and saplicareciprocidad='S' then
    fmoratorio := 0;
  end if;


if dfechaprestamo<dfechacobroiva then
  gIVA:=0;
  saplicaiva:='N';
end if;


  -- Iva y pago minimo

  if (1+gIVA)*(finteres+fmoratorio)<finteresminimo and dfechaultimopago<>dfechapago then
    -- Tomar el interes minimo como interes normal
    finteres := finteresminimo;
    fmoratorio := 0;
  end if;

  if saplicaiva='S' then
    fiva := round( (finteres+fmoratorio)*gIVA , 2);
  else
    if (finteres+fmoratorio)<finteresminimo and dfechaultimopago<>dfechapago then
      -- Tomar el interes minimo como interes normal
      finteres := finteresminimo;
      fmoratorio := 0;
      fiva:=0;
    end if;
  end if;


  ftotal := round(fcapital + finteres + fmoratorio + fiva, 2);

  idiasint := dfechapago - dfechaultimopago;

  if dfechaultimopago=dfecha_otorga then
    --
    -- Para el caso de la 1era amortizacion agregar un dia de interes
    --
    if gcobrardiainicial=1 then
      idiasint := idiasint + 1;
    end if;
    --raise exception ' % %  %',dfechaultimopago,dfecha_otorga,idiasint;
  end if;

  if idiasint<0 then
    idiasint := 0;
  end if;

  r.prestamoid   := lprestamoid;
  r.amortizacion := round(famortizacion,2);
  r.vencidas     := fvencidas;
  r.diasint      := idiasint;
  r.capital      := round(fcapital,2);
  r.interes      := round(finteres,2);
  r.moratorio    := round(fmoratorio,2);
  r.iva          := round(fiva,2);
  r.total        := round(ftotal,2);

  return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
