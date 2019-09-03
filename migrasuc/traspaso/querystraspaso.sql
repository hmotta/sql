--set search_path to public,sucursal1;
--
-- Funcion que salda un prestamo
--
drop function saldaprestamo(char(18),numeric,date,numeric);
create or replace function saldaprestamo(char(18),numeric,date,numeric,char(2),char(24)) returns int as
$_$
declare
  preferenciaprestamo alias for $1;
  pcapitalpagado alias for $2;
  pfechaultimopago alias for $3;
  pmontoprestamo alias for $4;
  sserie_user alias for $5;
  scuentacaja alias for $6;


  fAbono numeric;
  fAplicar numeric;
  fInteresPagado numeric;
  amor record;

  stipoprestamoid char(3);
  scuentaactivo char(24);
  scuentaintnormal char(24);

  lsocioid int4;
  lprestamoid int4;
 
--
-- Parametros del usuario
--

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;

  pmovipolizaid2 int4;
  pmovicajaid int4;
  pejercicio int4;
  pperiodo int4;
begin

  fAbono := round(pcapitalpagado,2);
  fInteresPagado := 0;

--
-- Actualizar tabla de prestamos, disminuir el saldo del prestamo y
-- actualizar fecha de ultimo pago, importante ya que a partir de ahi calculamos
-- el interes normal
--

  update prestamos
     set saldoprestamo = montoprestamo - fAbono,
         fechaultimopago = pfechaultimopago
   where referenciaprestamo=preferenciaprestamo;

--
-- Buscamos cuentas contables para el tipo de prestamo
--
  select tipoprestamoid,socioid,prestamoid into stipoprestamoid,lsocioid,lprestamoid
    from prestamos
   where referenciaprestamo=preferenciaprestamo;   
  
  select cuentaactivo,cuentaintnormal into scuentaactivo,scuentaintnormal
    from tipoprestamo
   where tipoprestamoid = stipoprestamoid;



  pejercicio:=cast(date_part('year',pfechaultimopago) as int4);
  pperiodo:=cast(date_part('month',pfechaultimopago) as int4);

--
-- Actualizar tabla de amortizaciones
--
  if fAbono>0 then
    for amor in
        select *
          from amortizaciones
         where prestamoid=lprestamoid
      order by fechadepago
    loop

      fAplicar := amor.importeamortizacion - amor.abonopagado;

      if fAbono>=fAplicar then
        update amortizaciones
           set abonopagado = importeamortizacion,
               ultimoabono = pfechaultimopago
         where amortizacionid=amor.amortizacionid;
         fAbono := fAbono - fAplicar;
      else
        if fAbono>0 then
          update amortizaciones
             set abonopagado = abonopagado+fAbono,
                 ultimoabono = pfechaultimopago
           where amortizacionid=amor.amortizacionid;
           fAbono := 0;
        end if;
      end if;
    end loop;
  end if;

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(pejercicio,pperiodo,'D',sserie_user,'A');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'A',pnumero_poliza,pejercicio,pperiodo,' ',pfechaultimopago,'D',' ',' ','Migración Inicial',pfechaultimopago);

-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,scuentaactivo,' ','C',pmontoprestamo,0,' ',' ','Caja Migración Inicial');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,pcapitalpagado,' ',' ','Capital Migración Inicial');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentacaja,' ','A',0,pmontoprestamo-pcapitalpagado,' ',' ','Capital Migración Inicial');

   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = sserie_user;

  lreferenciacaja := lreferenciacaja+1;   

   select *
     into pmovicajaid
     from spimovicajat(lsocioid,'00',ppolizaid,lreferenciacaja,sserie_user,pmovipolizaid,lprestamoid,'A',NULL);


return 1;
end
$_$
language 'plpgsql';

--
-- Funcion que inicializa el saldo de movimientos
--
create or replace function movinicial(char(15),date,numeric,char(2)) returns int as
$_$
declare
--
-- Parametros
--
  pclavesocioint alias for $1;
  pfecha alias for $2;
  psaldo alias for $3;
  ptipomovimientoid alias for $4;


  sserie_user char(2);
  scuentacaja char(24);
  scuentadeposito char(24);

  lsocioid int4;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;

  pmovipolizaid2 int4;
  pmovicajaid int4;
