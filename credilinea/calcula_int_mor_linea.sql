CREATE or replace FUNCTION calcula_int_mor_linea(integer,date) RETURNS numeric
    AS $_$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
    
	dfecha_otorga date;
	dultimo_pago_capital date;
	xtasa_moratoria numeric;
	xint_mora numeric;
	ndias_capital integer;
	corte record;
	rec record;
	sformula text;
begin
	xint_mora:=0;
	--se obtiene la tsa moratoria
	select tasa_moratoria into xtasa_moratoria from prestamos where prestamoid=pprestamoid;
	
	--Se obtiene la fecha de ultimo pago a capital
	select max(po.fechapoliza) into dultimo_pago_capital from polizas po,movipolizas mp,prestamos p,cat_cuentas_tipoprestamo ct  where po.polizaid=mp.polizaid and (ct.tipoprestamoid = trim(p.tipoprestamoid) and ct.clavefinalidad = p.clavefinalidad and ct.renovado = p.renovado) and mp.prestamoid=p.prestamoid and p.tipoprestamoid=tp.tipoprestamoid and mp.haber>0 and p.prestamoid=pprestamoid and (mp.cuentaid = tp.cuentaactivo) and po.fechapoliza<=pfecha;
	raise notice 'dultimo_pago_capital=%',dultimo_pago_capital;
	
	--Por cada corte vencido se obtiene el monto correspondiente de moratorio	
	for corte in
		select * from corte_linea where lineaid=pprestamoid and fecha_limite<pfecha and (capital-capital_pagado)>0
	loop
		if dultimo_pago_capital>corte.fecha_limite then
			ndias_capital := pfecha - dultimo_pago_capital;
		else
			ndias_capital := pfecha - corte.fecha_limite;
		end if;

		if ndias_capital<0 then
			ndias_capital := 0;
		end if;
		raise notice 'ndias_capital=% ',ndias_capital;
		update calculo set amortizacion = corte.capital-corte.capital_pagado,dias = ndias_capital,tasaintmoratorio = xtasa_moratoria where calculoid=2;

		SELECT formula into sformula from calculo where calculoid=2;

		for rec in execute
			'SELECT ' || sformula || ' as interes FROM calculo where calculoid='||2
		loop
			xint_mora := xint_mora + round(rec.interes,2);
		end loop;
	end loop;
 
	xint_mora:=coalesce(xint_mora,0);
	return xint_mora;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;