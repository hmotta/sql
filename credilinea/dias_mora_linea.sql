CREATE or replace FUNCTION dias_mora_linea(integer,date) RETURNS numeric
    AS $_$
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
	select max(po.fechapoliza) into dultimo_pago_capital from polizas po,movipolizas mp,prestamos p,tipoprestamo tp  where po.polizaid=mp.polizaid and mp.prestamoid=p.prestamoid and p.tipoprestamoid=tp.tipoprestamoid and mp.haber>0 and p.prestamoid=pprestamoid and (mp.cuentaid = tp.cuentaactivo or mp.cuentaid = tp.cuentaactivoren) and po.fechapoliza<=pfecha;
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
$_$
    LANGUAGE plpgsql SECURITY DEFINER;