begin

--
-- **** OJO poner la serie y cuenta de caja correspondiente ****
--
  sserie_user := 'Z';
  scuentacaja := '7-01-01-  -  -  -       ';

--
-- Tomaremos el saldo inicial como un deposito
--

-- Buscamos la cuenta de deposito y el socio

  select cuentadeposito into scuentadeposito
   from tipomovimiento where tipomovimientoid=ptipomovimientoid;

  select socioid into lsocioid
   from socio
  where clavesocioint = pclavesocioint;

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',sserie_user,'A');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,sserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','Saldo Inicial',pfecha);

-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,scuentacaja,' ','C',psaldo,0,' ',' ','Caja Saldo Inicial');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentadeposito,' ','A',0,psaldo,' ',' ','Caja Saldo Inicial');

   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = sserie_user;

  lreferenciacaja := lreferenciacaja+1;   

  select *
    into pmovicajaid
   from spimovicajat(lsocioid,ptipomovimientoid,ppolizaid,lreferenciacaja,sserie_user,pmovipolizaid,NULL,'A',NULL);

return 1;
end
$_$
language 'plpgsql';


--
-- Funcion para depositos de movimientos
--
drop function depositomov(char(15),date,numeric,char(2),char(2),char(24));
create or replace function depositomov(char(15),date,numeric,char(2),char(2),char(24)) returns int as
$_$
declare
--
-- Parametros
--
  pclavesocioint alias for $1;
  pfecha alias for $2;
  psaldo alias for $3;
  ptipomovimientoid alias for $4;
  sserie_user alias for $5;
  scuentacaja alias for $6;
  scuentadeposito char(24);

  lsocioid int4;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;

  pmovipolizaid2 int4;
  pmovicajaid int4;
begin

--
-- **** OJO poner la serie y cuenta de caja correspondiente ****
--
--
-- Tomaremos el saldo inicial como un deposito
--

-- Buscamos la cuenta de deposito y el socio

  select cuentadeposito into scuentadeposito
   from tipomovimiento where tipomovimientoid=ptipomovimientoid;

  select socioid into lsocioid
   from socio
  where clavesocioint = pclavesocioint;

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',sserie_user,'A');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipoliza(preferencia,sserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','Saldo Inicial',pfecha);

-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,scuentacaja,' ','C',psaldo,0,' ',' ','Movimiento del dia');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentadeposito,' ','A',0,psaldo,' ',' ','movimiento del dia');

   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = sserie_user;

  lreferenciacaja := lreferenciacaja+1;   

  select *
    into pmovicajaid
   from spimovicajat(lsocioid,ptipomovimientoid,ppolizaid,lreferenciacaja,sserie_user,pmovipolizaid,NULL,'A',NULL);

return 1;
end
$_$
language 'plpgsql';

--
-- Funcion para retiros de movimientos
--
drop function retiromov(char(15),date,numeric,char(2),char(2),char(24));
create or replace function retiromov(char(15),date,numeric,char(2),char(2),char(24)) returns int as
$_$
declare
--
-- Parametros
--
  pclavesocioint alias for $1;
  pfecha alias for $2;
  psaldo alias for $3;
  ptipomovimientoid alias for $4;
  sserie_user alias for $5;
  scuentacaja alias for $6;

  scuentadeposito char(24);

  lsocioid int4;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;

  pmovipolizaid2 int4;
  pmovicajaid int4;
begin

--
-- **** OJO poner la serie y cuenta de caja correspondiente ****
--
--
-- Tomaremos el saldo como un retiro
--

-- Buscamos la cuenta de deposito y el socio

  select cuentaretiro into scuentadeposito
   from tipomovimiento where tipomovimientoid=ptipomovimientoid;

  select socioid into lsocioid
   from socio
  where clavesocioint = pclavesocioint;

--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',sserie_user,'A');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipoliza(preferencia,sserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','Saldo Inicial',pfecha);

