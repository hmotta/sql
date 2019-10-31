CREATE or replace FUNCTION cortelinea(integer,date) RETURNS SETOF integer
AS $_$
declare
  pprestamoid alias for $1;
  pfecha alias for $2;
  
  pfecha_anterior date;
  ncorte_anterior_id integer;
  ndias_corte integer;
  nnumdisp integer;
  xsaldo_insoluto numeric;
  xsaldo_inicial numeric;
  xsaldo_final numeric;
  xsaldo_promedio numeric;
  ndisposiciones integer;
  xmonto_disposiciones numeric;
  xcapital numeric;
  xordinario numeric;
  xmoratorio numeric;
  xpago_minimo numeric;
  xdisposiciones numeric;
  xpagos numeric;
  
  xiva numeric;
  dfecha_limite_pago date;
  ndias_limite integer;
  

  xcapital_pagado_actual numeric;
  xcapital_vencido numeric;
  
  dfecha_adeudo_capital date;
  
  ndias_capital integer;
  ndias_interes integer;
  dultimo_pago_capital date;
  
  sformula text;
  rec record;
  
  begin
	xiva:=0;
	xsaldo_inicial:=0;		
	xmoratorio:=0;
	ndias_capital:=0;
	ndias_interes:=0;
	xcapital_vencido:=0;
	
	delete from corte_linea where lineaid=pprestamoid and fecha_corte=pfecha;
	
	
	--
	-- Verifica si hay un corte anterior o es el primer corte
	--
	select corteid into ncorte_anterior_id from corte_linea where lineaid=pprestamoid and fecha_corte<pfecha order by fecha_corte desc limit 1;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		select fecha_otorga into pfecha_anterior from prestamos where prestamoid=pprestamoid;
		ndias_corte:= pfecha - pfecha_anterior;
	else
		--Ya hay un corte anterior
		select fecha_corte,saldo_final into pfecha_anterior,xsaldo_inicial from corte_linea where corteid=ncorte_anterior_id;
		ndias_corte:= pfecha - pfecha_anterior;
		--fecha de adeudo (desde cuando debe?) si es que debe
		select fecha_limite into dfecha_adeudo_capital from corte_linea where lineaid=pprestamoid and (capital-capital_pagado)>0 order by fecha_corte limit 1;
	end if;
	
	
	--La Distribuir capital pagado Se tendria que hacer en caja al momento del pago, ya que va a ser un calculo al vuelo.
	
	
	--
	--	Cálculo el saldo promedio diario (ya no se usa)
	--
	--(+Disposiciones)
	select sum(debe) into xdisposiciones from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov in (1,2);
	xdisposiciones:=coalesce(xdisposiciones,0);
	--(-Pagos)
	select sum(haber) into xpagos from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov=3;
	xpagos:=coalesce(xpagos,0);
	xsaldo_final := xsaldo_inicial + xdisposiciones - xpagos;
	
	
	
	--
	-- Capital Minimo (saldoinsoluto x el 5%) 
	--
	select count(*) into nnumdisp from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov in (1);
	select spssaldoadeudolineafecha into xsaldo_insoluto from spssaldoadeudolineafecha(pprestamoid,pfecha);
	raise notice 'xsaldo_insoluto=%',xsaldo_insoluto;
	
	
	update calculo set saldoinsoluto=xsaldo_insoluto where calculoid=6;
	SELECT formula into sformula from calculo where calculoid=6;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||6
	loop
	  xcapital := rec.monto;
	end loop;

	
	--
	-- Capital Vencido
	--
	--Si tiene un capital pendiente de pago se le suma al pago minimo
	select sum(capital-capital_pagado) into xcapital_vencido from corte_linea where lineaid=pprestamoid and (capital-capital_pagado)>0 and fecha_limite<=pfecha;
	xcapital_vencido:=coalesce(xcapital_vencido,0);
	
	-- 
	-- Interes ordinarios 
	--
	xordinario:=calcula_int_ord_linea(pprestamoid,pfecha);
	xiva:=round(xordinario*0.16,2);
	-- 
	-- Interes Moratorios
	--
	select calcula_int_mor_linea into xmoratorio from calcula_int_mor_linea(pprestamoid,pfecha);
	xmoratorio:=coalesce(xmoratorio,0);
	xiva:=xiva+round(xmoratorio*0.16,2);
	
	xpago_minimo := xcapital  + xcapital_vencido + xordinario + xmoratorio + xiva;
	
	---
	--- Otros
	---
	select dia_mes_cobro into ndias_limite from prestamos where prestamoid=pprestamoid;
	dfecha_limite_pago:=pfecha+ndias_limite;
	select max(po.fechapoliza) into dultimo_pago_capital from polizas po,movipolizas mp,prestamos p,cat_cuentas_tipoprestamo ct  where po.polizaid=mp.polizaid and mp.prestamoid=p.prestamoid and (ct.tipoprestamoid = p.tipoprestamoid and ct.clavefinalidad = p.clavefinalidad and ct.renovado = p.renovado) and mp.haber>0 and p.prestamoid=pprestamoid and (mp.cuentaid = ct.cta_cap_vig) and po.fechapoliza<=pfecha;
	
	select dias_mora_linea into ndias_capital from dias_mora_linea(pprestamoid,pfecha);
	ndias_capital:=coalesce(ndias_capital,0);
	
	--Saco los dias de interes que debe
	if xordinario>0 then
		ndias_interes:=dias_interes_linea(pprestamoid,pfecha);
		ndias_interes:=coalesce(ndias_interes,0);
	end if;
	
	insert into corte_linea (lineaid,fecha_corte,dias_desde_corte_ant,saldo_inicial,num_disposiciones,monto_diposiciones,pagos,saldo_final,capital,capital_vencido,int_ordinario,int_moratorio,iva,comisiones,pago_minimo,fecha_limite,dias_capital,dias_interes,fecha_pago_capital,capital_pagado,estatus) values (pprestamoid,pfecha,ndias_corte,xsaldo_inicial,nnumdisp,xdisposiciones,xpagos,xsaldo_final,xcapital,xcapital_vencido,xordinario,xmoratorio,xiva,0,xpago_minimo,dfecha_limite_pago,ndias_capital,ndias_interes,null,0,1);
	
	perform verifica_bloqueo_linea(pprestamoid);
  return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

