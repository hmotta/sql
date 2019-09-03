CREATE or replace FUNCTION dias_interes_linea(integer,date) RETURNS integer
    AS $_$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
	ndias_interes integer;
	dfecha_inicial date;	
	dfecha_final date;	
begin
	
	perform genera_interes_diario_linea(pprestamoid,pfecha);
	
	select min(fecha) into dfecha_inicial from credito_linea_interes_devengado 
	where (interes_diario-interes_pagado)>0 and fecha<=pfecha;
	
	select max(fecha) into dfecha_final from credito_linea_interes_devengado 
	where (interes_diario-interes_pagado)>0 and fecha<=pfecha;
	
	raise notice 'fecha inicial:=%',dfecha_inicial;
	raise notice 'fecha final:=%',dfecha_final;
	
	dfecha_final:=coalesce(dfecha_final,pfecha);
	dfecha_inicial:=coalesce(dfecha_inicial,pfecha);
	
	raise notice 'fecha inicial:=%',dfecha_inicial;
	raise notice 'fecha final:=%',dfecha_final;
	
	ndias_interes:=dfecha_final-dfecha_inicial;
	
	if ndias_interes<0 then
		ndias_interes:=0;
	end if;
	return ndias_interes;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;