-- Detalle de la poliza


   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,scuentacaja,' ','A',0,psaldo,' ',' ','Movimiento del dia');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentadeposito,' ','C',psaldo,0,' ',' ','movimiento del dia');

   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = sserie_user;

  lreferenciacaja := lreferenciacaja+1;   

  select *
    into pmovicajaid
   from spimovicajat(lsocioid,ptipomovimientoid,ppolizaid,lreferenciacaja,sserie_user,pmovipolizaid,NULL,'A',NULL);

return 1;
end
$_$
language 'plpgsql';


create or replace function spipolizasfecha(integer,char(2),char(1),integer,integer,integer,char(1),date,char(1),char(1),char(3),text,date) returns int4 as
$_$
declare

  preferencia            alias for $1;
  pserie                 alias for $2;
  ptipo                  alias for $3;
  pnumero_poliza         alias for $4;
  pejercicio             alias for $5;
  pperiodo               alias for $6;
  pidentificacion        alias for $7;
  pfecha                 alias for $8;
  ptipo_poliza           alias for $9;
  pclase_poliza          alias for $10;
  pdiario_agrupador      alias for $11;
  pconcepto_poliza       alias for $12;
  pfecha_fin_aceptacion  alias for $13;

  pref int4;
  pnopol int4;
begin

   if pfecha<>CURRENT_DATE then
     -- DESCOMENTAR EL RAISE SI SE QUIERE VALIDACION
     -- raise exception 'Verifique la fecha, la fecha proporcionada es diferente a la fecha del SERVIDOR';
   end if;

   select coalesce(max(numero_poliza),0)
    into pnopol
    from polizas
   where ejercicio=pejercicio and
         periodo=pperiodo and
         tipo_poliza=ptipo_poliza;

   pnopol:=pnopol+1;

   select coalesce(max(referencia),0) into pref
     from polizas where seriepoliza=pserie and tipo=ptipo;

   pref := pref+1;

   insert into polizas( referencia,seriepoliza,tipo,numero_poliza,ejercicio,periodo,fechapoliza,tipo_poliza,clase_poliza,diario_agrupador,concepto_poliza,fecha_fin_aceptacion )
    values( pref,pserie,ptipo,pnopol,pejercicio,pperiodo,pfecha,ptipo_poliza,pclase_poliza,pdiario_agrupador,pconcepto_poliza,pfecha_fin_aceptacion );
            
return currval('polizas_polizaid_seq');
end
$_$
language 'plpgsql' security definer;


drop function saldaamortiza(char(18),numeric,date);
create or replace function saldaamortiza(char(18),numeric,date) returns int as
$_$
declare
  preferenciaprestamo alias for $1;
  pcapitalpagado alias for $2;
  pfechaultimopago alias for $3;

  fAbono numeric;
  fAplicar numeric;
  amor record;
  dnumamor int4;
  lprestamoid int4;
 
begin

  fAbono := round(pcapitalpagado,2);

--
-- Actualizar tabla de prestamos, disminuir el saldo del prestamo y
-- actualizar fecha de ultimo pago, importante ya que a partir de ahi calculamos
-- el interes normal
--

--
-- Buscamos cuentas contables para el tipo de prestamo
--
  select prestamoid into lprestamoid
    from prestamos
   where referenciaprestamo=preferenciaprestamo;   

  select count(amortizacionid) into dnumamor from amortizaciones where prestamoid = lprestamoid;

  update prestamos
     set saldoprestamo = montoprestamo - fAbono,
         fechaultimopago = pfechaultimopago, numero_de_amor=dnumamor
   where referenciaprestamo=preferenciaprestamo;


--
-- Actualizar tabla de amortizaciones
--
  update amortizaciones
           set abonopagado = 0,
               ultimoabono = fechadepago
         where prestamoid=lprestamoid;

  if fAbono>0 then
    for amor in
        select *
          from amortizaciones
         where prestamoid=lprestamoid
      order by fechadepago
    loop

      fAplicar := amor.importeamortizacion - amor.abonopagado;

      if fAbono>=fAplicar then
        update amortizaciones
           set abonopagado = importeamortizacion,
               ultimoabono = pfechaultimopago
         where amortizacionid=amor.amortizacionid;
         fAbono := fAbono - fAplicar;
      else
        if fAbono>0 then
          update amortizaciones
             set abonopagado = abonopagado+fAbono,
                 ultimoabono = pfechaultimopago
           where amortizacionid=amor.amortizacionid;
           fAbono := 0;
        end if;
      end if;
    end loop;
  end if;


