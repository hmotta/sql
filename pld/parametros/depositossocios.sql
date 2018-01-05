
--funcion para reportear 
CREATE OR REPLACE FUNCTION spsdepositossocio(integer,integer,integer,date,date) RETURNS numeric
AS $_$
declare
	r record;
	tipodep1 alias for $1;
	tipodep2 alias for $2;
	dsocioid alias for $3;
  	pfechai alias for $4;
	pfechaf alias for $5;
	xSuma numeric;
begin
	select sum(debe) into xSuma from movicaja mc, movipolizas mp, polizas p where mc.tipomovimientoid not in ('WU','RG','CH','RE','AG','LE','BU','SM','SI','SQ','SB','ST','TC','MV','IU','OP','MC','CM','SK','CF','TU','ET','ID','00') and mp.movipolizaid=mc.movipolizaid and p.polizaid=mc.polizaid and p.fechapoliza between pfechai and pfechaf and p.seriepoliza not in ('ZA','WW','Z') and mc.efectivo>=tipodep1 and mc.efectivo<=tipodep2 and mc.socioid=dsocioid  group by socioid;
	
	xSuma := coalesce(xSuma,0);
return xSuma;
end
$_$
    LANGUAGE plpgsql;


