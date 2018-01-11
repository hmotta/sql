CREATE OR REPLACE FUNCTION spsdepositossociomonto(integer,numeric,date,date) RETURNS numeric
AS $_$
declare
	dsocioid alias for $1;
	xmonto_dolares alias for $1;
  	pfechai alias for $3;
	pfechaf alias for $4;
	xSuma numeric;
	xdolar_valor numeric;
	r record;
begin
	xSuma:=0;
	select spsdolarvalor into xdolar_valor from spsdolarvalor(pfechai);
	for r in 
		select debe as monto_operacion from movicaja mc, movipolizas mp, polizas p where mc.tipomovimientoid not in ('WU','RG','CH','RE','AG','LE','BU','SM','SI','SQ','SB','ST','TC','MV','IU','OP','MC','CM','SK','CF','TU','ET','ID','00') and mp.movipolizaid=mc.movipolizaid and p.polizaid=mc.polizaid and p.fechapoliza between pfechai and pfechaf and p.seriepoliza not in ('ZA','WW','Z') and mc.efectivo>=1 and mc.socioid=dsocioid and debe>=xdolar_valor;
	loop 
		if r.monto_operacion >= (xmonto_dolares*xdolar_valor) then
			xSuma := xSuma + coalesce(r.monto_operacion,0);
		end if;
	end loop;
return xSuma;
end
$_$
    LANGUAGE plpgsql;