return 1;
end
$_$
language 'plpgsql';

--select * from saldaamortiza('22517-X',25704.06,'2005-11-14');
--select * from saldaamortiza('XX05246',1000,'2005-09-26');


--
-- Name: movinversion(character, integer, character, character, date, character, numeric, character, numeric, date, date); Type: FUNCTION; Schema: public; Owner: sistema
--

drop FUNCTION movinversion(character, integer, character, character, date, character, numeric, character, numeric, date, date);
CREATE FUNCTION movinversion(character, integer, character, character, date, character, numeric, character, numeric, date, date) RETURNS integer
    AS $_$
declare
  pmovimiento alias for $1;
  pinversionid alias for $2;
  ptipoinversionid alias for $3;
  pserie alias for $4;
  pfecha alias for $5;
  pclavesocioint alias for $6;
  pdepositoinversion alias for $7;
  pcuentacaja alias for $8;
  pinteresre alias for $9;
  pfechainversion alias for $10;
  pfechavencimiento alias for $11;

  linversionid int4;
  psocioid int4;
  pcuentapasivo char(24);
  pcuentaintinver char(24);
  pcuentaivainver char(24);
  pplazo          int;
  ptasa_normal_inversion numeric;
  pcalculoid      int4;
  paplicaivainversion char(1);
  lreferenciainversion int4;

  ppolizaid int4;
  pmovipolizaid int4;
  pmovipolizaid2 int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;
  pmovicajaid int4;

  r inversion%rowtype;

begin

  select socioid into psocioid
    from socio
   where clavesocioint=pclavesocioint;

  select cuentapasivo,cuentaintinver,cuentaivainver,plazo,tasa_normal_inversion,calculoid,
         aplicaivainversion
    into pcuentapasivo,pcuentaintinver,pcuentaivainver,pplazo,ptasa_normal_inversion,pcalculoid,
         paplicaivainversion
    from tipoinversion
   where tipoinversionid=ptipoinversionid;


------------------------------------------
-- Caso en que es nueva inversion
------------------------------------------
  if pmovimiento='1' then

    select max(referenciainversion) into lreferenciainversion
      from inversion;

    lreferenciainversion := coalesce(lreferenciainversion,0)+1;

    select * into linversionid
      from spiinversion(psocioid,ptipoinversionid,lreferenciainversion,pserie,pdepositoinversion,0,0,pfechainversion,pfechavencimiento,pfechainversion,0,ptasa_normal_inversion,0,pfechainversion,pfechainversion,'S');

-----------------------------------------
-- Dar de alta la poliza contable
-----------------------------------------
    select *
      into pnumero_poliza,preferencia
      from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie,'A');

-- Encabezado de la poliza
    select * 
      into ppolizaid
      from spipolizasfecha(preferencia,pserie,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','Migración Inicial',pfecha);

-- Detalle de la poliza
 
     select *
       into pmovipolizaid
       from spimovipoliza(ppolizaid,pcuentacaja,' ','C',pdepositoinversion,0,' ',' ','Caja Migración Inicial');

     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,pcuentapasivo,' ','A',0,pdepositoinversion,' ',' ','Capital Migración Inicial');

     select coalesce(max(referenciacaja),0)
       into lreferenciacaja
       from movicaja
      where seriecaja = pserie;

     lreferenciacaja := lreferenciacaja+1;   

      select *
        into pmovicajaid
       from spimovicajat(psocioid,'IN',ppolizaid,lreferenciacaja,pserie,pmovipolizaid,NULL,'A',linversionid);

  end if;
-- Termina caso 1



------------------------------------------
-- Caso en que retira inversion
------------------------------------------

  if pmovimiento='2' then

    for r in
      select * from spsinversion(pinversionid)
    loop

      if pinteresre<>r.interesinversion then
         -- Tomamos siempre el interes pasado en el parametro
         r.interesinversion := pinteresre;
      end if;

