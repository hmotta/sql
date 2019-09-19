CREATE OR REPLACE FUNCTION spscalculopagoamortizacion(int4, numeric)
  RETURNS SETOF tcalculopago AS $BODY$
declare
  lprestamoid alias for $1;
  pamortizacion alias for $2;
  
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

  ptipoprestamoid char(3);
  noamor integer;

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

  famortizacion := 0;
  fvencidas     := 0;
  idiasint      := 0;
  fcapital      := 0;
  finteres      := 0;
  fmoratorio    := 0;
  fiva          := 0;
  ftotal        := 0;

  
  select p.montoprestamo,p.saldoprestamo,p.tasanormal,p.tasa_moratoria,p.fecha_otorga,p.fecha_1er_pago,
         tp.aplicaivaprestamo,p.calculonormalid,p.calculomoratorioid,tp.tantos,p.tipoprestamoid,p.fechaultimopago
    into fmontoprestamo,fsaldoprestamo,ftasanormal,ftasa_moratoria,dfecha_otorga,dfecha_1er_pago,
         saplicaiva,icalculonormalid,icalculomoratorioid,itantos,ptipoprestamoid,dfechaultimopago
    from prestamos p, tipoprestamo tp
   where p.prestamoid=lprestamoid and
         tp.tipoprestamoid = p.tipoprestamoid;

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

   dultimoabono := coalesce(dultimoabono,dfecha_otorga);

   --raise notice 'ult. abo. % - ult. pag. %',dultimoabono,dfechaultimopago;
   if dultimoabono<>dfechaultimopago then

     dfechaultimopago := dultimoabono;
     update prestamos
        set fechaultimopago = dultimoabono
      where prestamoid = lprestamoid;

   end if;

--
-- Calculo de interes Normal
--
--SE ADICIONO EL C17, C18 Y C19 29MAY09, YA QUE SE SE CREARON PRODUCTOS NUEVOS MISMAS CONSIDERACIONES SALDOS INSOLUTOS PF 

  --calculo para el tipo de prestamo C12, C13, C14, C15, C16, nuevos-> C17,C18,C19

  noamor:=0;
  fcapital := 0;
  finteres := 0;
  
  for amor in
   select *
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago<=CURRENT_DATE and
          (importeamortizacion-abonopagado>0.10) order by fechadepago
  loop
   if noamor<pamortizacion then
    finteres:=finteres+(amor.interesnormal-amor.interespagado);
    fcapital:=fcapital+(amor.importeamortizacion-amor.abonopagado);
    noamor:=noamor+1;
   end if; 
  end loop;

  raise notice ' interes % ',finteres;
 
  --
  -- Calculo de interes moratorio
  --
  
  noamor:=0;
  fmoratorio := 0;

  for amor in
   select *
     from amortizaciones
    where prestamoid=lprestamoid and fechadepago<CURRENT_DATE and
          importeamortizacion-abonopagado>0 order by fechadepago 
  loop
  if noamor<pamortizacion then
    if dfechaultimopago>amor.fechadepago then
      idiasint := CURRENT_DATE - dfechaultimopago;
    else
      idiasint := CURRENT_DATE - amor.fechadepago;
    end if;

    if idiasint<0 then
      idiasint := 0;
    end if;

    update calculo
       set saldoinsoluto = fsaldoinsoluto,
           amortizacion = amor.importeamortizacion-amor.abonopagado,
           dias = idiasint,
           tasaintnormal = ftasanormal,
           tasaintmoratorio = ftasa_moratoria
     where calculoid=icalculomoratorioid;

    SELECT formula into sformula from calculo where calculoid=icalculomoratorioid;

    for rec in execute
             'SELECT ' || sformula || ' as interes FROM calculo where calculoid='||icalculomoratorioid
    loop
      
      --if round(rec.interes,4)-trunc(round(rec.interes,4))>=0.50 then
      --  fmoratorio := fmoratorio+round(trunc(rec.interes)+1,2);
      --else
      --  fmoratorio := fmoratorio+round(trunc(rec.interes),2);
      --end if;

      fmoratorio := fmoratorio + round(rec.interes,2);

      --raise notice '% Dias % Amortizacion % Tasa % El interes acumulado es %',dfechaultimopago,idiasint,amor.numamortizacion,ftasa_moratoria,fmoratorio;
    end loop;

  noamor:=noamor+1;
  end if; 
 end loop;

 
  if saplicaiva='S' then
      fiva := round( (finteres+fmoratorio)*gIVA , 2);
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