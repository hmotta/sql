CREATE or replace FUNCTION calcula_int_ord_linea(integer,date) RETURNS numeric
AS $_$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
	xinteres_acumulado numeric;
begin
	perform genera_interes_diario_linea(pprestamoid,pfecha);
	xinteres_acumulado:=0;
	select sum(interes_diario-interes_pagado) into xinteres_acumulado from  credito_linea_interes_devengado where
    (interes_diario-interes_pagado)>0 and fecha<=pfecha and lineaid=pprestamoid;	
	xinteres_acumulado:=coalesce(xinteres_acumulado,0);
	return xinteres_acumulado;
end
$_$
LANGUAGE plpgsql SECURITY DEFINER;