--      if paplicaivainversion='S' then

        select *
          into pnumero_poliza,preferencia
          from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie,'A');

         -- Encabezado de la poliza
        select * 
          into ppolizaid
          from spipolizasfecha(preferencia,pserie,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','Migración Inicial',pfecha);

        -- Detalle de la poliza
 
        select *
          into pmovipolizaid
          from spimovipoliza(ppolizaid,pcuentacaja,' ','A',0,pdepositoinversion+r.interesinversion,' ',' ','Caja Migración Inicial');

        select *
          into pmovipolizaid2
          from spimovipoliza(ppolizaid,pcuentapasivo,' ','C',pdepositoinversion,0,' ',' ','Capital Migración Inicial');

        select *
          into pmovipolizaid2
          from spimovipoliza(ppolizaid,pcuentaintinver,' ','C',r.interesinversion,0,' ',' ','Interes Migración Inicial');


    select coalesce(max(referenciacaja),0)
      into lreferenciacaja
      from movicaja
     where seriecaja = pserie;

    lreferenciacaja := lreferenciacaja+1;

    select *
      into pmovicajaid
      from spimovicajat(psocioid,'IN',ppolizaid,lreferenciacaja,pserie,pmovipolizaid,NULL,'A',pinversionid);

    update inversion
       set retiroinversion = depositoinversion,
           fechapagoanterior = fechapagoinversion,
           fechapagoinversion = pfecha
     where inversionid=pinversionid;
    
--    return next r;
    end loop;

  end if;



return 1;
end
$_$
LANGUAGE plpgsql;



drop FUNCTION spimovicajat(integer, character, integer, integer, character, integer, integer, character, integer);
CREATE FUNCTION spimovicajat(integer, character, integer, integer, character, integer, integer, character, integer) RETURNS integer
    AS $_$
declare
   psocioid          alias for $1;	
   ptipomovimientoid alias for $2;
   ppolizaid         alias for $3;
   preferenciacaja   alias for $4;
   pseriecaja        alias for $5;
   pmovipolizaid     alias for $6;
   pprestamoid       alias for $7;
   pestatusmovicaja  alias for $8;
   pinversionid      alias for $9;

   fprestamos numeric;
   fretiro numeric;
   fdeposito numeric;
   fsaldo  numeric;

   iestatussocio int;

   saplicasaldo char(1);
   saceptadeposito char(1);
   saceptaretiro   char(1);

   stiposocioid char(2);

   fmontopartesocial numeric;
   fsaldopa numeric;
   ipartesocialcompleta int4;

   lsocioid int4;

   irepetido int4;
   pefectivo integer;
begin
	pefectivo:=3;
   if ptipomovimientoid='00' then
     -- Validar que el prestamo corresponda al socio

     select socioid into lsocioid
       from prestamos where prestamoid=pprestamoid;
     if lsocioid<>psocioid then
       raise exception 'Verifique el prestamo no corresponde al socio !!!';
     end if;
   end if;

   if ptipomovimientoid='RM' then
     -- Validar que no haya salido por cheque

     select count(p.*) into irepetido
       from movibanco m, polizas p
      where m.prestamoid = pprestamoid and
            p.polizaid=m.polizaid and
            substr(p.concepto_poliza,1,9)<>'CANCELADO';

     irepetido:=coalesce(irepetido,0);

     if irepetido>0 then
       raise exception 'El prestamo ya fue retirado mediante un cheque !!!';
     end if;
   end if;



   if ptipomovimientoid='IN' then
     -- Validar que la inversion corresponda al socio

     select socioid into lsocioid
       from inversion where inversionid=pinversionid;
     if lsocioid<>psocioid then
       raise exception 'Verifique la inversion no corresponde al socio !!!';
     end if;

   end if;

   select estatussocio,tiposocioid into iestatussocio,stiposocioid
     from socio
    where socioid=psocioid;

   if stiposocioid='02' and
      (ptipomovimientoid<>'00' and ptipomovimientoid<>'PA' and
       ptipomovimientoid<>'RE' and ptipomovimientoid<>'CH' and
       ptipomovimientoid<>'MG' and ptipomovimientoid<>'BS') then

     select montopartesocial,partesocialcompleta
       into fmontopartesocial,ipartesocialcompleta
       from empresa where empresaid=1;

     if ipartesocialcompleta=1 then
       -- Validar que tenga la parte social
       select sum(mp.debe)-sum(mp.haber) into fsaldopa
         from movicaja mc, movipolizas mp
        where mc.socioid=psocioid and
              mc.tipomovimientoid='PA' and
              mp.movipolizaid=mc.movipolizaid;
       fsaldopa:=coalesce(fsaldopa,0);

     end if;
   end if;

   select aplicasaldo,aceptadeposito,aceptaretiro
     into saplicasaldo,saceptadeposito,saceptaretiro
     from tipomovimiento where tipomovimientoid=ptipomovimientoid;


   select sum(p.montoprestamo/tp.tantos) into fprestamos
    from prestamos p, tipoprestamo tp
   where p.socioid = psocioid and
         p.saldoprestamo>0 and
         tp.tipoprestamoid = p.tipoprestamoid and
         tp.tipomovimientoid = ptipomovimientoid and
         tp.tantos>0 and
         p.claveestadocredito<>'008';

   select debe,haber into fdeposito,fretiro
    from movipolizas
   where movipolizaid=pmovipolizaid;

   fdeposito := coalesce(fdeposito,0);
   fretiro := coalesce(fretiro,0);

   fprestamos := coalesce(fprestamos,0);

  
   -- Validar que no retire mas de lo que tiene en Saldo
   select sum(mp.debe)-sum(mp.haber) into fsaldo
     from movicaja mc, movipolizas mp
    where mc.socioid=psocioid and
          mc.tipomovimientoid=ptipomovimientoid and
          mp.movipolizaid=mc.movipolizaid;

   fsaldo:=coalesce(fsaldo,0);

   insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,efectivo)
    values(psocioid,ptipomovimientoid,ppolizaid,preferenciacaja,pseriecaja,pmovipolizaid,pprestamoid,pestatusmovicaja,pinversionid,pefectivo);
            
