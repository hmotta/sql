CREATE OR REPLACE FUNCTION movprestamo(bpchar, bpchar, date, numeric, numeric, numeric, numeric, bpchar, bpchar)
  RETURNS pg_catalog.int4 AS $BODY$
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
    from cat_cuentas_tipoprestamo ct, prestamos p
   where ct.cat_cuentasid=p.cat_cuentasid and p.prestamoid=lprestamoid;

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
$BODY$
  LANGUAGE plpgsql VOLATILE;