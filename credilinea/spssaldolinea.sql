CREATE or replace FUNCTION spssaldolinea(integer) RETURNS numeric
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
  
  fmonto_inicial numeric;
  fcargos numeric;
  fabonos numeric;
  sreferenciaprestamo character varying(18);

begin

-- Recalcular el saldo en base a pagos y disposiciones
select p.saldoprestamo, p.montoprestamo into fsaldoact,fmonto_inicial from prestamos p where p.prestamoid = lprestamoid;

select sum(mp.debe),sum(mp.haber) into fcargos,fabonos from movipolizas mp,prestamos p,tipoprestamo tp  where mp.prestamoid=p.prestamoid and p.tipoprestamoid=tp.tipoprestamoid and p.prestamoid=lprestamoid and (mp.cuentaid = tp.cuentaactivo or mp.cuentaid = tp.cuentaactivoren);

  fsaldoact:=coalesce(fsaldoact,0);
  
  fcargos:=coalesce(fcargos,0);
  fabonos:=coalesce(fabonos,0);

  fsaldocalculado:=fmonto_inicial-fcargos+fabonos;
  
  raise notice ' Saldo Actual %  Saldo Calculado %',fsaldoact,fsaldocalculado;
  if fsaldoact<>fsaldocalculado and not exists (select prestamoid from prestamos where referenciaprestamo = sreferenciaprestamo||'CAS-') then
    raise notice 'Voy a updetear el saldo';
    update prestamos
       set saldoprestamo = fsaldocalculado
     where prestamoid=lprestamoid;
	 
  end if;
	
	return fsaldocalculado;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
