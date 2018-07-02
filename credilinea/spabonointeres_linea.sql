CREATE OR REPLACE FUNCTION spabonointeres_linea(integer, numeric) RETURNS integer
    AS $_$
declare
	pprestamoid alias for $1;
	pabono alias for $2;

	fAbono numeric;
	fAplicar numeric;
	r record;

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

	--select saldoprestamo into lsaldoprestamo from prestamos where prestamoid=pprestamoid;

	--if lsaldoprestamo<0 then
		--raise exception 'El abono es mayor al saldo del prestamo';
	--end if;

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
		for r in
			select *
			from credito_linea_interes_devengado
			where lineaid=pprestamoid and intere_diario-interes_pagado>0
			order by fecha
		loop
			fAplicar := r.interes_diario - r.interes_pagado;
			if fAbono>=fAplicar then
				update credito_linea_interes_devengado set interes_pagado = interes_diario, fecha_pago = now() where devengamientoid=r.devengamientoid;
				fAbono := fAbono - fAplicar;
			else
				if fAbono>0 then
					update credito_linea_interes_devengado set interes_pagado = interes_pagado+fAbono,fecha_pago = now() where devengamientoid=r.devengamientoid;
					fAbono := 0;
				end if;
			end if;
		end loop;
	end if;


	return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;