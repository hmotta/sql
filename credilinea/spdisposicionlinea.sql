CREATE OR REPLACE FUNCTION spdisposicionlinea(integer, numeric) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  pmontodispuesto alias for $2;

  xsaldo_disponible numeric;
  xsaldo_adeudo numeric;
  
begin
	select spssaldoadeudolinea into xsaldo_adeudo from spssaldoadeudolinea(pprestamoid);
	select spssaldodisplinea into xsaldo_disponible from spssaldodisplinea(pprestamoid);

  --if xsaldo_disponible<pmontodispuesto then
    -- raise exception 'La disposicion es mayor al saldo disponible de la linea';
  --end if;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;