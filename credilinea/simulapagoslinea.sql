drop type pagoslinea cascade;
create type pagoslinea as (
	num_pago integer,
	fecha_pago date,
	total_pago numeric
	
);
CREATE or replace FUNCTION simulapagoslinea(integer) RETURNS SETOF pagoslinea
    AS $_$
declare
  r pagoslinea%rowtype;
  pprestamoid alias for $1;
  dfecha_pago date;
  xtotal_pago numeric;
  nnum integer;

begin
	nnum := 1;
	select fecha_1er_pago into dfecha_pago from prestamos where prestamoid=pprestamoid;
	select total into xtotal_pago from spspagomaximolinea(pprestamoid);
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