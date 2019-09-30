

CREATE OR REPLACE FUNCTION spssumapagos(integer,date,date) RETURNS numeric
AS $_$
declare
	r record;
	lprestamoid alias for $1;
	pfechai alias for $2;
	pfechaf alias for $3;
	xSuma numeric;
begin
	select sum(m.haber) into xSuma from prestamos p, cat_cuentas_tipoprestamo ct, movicaja mc, polizas l, movipolizas m
 where p.prestamoid = lprestamoid and l.fechapoliza between pfechai and pfechaf and 
       (ct.cat_cuentasid = p.cat_cuentasid) and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.polizaid=l.polizaid  and
       (m.cuentaid = ct.cta_cap_vig);
	
	xSuma := coalesce(xSuma,0);
return xSuma;
end
$_$
    LANGUAGE plpgsql;

