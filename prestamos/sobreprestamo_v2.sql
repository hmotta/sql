CREATE OR REPLACE FUNCTION sobreprestamo(character, numeric, numeric, numeric, numeric, date, character, character, character) RETURNS integer
    AS $_$
declare
  preferenciaprestamo alias for $1;
  pcapitalpagado      alias for $2;
  pinterespagado      alias for $3;
  pmoratoriopagado    alias for $4;
  pivapagado          alias for $5;
  pfechaultimopago    alias for $6;
  psobreprestamo      alias for $7;
  sserie_user         alias for $8;
  scuentacaja         alias for $9;

  fAbono numeric;
  fAplicar numeric;
  fInteresPagado numeric;
  amor record;

  stipoprestamoid  char(3);
  scuentaactivo    char(24);
  scuentaintnormal char(24);
  scuentaintmora   char(24);
  scuentaiva       char(24);

  stipoprestamoid2  char(3);
  scuentaactivo2    char(24);
  
  vscuentacaja char(24);
  vsserie_user char(2);
  
  
  lsocioid int4;
  lprestamoid int4;
  lprestamoid2 int4;

--
-- Parametros del usuario
--

  ppolizaid int4;
  pmovipolizaid int4;
  pmovipolizaidcaja int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;

  pmovipolizaid2 int4;
  pmovicajaid int4;

  pfecha date;

  psaldoactual numeric;
begin

  select serie_user,cuentacaja into vsserie_user,vscuentacaja from parametros where usuarioid='restructuras';
  pfecha := pfechaultimopago;

  fAbono := round(pcapitalpagado,2);
  fInteresPagado := 0;
--
-- Actualizar tabla de prestamos, disminuir el saldo del prestamo y
-- actualizar fecha de ultimo pago, importante ya que a partir de ahi calculamos
-- el interes normal
--
  select saldoprestamo
    into psaldoactual
    from prestamos
   where referenciaprestamo = preferenciaprestamo;

  if psaldoactual=fAbono then

    update prestamos
       set saldoprestamo = saldoprestamo - fAbono,
           fechaultimopago = pfechaultimopago,
           claveestadocredito = '002'
     where referenciaprestamo = preferenciaprestamo;
  else
    raise exception 'La cantidad con que se quiere cubrir el prestamo difiere: Saldo= % Abono= %',psaldoactual,fAbono;
  end if;

--
-- Buscamos cuentas contables para el tipo de prestamo anterior
--
  select tipoprestamoid,socioid,prestamoid into stipoprestamoid,lsocioid,lprestamoid
    from prestamos
   where referenciaprestamo=preferenciaprestamo;   
  
  select cuentaactivo,cuentaintnormal,cuentaiva,cuentaintmora
    into scuentaactivo,scuentaintnormal,scuentaiva,scuentaintmora
    from tipoprestamo
   where tipoprestamoid = stipoprestamoid;

  select tipoprestamoid,socioid,prestamoid into stipoprestamoid2,lprestamoid2
    from prestamos
   where referenciaprestamo=psobreprestamo;   
  
  select cuentaactivo into scuentaactivo2
    from tipoprestamo
   where tipoprestamoid = stipoprestamoid2;

--
-- Actualizar tabla de amortizaciones del prestamo anterior
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
-- Dar de alta la poliza contable para el pago del crédito
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'A',vsserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipoliza(preferencia,vsserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfechaultimopago,'D',' ',' ','Sobre-Prestamo',pfechaultimopago);

-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,vscuentacaja,' ','C',pcapitalpagado+pinterespagado+pmoratoriopagado+pivapagado,0,' ',' ','Pago de '||preferenciaprestamo);

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,pcapitalpagado,' ',' ','Capital '||preferenciaprestamo);

   if pinterespagado>0 then
     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaintnormal,' ','A',0,pinterespagado,' ',' ','Interes '||preferenciaprestamo);
   end if;

   if pmoratoriopagado>0 then
     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaintmora,' ','A',0,pmoratoriopagado,' ',' ','Moratorio '||preferenciaprestamo);
   end if;

   if pivapagado>0 then
     select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaiva,' ','A',0,pivapagado,' ',' ','IVA '||preferenciaprestamo);
   end if;


   -- Movimiento de caja

   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = vsserie_user;

  lreferenciacaja := lreferenciacaja+1;   

   select *
     into pmovicajaid
     from spimovicaja(lsocioid,'00',ppolizaid,lreferenciacaja,vsserie_user,pmovipolizaid,lprestamoid,'A',NULL);
	 
	
--
-- Dar de alta la poliza contable para la remesa y cuadrar la caja, dejando el saldo en caja fuerte, que se solventa con el cheque emitido
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'A',vsserie_user,'D');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipoliza(preferencia,vsserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfechaultimopago,'D',' ',' ','Sobre-Prestamo',pfechaultimopago);

-- Detalle de la poliza

   select *
     into pmovipolizaidcaja
     from spimovipoliza(ppolizaid,vscuentacaja,' ','A',0,pcapitalpagado+pinterespagado+pmoratoriopagado+pivapagado,' ',' ','Ret de Rem Sobre-Prestamo');

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,'1101010101',' ','C',pcapitalpagado+pinterespagado+pmoratoriopagado+pivapagado,0,' ',' ','Ret de Rem Sobre-Prestamo');

   
   -- Movimiento de caja

   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = vsserie_user;

  lreferenciacaja := lreferenciacaja+1;   

   select socioid into lsocioid from socio s,sujeto su where s.sujetoid=su.sujetoid and su.paterno='CAJA' and su.materno='CAJA' AND su.nombre='CAJA OPERACION';
   
   select *
     into pmovicajaid
     from spimovicaja(lsocioid,'RE',ppolizaid,lreferenciacaja,vsserie_user,pmovipolizaidcaja,NULL,'A',NULL);

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;