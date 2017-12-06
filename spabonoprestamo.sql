CREATE OR REPLACE FUNCTION spabonoprestamo(integer, numeric) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  pabono alias for $2;

  fAbono numeric;
  fAplicar numeric;
  amor record;

  lsaldoprestamo numeric;

  finteres numeric;
  fintpag numeric;
  
begin

  fAbono := round(pabono,2);
  raise notice ' Estoy en La funcion spabonoprestamo!!! ';
--
-- Actualizar tabla de prestamos, disminuir el saldo del prestamo y
-- actualizar fecha de ultimo pago, importante ya que a partir de ahi calculamos
-- el interes normal
--

  update prestamos
     set saldoprestamo = saldoprestamo - fAbono,
         fechaultimopago = now()
   where prestamoid=pprestamoid;

  select saldoprestamo into lsaldoprestamo
   from prestamos where prestamoid=pprestamoid;

  if lsaldoprestamo<0 then
     raise exception 'El abono es mayor al saldo del prestamo';
  end if;

  if lsaldoprestamo=0 then
    -- Cambiar estatus a pagado
    update prestamos
     set claveestadocredito='002'
   where prestamoid=pprestamoid;
  end if;


--
-- Actualizar tabla de amortizaciones
--
  if fAbono>0 then
    for amor in
        select *
          from amortizaciones
         where prestamoid=pprestamoid and importeamortizacion-abonopagado>0
      order by fechadepago
    loop

      fAplicar := amor.importeamortizacion - amor.abonopagado;

      if fAbono>=fAplicar then
        update amortizaciones
           set abonopagado = importeamortizacion,
               ultimoabono = now()
         where amortizacionid=amor.amortizacionid;
         fAbono := fAbono - fAplicar;
      else
        if fAbono>0 then
          update amortizaciones
             set abonopagado = abonopagado+fAbono,
                 ultimoabono = now()
           where amortizacionid=amor.amortizacionid;
           fAbono := 0;
        end if;
      end if;
    end loop;
  end if;


return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;