-- ----------------------------
-- Function structure for dias_mora_linea
-- ----------------------------
DROP FUNCTION IF EXISTS dias_mora_linea(int4, date);
CREATE OR REPLACE FUNCTION dias_mora_linea(int4, date)
  RETURNS pg_catalog.numeric AS $BODY$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
    
	dfecha_otorga date;
	dultimo_pago_capital date;
	dfecha_primer_adeudo date;
	ndias_capital integer;
begin
	ndias_capital:=0;
	--Se obtiene la fecha de ultimo pago a capital
	select max(po.fechapoliza) into dultimo_pago_capital from polizas po,movipolizas mp,prestamos p,cat_cuentas_tipoprestamo ct  where po.polizaid=mp.polizaid and mp.prestamoid=p.prestamoid and (ct.tipoprestamoid = p.tipoprestamoid and ct.clavefinalidad = p.clavefinalidad and ct.renovado = p.renovado) and mp.haber>0 and p.prestamoid=pprestamoid and (mp.cuentaid = ct.cuentaactivo) and po.fechapoliza<=pfecha;
	raise notice 'dultimo_pago_capital=%',dultimo_pago_capital;
	
	select fecha_limite into dfecha_primer_adeudo from corte_linea where lineaid=pprestamoid and fecha_limite<pfecha and (capital-capital_pagado)>0 order by fecha_limite limit 1;
	
	if dultimo_pago_capital>dfecha_primer_adeudo then
		ndias_capital := pfecha - dultimo_pago_capital;
	else
		ndias_capital := pfecha - dfecha_primer_adeudo;
	end if;

	if ndias_capital<0 then
		ndias_capital := 0;
	end if;
	ndias_capital:=coalesce(ndias_capital,0);
	
	return ndias_capital;

end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;