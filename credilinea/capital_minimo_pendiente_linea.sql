CREATE or replace FUNCTION capital_minimo_pendiente_linea(integer,date) RETURNS numeric
    AS $_$
declare
  pprestamoid alias for $1;
  pfecha alias for $2;
  r tcalculopago%rowtype;
  
  xcapital_pendiente numeric;
  ncorte_anterior_id integer;
begin
	
	--
	-- Verifica si hay un corte anterior 
	--
	select corteid into ncorte_anterior_id from corte_linea where lineaid=pprestamoid and fecha_corte<=pfecha order by fecha_corte desc limit 1;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		return  0;
	else
		--Ya hay cortes
		--se verifican los cortes con la fecha de corte, ya que el pago minimo exigible es desde el dia 1 de mes siguiente
		select sum(capital-capital_pagado) into xcapital_pendiente from corte_linea where lineaid=pprestamoid and fecha_corte<=pfecha and (capital-capital_pagado)>0;
	end if;
	xcapital_pendiente:=coalesce(xcapital_pendiente,0);
	
	return xcapital_pendiente;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
