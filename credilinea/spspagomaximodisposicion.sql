CREATE or replace FUNCTION spspagomaximodisposicion(integer,numeric) RETURNS SETOF tcalculopago
    AS $_$
declare
  pprestamoid alias for $1;
  pmonto_dispuesto alias for $2;
  r tcalculopago%rowtype;
  rec record;
  
  famortizacion numeric;
  fvencidas     numeric;
  idiasint      integer;
  fcapital      numeric;
  finteres      numeric;
  fmoratorio    numeric;
  fiva          numeric;
  ftotal        numeric;

  
  fsaldoprestamo   numeric;
  
  ftasanormal      numeric;
  ftasa_moratoria  numeric;
  

  fsaldoinsoluto   numeric;

  saplicaiva       char(1);
  sformula text;
  icalculonormalid int4;
  icalculomoratorioid int4;

  

  itantos int4;
  freciprocidad numeric;

  dultimoabono date;

  saplicareciprocidad char(1);

  fsaldoact numeric;
  fsaldocalculado numeric;

  sclaveestadocredito char(3);

  gIVA numeric;
  dfechaprestamo date;
  dfecha2 date;
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

  select iva into gIVA from empresa where empresaid=1;

--raise notice 'Calculando';

  famortizacion := 0;
  fvencidas     := 0;
  idiasint      := 0;
  fcapital      := 0;
  finteres      := 0;
  fmoratorio    := 0;
  fiva          := 0;
  ftotal        := 0;
--
-- Calculo de interes Normal
--
  icalculonormalid:=7;

  select tasanormal,montoprestamo into ftasanormal,fsaldoinsoluto from prestamos where prestamoid=pprestamoid;
  
  idiasint := 30;
  raise notice 'updateando calculo................';
  raise notice 'fsaldoinsoluto=%',fsaldoinsoluto;
  raise notice 'idiasint=%',idiasint;
  raise notice 'ftasanormal=%',ftasanormal;
  
  update calculo
     set saldopromdiario = pmonto_dispuesto,
         dias = idiasint,
         tasaintnormal = ftasanormal,
         tasaintmoratorio = 0
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
-- Calculo de Pago de capital
--


  icalculonormalid:=6;
  
  raise notice 'updateando calculo................';

  update calculo
     set 
         saldoinsoluto = pmonto_dispuesto
   where calculoid=icalculonormalid;


  SELECT formula into sformula from calculo where calculoid=icalculonormalid;

  for rec in execute
      'SELECT round(' || sformula || ',2) as capital FROM calculo where calculoid='||icalculonormalid
  loop
  
    if round(rec.capital,2)-trunc(round(rec.capital,2))>=0.50 then
      fcapital := round(trunc(rec.capital)+1,2);
    else
      fcapital := round(trunc(rec.capital),2);
    end if;
  
  end loop;
  

  if gIVA>0 then
      fiva := round( (finteres)*gIVA , 2);
  end if;


  ftotal := round(fcapital + finteres  + fiva, 2);

  idiasint := 30;


  r.prestamoid   := pprestamoid;
  r.amortizacion := 0;
  r.vencidas     := 0;
  r.diasint      := idiasint;
  r.capital      := round(fcapital,2);
  r.interes      := round(finteres,2);
  r.moratorio    := 0;
  r.iva          := round(fiva,2);
  r.total        := round(ftotal,2);

  return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;