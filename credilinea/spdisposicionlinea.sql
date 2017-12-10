CREATE OR REPLACE FUNCTION spdisposicionlinea(integer, numeric) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  pmontodispuesto alias for $2;

  fmontodispuesto numeric;
  fAplicar numeric;
  amor record;

  lsaldoprestamo numeric;

  finteres numeric;
  fintpag numeric;
  
begin

  fmontodispuesto := round(pmontodispuesto,2);
  raise notice ' Estoy en La funcion spmontodispuestoprestamo!!! ';
--
-- Actualizar tabla de prestamos, disminuir el saldo del prestamo y
-- actualizar fecha de ultimo pago, importante ya que a partir de ahi calculamos
-- el interes normal
--

  update prestamos
     set saldoprestamo = saldoprestamo - fmontodispuesto,
         fechaultimopago = now()
   where prestamoid=pprestamoid;

  select saldoprestamo into lsaldoprestamo
   from prestamos where prestamoid=pprestamoid;

  if lsaldoprestamo<0 then
     raise exception 'La disposicion es mayor al saldo de la linea';
  end if;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;