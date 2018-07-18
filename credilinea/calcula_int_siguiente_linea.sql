--Calcula el interes del nuevo periodo, es decir del periodo actual (presente) de la linea, sólo del 1 al día 10 (dia de limite de pago)
CREATE or replace FUNCTION calcula_int_siguiente_linea(integer,date) RETURNS numeric
AS $_$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
	xinteres numeric;
	dfecha_limite date;
	dfecha_corte date;
	ncorte_anterior_id integer;
begin
	select corteid into ncorte_anterior_id from corte_linea where lineaid=pprestamoid and fecha_corte<pfecha order by fecha_corte desc limit 1;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		xinteres:=0;
	else
		--Ya hay un corte anterior
		select fecha_corte,fecha_limite into dfecha_corte,dfecha_limite from corte_linea where corteid=ncorte_anterior_id;
	end if;
	
	raise notice 'dfecha_corte=%',dfecha_corte;
	raise notice 'dfecha_limite=%',dfecha_limite;
	--Sí y Solo si, estamos en el rango de los primeros dias del mes y No ha cobierto el total de su pago minimo
	if (pfecha>=dfecha_corte and pfecha<=dfecha_limite) and (capital_minimo_pendiente_linea(pprestamoid,pfecha)>0) then
			select sum(interes_diario-interes_pagado) into xinteres from  credito_linea_interes_devengado where
			(interes_diario-interes_pagado)>0 and fecha between dfecha_corte+1 and dfecha_limite;
			xinteres:=coalesce(xinteres,0);
	else
		xinteres:=0;
	end if;

	return xinteres;
end
$_$
LANGUAGE plpgsql SECURITY DEFINER;