drop type pagoslinea cascade;
create type pagoslinea as (
	num_pago integer,
	fecha_pago date,
	total_pago numeric
	
);

--Se utilizar para el analisis de crédito, simula un pago maximo que tendria la linea
CREATE or replace FUNCTION simulapagosdisposicion(integer,numeric) RETURNS SETOF pagoslinea
    AS $_$
declare
  r pagoslinea%rowtype;
  pprestamoid alias for $1;
  pmonto_dispuesto alias for $2;
  dfecha_pago date;
  xtotal_pago numeric;
  nnum integer;
  ncorte_anterior_id integer;
begin
	nnum := 1;
	
	--
	-- Verifica si hay un corte anterior o es el primer corte
	--
	select corteid into ncorte_anterior_id from corte_linea where lineaid=pprestamoid and fecha_corte<=current_date order by fecha_corte desc limit 1;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		select fecha_1er_pago into dfecha_pago from prestamos where prestamoid=pprestamoid;
	else
		--Ya hay un corte anterior
		select fecha_limite into dfecha_pago from corte_linea where corteid=ncorte_anterior_id;
	end if;
	
	--select dfecha_pago + interval '1 month'into dfecha_pago;
	
	select total into xtotal_pago from spspagomaximodisposicion(pprestamoid,pmonto_dispuesto);
	for i in 1..20 loop
		r.num_pago:=nnum;
		r.fecha_pago:=dfecha_pago;
		r.total_pago:=xtotal_pago;
		return next r;
		nnum:=nnum+1;
		--dfecha_pago:=dfecha_pago+30;
		select dfecha_pago + interval '1 month'into dfecha_pago;
	end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;