return currval('movicaja_movicajaid_seq');
end
$_$
LANGUAGE plpgsql SECURITY DEFINER;

drop FUNCTION movprestamo(character, character, date, numeric, numeric, numeric, numeric, character, character);
CREATE FUNCTION movprestamo(character, character, date, numeric, numeric, numeric, numeric, character, character) RETURNS integer
    AS $_$
declare

  pclavesocioint alias for $1;
  preferenciaprestamo alias for $2;
  pfecha alias for $3;
  pcapital alias for $4;
  pinteres alias for $5;
  pmoratorio alias for $6;
  piva alias for $7;
  pcuentacaja alias for $8;
  pserie_user alias for $9;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;

  pmovipolizaid2 int4;
  pmovicajaid int4;

  scuentaactivo char(24);
  scuentaintnormal char(24);
  scuentaintmora char(24);
  scuentaiva char(24);
  stipoprestamoid char(3);

  lsocioid int4;
  lprestamoid int4;

  fAbono numeric;
  fAplicar numeric;
  fInteresPagado numeric;
  amor record;

begin

  fAbono := round(pcapital,2);
  fInteresPagado := 0;

  select tipoprestamoid,socioid,prestamoid into stipoprestamoid,lsocioid,lprestamoid
    from prestamos
   where referenciaprestamo=preferenciaprestamo;   
  
  select cuentaactivo,cuentaintnormal,cuentaintmora,cuentaiva
    into scuentaactivo,scuentaintnormal,scuentaintmora,scuentaiva
    from tipoprestamo
   where tipoprestamoid = stipoprestamoid;

  update prestamos
     set saldoprestamo = saldoprestamo - fAbono,
         fechaultimopago = pfecha
   where referenciaprestamo=preferenciaprestamo;

--
-- Actualizar tabla de amortizaciones
--
  if fAbono>0 then
    for amor in
        select *
          from amortizaciones
         where prestamoid=lprestamoid
      order by fechadepago
    loop

      fAplicar := amor.importeamortizacion - amor.abonopagado;

      if fAbono>=fAplicar then
        update amortizaciones
           set abonopagado = importeamortizacion,
               ultimoabono = pfecha
         where amortizacionid=amor.amortizacionid;
         fAbono := fAbono - fAplicar;
      else
        if fAbono>0 then
          update amortizaciones
             set abonopagado = abonopagado+fAbono,
                 ultimoabono = pfecha
           where amortizacionid=amor.amortizacionid;
           fAbono := 0;
        end if;
      end if;
    end loop;
  end if;


