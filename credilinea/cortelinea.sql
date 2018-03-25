CREATE or replace FUNCTION cortelinea(integer,date) RETURNS SETOF integer
AS $_$
declare
  pprestamoid alias for $1;
  pfecha alias for $2;
  
  pfecha_anterior date;
  ncorteid integer;
  ndias integer;
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
  xtasa_normal numeric;
  xtasa_moratoria numeric;
  xiva numeric;
  dfecha_limte_pago date;
  
  xcapital_adeudado_anterior numeric;
  xcapital_pagado_actual numeric;
  xcapital_vencido numeric;
  
  xint_ord_dev_balance numeric;
  xint_ord_dev_cuent_orden numeric;
  xint_mor_dev_balance numeric;
  xint_mor_dev_cuent_orden numeric;
  
  ndiastraspasovencida integer;
  
  dfecha_adeudo date;
  ndias_capital integer;
  sformula text;
  rec record;
  
  begin
	xiva:=0;
	select diastraspasoavencida into ndiastraspasovencida from prestamos inner join tiporestamo on (prestamos.tipoprestamoid=tiporestamo.tipoprestamoid) where prestamoid=pprestamoid;
	
	--
	-- Verifica si hay un corte anterior o es el primer corte
	--
	select corteid into ncorteid from corte_linea where lineaid=pprestamoid and fecha_corte<pfecha;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		select fecha_otorga into pfecha_anterior from prestamos where prestamoid=pprestamoid;
		ndias:= pfecha - pfecha_anterior;
		xsaldo_inicial:=0;		
		xcapital_adeudado_anterior:=0;
	else
		--Ya hay un corte anterior
		select fecha_corte,saldo_final,(capital+capital_vencido) into pfecha_anterior,xsaldo_inicial,xcapital_adeudado_anterior from corte_linea where corteid=ncorteid;
		ndias:= pfecha - pfecha_anterior;
		
	end if;
	
	--
	--	Se verifica si hay un pago pendiente de capital
	--

	--monto de capital pagado en el periodo
	select sum(haber) into xcapital_pagado_actual from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov=3;
	--Cálculo el capital pendiente
	xcapital_vencido:=xcapital_adeudado_anterior-xcapital_pagado_actual;
	if xcapital_vencido>0 then --tiene un saldo de capital que no cubrió
		--fecha de adeudo (dese cuando debe?)
		select fecha_limite into dfecha_adeudo from corte_linea where lineaid=pprestamoid and estatus=1 order by fecha_corte;
		ndias_capital:=dfecha_adeudo-pfecha; -- se calculan los dias de adeudo de capital
		--Calculo el interes moratorio a pagar al corte
		update calculo set amortizacion=xcapital_vencido,dias=ndias_capital,tasaintnormal=xtasa_moratoria where calculoid=2;
		SELECT formula into sformula from calculo where calculoid=2;
		for rec in execute
		  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||2
		loop
		  xmoratorio := rec.monto;
		end loop;
		xiva:=xmoratorio*0.16;
	end if;
	
	
	--
	--	Cálculo el saldo promedio diario
	--
	--(+Disposiciones)
	select sum(debe) into xdisposiciones from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov in (1,2);
	xdisposiciones:=coalesce(xdisposiciones,0);
	--(-Pagos)
	select sum(haber) into xpagos from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov=7;
	xpagos:=coalesce(xpagos,0);
	xsaldo_final := xsaldo_inicial + xdisposiciones - xpagos;
	--(saldo promedio)
	select sum(saldo_final) into xsaldo_promedio from saldolineadias(pprestamoid,pfecha_anterior,pfecha);
	xsaldo_promedio:=coalesce(xsaldo_promedio,0);
	xsaldo_promedio:=xsaldo_promedio/ndias;
	
	
	--
	-- Cálculo del capital a pagar (saldoinsoluto x el 5%) + el capital pendiente de pago (si lo hay)
	--
	select count(*) into nnumdisp from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov in (1);
	select spssaldoadeudolinea into xsaldo_insoluto from spssaldoadeudolinea(pprestamoid);
	select tasanormal,tasa_moratoria into xtasa_normal,xtasa_moratoria from prestamos where prestamoid=pprestamoid;
	
	update calculo set saldoinsoluto=xsaldo_insoluto where calculoid=6;
	SELECT formula into sformula from calculo where calculoid=6;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||6
	loop
	  xcapital := rec.monto;
	end loop;
	xcapital:=xcapital;
	
	
	--
	-- Cálculo del interes ordinario en base al saldo promedio diario
	--
	update calculo set saldopromdiario=xsaldo_promedio,dias=ndias,tasaintnormal=xtasa_normal where calculoid=7;
	SELECT formula into sformula from calculo where calculoid=7;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||7
	loop
	  xordinario := rec.monto;
	end loop;
	xiva:=xiva+(xordinario*0.16);
	--Fecha de ultimo pago a interes
	
	--Interes ord dev no cob balance
	update calculo set saldopromdiario=xsaldo_promedio,dias=ndias,tasaintnormal=xtasa_normal where calculoid=7;
	SELECT formula into sformula from calculo where calculoid=7;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||7
	loop
	  xordinario := rec.monto;
	end loop;
	--Interes orde dev no cob balance ctas orden
	update calculo set saldopromdiario=xsaldo_promedio,dias=ndias,tasaintnormal=xtasa_normal where calculoid=7;
	SELECT formula into sformula from calculo where calculoid=7;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||7
	loop
	  xordinario := rec.monto;
	end loop;
	
	
	--
	-- Cálculo del pago mínimo
	--
	update calculo set saldoinsoluto=xsaldo_insoluto,saldopromdiario=xsaldo_promedio,dias=ndias,tasaintnormal=xtasa_normal where calculoid=8;
	SELECT formula into sformula from calculo where calculoid=8;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||8
	loop
	  xpago_minimo := rec.monto;
	end loop;
	xpago_minimo := xpago_minimo + xiva;
	
	---
	--- Otros
	---
	select dia_mes_cobro into ndias from prestamos where prestamoid=pprestamoid;
	dfecha_limte_pago:=pfecha+ndias;
	insert into corte_linea (lineaid,fecha_corte,dias,saldo_inicial,saldo_final,saldo_promedio,num_disposiciones,monto_diposiciones,capital,int_ordinario,int_moratorio,iva,comisiones,pago_minimo,fecha_limite,dias_capital,dias_interes,fecha_pago_interes,fecha_pago_capital,capital_pagado,capital_vencido,int_ord_dev_balance,int_ord_dev_cuent_orden,int_mor_dev_balance,int_mor_dev_cuent_orden,estatus) values (pprestamoid,pfecha,ndias,xsaldo_inicial,xsaldo_final,xsaldo_promedio,nnumdisp,xdisposiciones,xcapital,xordinario,xmoratorio,xiva,0,xpago_minimo,dfecha_limte_pago,ndias_capital,ndias_capital,null,null,xcapital_pagado_actual,xcapital_vencido,xint_ord_dev_balance,xint_ord_dev_cuent_orden,xint_mor_dev_balance,xint_mor_dev_cuent_orden,1);
  return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

