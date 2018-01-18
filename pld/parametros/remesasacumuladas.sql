
--funcion para reportear 
CREATE OR REPLACE FUNCTION remesasacumuladas(integer,date,date,integer) RETURNS numeric
AS $_$
declare
	r record;
	psocioid alias for $1;
	pfechai alias for $2;
	pfechaf alias for $3;
	lmodo alias for $4;
	xSuma numeric;
begin
	if 	lmodo=1 then --Envios
			select sum(m.debe) into xSuma from movicaja mc, polizas l, movipolizas m
			 where l.fechapoliza between pfechai and pfechaf and mc.socioid=psocioid and 
				   m.polizaid = mc.polizaid and
				   m.polizaid=l.polizaid  and
				   mc.tipomovimientoid='EN';
		
	
	else --Pagos

			select sum(m.haber) into xSuma from movicaja mc, polizas l, movipolizas m
			 where l.fechapoliza between pfechai and pfechaf and mc.socioid=psocioid and
				   m.polizaid = mc.polizaid and
				   m.polizaid=l.polizaid  and
				   mc.tipomovimientoid in ('EI','RN','RG','WU');

	end if;

	
	xSuma := coalesce(xSuma,0);
return xSuma;
end
$_$
    LANGUAGE plpgsql;


