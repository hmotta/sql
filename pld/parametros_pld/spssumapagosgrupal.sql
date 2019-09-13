-- ----------------------------
-- Function structure for spssumapagosgrupal
-- ----------------------------
DROP FUNCTION IF EXISTS spssumapagosgrupal(date, date, bpchar);
CREATE OR REPLACE FUNCTION spssumapagosgrupal(date, date, bpchar)
  RETURNS pg_catalog.numeric AS $BODY$
declare
	r record;
	pfechai alias for $1;
	pfechaf alias for $2;
        pgrupo  alias for $3;
	xSuma numeric;
begin
	select sum(m.haber) into xSuma from prestamos p, cat_cuentas_tipoprestamo ct, movicaja mc, polizas l, movipolizas m, solicitudprestamo sp
 where p.solicitudprestamoid = sp.solicitudprestamoid and l.fechapoliza between pfechai and pfechaf and 
	  (ct.cat_cuentasid = p.cat_cuentasid) and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.polizaid=l.polizaid  and
       sp.grupo=pgrupo and 
       m.cuentaid in (ct.cuentaactivo,ct.cuentaactivoren,ct.cuentaintnormal,ct.cuentaintnormalren,ct.cuentaintmora,ct.cuentaintmoraren,ct.cuentaiva);
	
	xSuma := coalesce(xSuma,0);
return xSuma;
end
$BODY$
  LANGUAGE plpgsql VOLATILE;