CREATE OR REPLACE FUNCTION spscalculopago(int4)
  RETURNS SETOF tcalculopago AS $BODY$
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
  
  sreferenciaprestamo character varying(18);

begin

  select iva,cobrardiainicial,aplicareciprocidad,fechacobroiva,moratoriopormonto,diasmoratoriopormonto,diasanualesprestamo
    into gIVA,gcobrardiainicial,saplicareciprocidad,dfechacobroiva,gmoratoriopormonto,gdiasmoratoriopormonto,gdiasanualesprestamo
    from empresa where empresaid=1;

--raise notice 'Calculando';

select fecha_otorga,fechaultimopago,trim(referenciaprestamo)
  into dfechaprestamo,dfecha2,sreferenciaprestamo
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
  from prestamos p, cat_cuentas_tipoprestamo ct, movicaja mc, movipolizas m
 where p.prestamoid = lprestamoid and
       ct.cat_cuentasid = p.cat_cuentasid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.cuentaid = ct.cuentaactivo
group by p.saldoprestamo,p.montoprestamo,p.claveestadocredito;

  fsaldoact:=coalesce(fsaldoact,0);
  fsaldocalculado:=coalesce(fsaldocalculado,0);

  raise notice ' Saldo Actual %  Saldo Calculado %',fsaldoact,fsaldocalculado;
  if fsaldoact<>fsaldocalculado and not exists (select prestamoid from prestamos where referenciaprestamo = sreferenciaprestamo||'CAS-') then
    raise notice 'Voy a updetear el saldo';
    update prestamos
       set saldoprestamo = fsaldocalculado
     where prestamoid=lprestamoid;
	 
  end if;

--  select aplicareciprocidad
--    into saplicareciprocidad
--    from empresa
--   where empresaid=1;

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


--if dfechaprestamo<dfechacobroiva then
--  gIVA:=0;
--  saplicaiva:='N';
--end if;



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
raise notice 'updateando calculo................';

 if icalculonormalid=5 then 
  update calculo
     set saldoinsoluto = fsaldoinsoluto,
         dias = idiasint,
         tasaintnormal = ftasanormal,
         tasaintmoratorio = ftasa_moratoria,
	 montoprestamo=fmontoprestamo
   where calculoid=icalculonormalid;
else

  update calculo
     set saldoinsoluto = fsaldoinsoluto,
         dias = idiasint,
         tasaintnormal = ftasanormal,
         tasaintmoratorio = ftasa_moratoria
   where calculoid=icalculonormalid;
end if;

  SELECT formula into sformula from calculo where calculoid=icalculonormalid;

  for rec in execute
      'SELECT round(' || sformula || ',2) as interes FROM calculo where calculoid='||icalculonormalid
  loop
  if icalculonormalid in (5,4) then 
     finteres=rec.interes;
  else
    if round(rec.interes,2)-trunc(round(rec.interes,2))>=0.50 then
      finteres := round(trunc(rec.interes)+1,2);
    else
      finteres := round(trunc(rec.interes),2);
    end if;
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

--  if dfechaultimopago >=  dfecha_vencimiento then

  --  fmormayor:=fsaldoinsoluto*idiasint*ftasa_moratoria/100/360;

  --else

    for amor in
      select * from amortizaciones
      where prestamoid=lprestamoid
      order by fechadepago
    loop

      if fpagado<amor.importeamortizacion then

      --raise notice ' fpagado % amortizacion % --% --%--%',fpagado,amor.importeamortizacion,amor.fechadepago,fmormenor,dfechaultimopago;

      if amor.fechadepago<dfechapago then
        -- Calcular moratorio
      --  if amor.fechadepago-dfechaultimopago<=idiastraspasoavencida then
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
              fmormenor := fmormenor + round(fmoratorio+1,2);
			  --  fmormenor := fmormenor + round(trunc(fmoratorio)+1,2);
            else
               fmormenor := fmormenor + round(fmoratorio,2);
			  --   fmormenor := fmormenor + round(trunc(fmoratorio),2);
            end if;

            fpagado:=0;
                     
          end if;
       -- end if;
		-- 31/05/2016 se comento esta parte ya que por cada amortizacion mayor le cobraba todo el saldo nuevamente
        --if amor.fechadepago-dfechaultimopago>idiastraspasoavencida then
            --raise notice ' mora mayor 1 * %', fmoratorio;
          --  if dfechapago-amor.fechadepago>0 then
              --raise noce ' mora mayor 2 ';
              -- Aqui se agrega el calculo especial de credimax
            
            --     if swmora=0 and amor.fechadepago-dfechaultimopago > idiastraspasoavencida then
            --          idias:= dfechapago-amor.fechadepago;
            --          fmoratorio:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;
                      --raise notice ' mora mayor 2 ** % % %',fsaldoinsoluto,idias,fmoratorio;
            --          swmora:=1;
                      -- Lo hacemos una vez y prendemos el switch
            --      else
            --          fmoratorio:=0;
            --      end if;

              --raise notice ' mora menor 3 %  -- % -- idiasven %',idias,fmoratorio,idiastraspasoavencida;
          
              -- Aqui termina 

            --  if round(fmoratorio,2)-trunc(round(fmoratorio,2))>=0.50 then
              --   fmormayor := fmormayor+ round(trunc(fmoratorio)+1,2);
            --  else
              --   fmormayor := fmormayor+ round(trunc(fmoratorio),2);
            --  end if;
              
              --fpagado:=0;

           --end if;
         
       -- end if;

      else
        exit;
      end if;
    else
      fpagado := fpagado - amor.importeamortizacion;
    end if;
    
    end loop;

 -- end if;

  --if fmormayor = 0 and dfecha_vencimiento < dfechapago then
    --  idias:= dfechapago-dfechaultimopago;
      --idias:= dfechapago-dfecha_vencimiento;
      --fmormayor:=(fsaldoinsoluto)*idias*ftasa_moratoria/100/360;
      --raise notice ' mora menor 4 %  -- % -- idiasven %',idias,fmormayor,idiastraspasoavencida;
  --end if;

	fmoratorio:=coalesce(fmormenor,0)+coalesce(fmormayor,0);


  --if CURRENT_DATE-dfechaultimopago>gdiasmoratoriopormonto and gmoratoriopormonto=1 then
    -- Calcular el moratrio en base al saldo
    --fmoratorio:=(CURRENT_DATE-dfechaultimopago)*fsaldoinsoluto*ftasa_moratoria/100/gdiasanualesprestamo;
  --end if;


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
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;