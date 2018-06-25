CREATE OR REPLACE FUNCTION spabonoprestamo_linea(integer, numeric) RETURNS integer
    AS $_$
declare
	pprestamoid alias for $1;
	pabono alias for $2;

	fAbono numeric;
	fAplicar numeric;
	corte record;

	lsaldoprestamo numeric;

	finteres numeric;
	fintpag numeric;
  
begin

	fAbono := round(pabono,2);
	--raise notice ' Estoy en La funcion spabonoprestamo!!! ';
	--
	-- Actualizar tabla de prestamos, disminuir el saldo del prestamo y
	-- actualizar fecha de ultimo pago, importante ya que a partir de ahi calculamos
	-- el interes normal
	--

	--update prestamos 	set saldoprestamo = saldoprestamo - fAbono, fechaultimopago = now()	where prestamoid=pprestamoid;

	select saldoprestamo into lsaldoprestamo from prestamos where prestamoid=pprestamoid;

	if lsaldoprestamo<0 then
		raise exception 'El abono es mayor al saldo del prestamo';
	end if;

	--if lsaldoprestamo=0 then
	-- Cambiar estatus a pagado
	--update prestamos
	--set claveestadocredito='002'
	--where prestamoid=pprestamoid;
	--end if;


	--
	-- Actualizar tabla de cortes
	--
	if fAbono>0 then
		for corte in
			select *
			from corte_linea
			where lineaid=pprestamoid and capital-capital_pagado>0
			order by fecha_limite
		loop
			fAplicar := corte.capital - corte.capital_pagado;
			if fAbono>=fAplicar then
				update corte_linea set capital_pagado = capital, fecha_pago_capital = now() where corteid=corte.corteid;
				fAbono := fAbono - fAplicar;
			else
				if fAbono>0 then
					update corte_linea set capital_pagado = capital_pagado+fAbono,fecha_pago_capital = now() where corteid=corte.corteid;
					fAbono := 0;
				end if;
			end if;
		end loop;
	end if;


	return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;