--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','Migración Inicial',pfecha);

-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,pcuentacaja,' ','C',pcapital+pinteres+pmoratorio+piva,0,' ',' ','Caja Migración Inicial');

   if pcapital>0 then
     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,pcapital,' ',' ','Capital Migración Inicial');
   end if;

   if pinteres>0 then
     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaintnormal,' ','A',0,pinteres,' ',' ','Capital Migración Inicial');
   end if;

   if pmoratorio>0 then
     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaintmora,' ','A',0,pmoratorio,' ',' ','Capital Migración Inicial');
   end if;

   if piva>0 then
     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaiva,' ','A',0,piva,' ',' ','Capital Migración Inicial');
   end if;


   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = pserie_user;

   lreferenciacaja := lreferenciacaja+1;   

   select *
     into pmovicajaid
     from spimovicajat(lsocioid,'00',ppolizaid,lreferenciacaja,pserie_user,pmovipolizaid,lprestamoid,'A',NULL);


return 1;
end
$_$
LANGUAGE plpgsql;



CREATE or replace FUNCTION spiprestamos(character, numeric, numeric, integer, date, date, character, numeric, numeric, integer, integer, integer, integer, date, character, numeric, character, character, character, integer, integer, integer, integer) RETURNS integer
    AS $_$
declare

 preferenciaprestamo alias for $1;
 pmontoprestamo      alias for $2;
 psaldoprestamo      alias for $3;
 pnumero_de_amor     alias for $4;
 pfecha_otorga       alias for $5;
 pfecha_vencimiento  alias for $6;
 ptipoprestamoid     alias for $7;
 ptasanormal         alias for $8;
 ptasa_moratoria     alias for $9;
 psocioid            alias for $10;
 pdias_de_cobro      alias for $11;
 pmeses_de_cobro     alias for $12;
 pdia_mes_cobro      alias for $13;
 pfecha_1er_pago     alias for $14;
 pclavegarantia      alias for $15;
 pmonto_garantia     alias for $16;
 pclaveestadocredito alias for $17;
 pautorizaprestamo   alias for $18;
 pfinalidadprestamo  alias for $19;
 pcalculonormalid    alias for $20;
 pcalculomoratorioid alias for $21;
 pessobreprestamo    alias for $22;
 psolicitudprestamoid alias for $23;

 ahorro numeric;
 ahorromin varchar;
 prestamossocio integer;
 itantos integer;
 stipomovimientoid char(2);

 sreferenciaprestamo char(18);

 lgenero int4;

 sclavesocioint char(15);
begin


   insert into prestamos(referenciaprestamo, montoprestamo, saldoprestamo, numero_de_amor, fecha_otorga, fecha_vencimiento, tipoprestamoid, tasanormal, tasa_moratoria, socioid, dias_de_cobro, meses_de_cobro, dia_mes_cobro, fecha_1er_pago, clavegarantia, monto_garantia, claveestadocredito, usuarioid, clavefinalidad, calculonormalid, calculomoratorioid, fechaultimopago,solicitudprestamoid)
    values( preferenciaprestamo,pmontoprestamo, pmontoprestamo, pnumero_de_amor, pfecha_otorga, pfecha_vencimiento, ptipoprestamoid, ptasanormal, ptasa_moratoria, psocioid, pdias_de_cobro, pmeses_de_cobro, pdia_mes_cobro, pfecha_1er_pago, pclavegarantia, pmonto_garantia, '001', pautorizaprestamo, pfinalidadprestamo, pcalculonormalid, pcalculomoratorioid, pfecha_otorga,psolicitudprestamoid);

  
  -- Generar las amortizaciones aqui
  select * into lgenero from generaramortizaciones(preferenciaprestamo,0,pfecha_otorga);

 --  raise exception 'Llega bien al alta';         
return currval('prestamos_prestamoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
