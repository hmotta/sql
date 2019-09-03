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
  xtasa_normal numeric;
  xtasa_moratoria numeric;
  xiva numeric;
  dfecha_limte_pago date;
  ndias_limite integer;
  
  xcapital_adeudado_anterior numeric;
  xcapital_pagado_actual numeric;
  xcapital_vencido numeric;
  
  xinteres_adeudado_anterior numeric;
  xinteres_pagado_actual numeric;
  xinteres_vencido numeric;
  
  xint_ord_dev_balance numeric;
  xint_ord_dev_cuent_orden numeric;
  xint_mor_dev_balance numeric;
  xint_mor_dev_cuent_orden numeric;
  
  ndiastraspasovencida integer;
  
  dfecha_adeudo date;
  ndias_capital integer;
  ndias_interes integer;
  
  xmonto_distribuir numeric;
  ncorte_id_distribuir integer;
  xmonto_pendiente numeric;
  ndias_calculo integer;
  sformula text;
  rec record;
  
  begin
	xiva:=0;
	xsaldo_inicial:=0;		
	xcapital_adeudado_anterior:=0;
	xmoratorio:=0;
	ndias_capital:=0;
	ndias_interes:=0;
	xinteres_pagado_actual:=0;
	xinteres_vencido:=0;
	xinteres_adeudado_anterior:=0;
	xint_ord_dev_balance:=0;
	xint_ord_dev_cuent_orden:=0;
	xint_mor_dev_balance:=0;
	xint_mor_dev_cuent_orden:=0;
	
	delete from corte_linea where lineaid=pprestamoid and fecha_corte=pfecha;
	select diastraspasoavencida into ndiastraspasovencida from prestamos inner join tipoprestamo on (prestamos.tipoprestamoid=tipoprestamo.tipoprestamoid) where prestamoid=pprestamoid;
	
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
		select fecha_corte,saldo_final,(capital+coalesce(capital_vencido,0)),(int_ordinario+coalesce(interes_vencido,0)) into pfecha_anterior,xsaldo_inicial,xcapital_adeudado_anterior,xinteres_adeudado_anterior from corte_linea where corteid=ncorte_anterior_id;
		ndias_corte:= pfecha - pfecha_anterior;
		
	end if;
	ncorte_anterior_id:=coalesce(ncorte_anterior_id,0);
	--
	--	Se verifica si hay un pago pendiente de capital
	--

	--monto de capital pagado en el periodo
	select coalesce(sum(haber),0) into xcapital_pagado_actual from movslinead(pprestamoid,pfecha_anterior,pfecha,1) where tipomov=3;
	raise notice 'xcapital_pagado_actual=%',xcapital_pagado_actual;
	raise notice 'xcapital_adeudado_anterior=%',xcapital_adeudado_anterior;
	--Distribuir capital pagado si lo hubo --lo puedo hacer en caja??? No! por si cancelan el folio
	if xcapital_pagado_actual>0 then
		xmonto_distribuir:=xcapital_pagado_actual;
		while xmonto_distribuir>0 loop
			--busco donde meterlo
			select corteid,(capital-capital_pagado) into ncorte_id_distribuir,xmonto_pendiente from corte_linea where (capital-capital_pagado)>0 and lineaid=pprestamoid order by fecha_corte limit 1;
			xmonto_pendiente:=coalesce(xmonto_pendiente,0);
			--no hay termino y se sale
			if xmonto_pendiente<=0 then
				exit;
			else --si hay? lo meto
				if xmonto_distribuir<xmonto_pendiente then --todavia hay suficiente
					xmonto_pendiente:=xmonto_distribuir;
				end if;
				update corte_linea set capital_pagado=(capital_pagado+xmonto_pendiente) where corteid=ncorte_id_distribuir;
				xmonto_distribuir:=xmonto_distribuir-xmonto_pendiente;
			end if;
		end loop;
	end if;
	--Cálculo del capital pendiente (el capital que no cubrió totalmente de corte a corte, si pago posterior a la fecha limite ese moratiorio se le cobra en caja)
	xcapital_vencido:=xcapital_adeudado_anterior-xcapital_pagado_actual;
	raise notice 'xcapital_vencido=%',xcapital_vencido;
	if xcapital_vencido>0 then --tiene un saldo de capital que no cubrió
		--fecha de adeudo (desde cuando debe?) 
		select fecha_limite into dfecha_adeudo from corte_linea where lineaid=pprestamoid and (capital-capital_pagado)>0 order by fecha_corte limit 1;
		raise notice 'dfecha_adeudo=%',dfecha_adeudo;
		ndias_capital:=pfecha-dfecha_adeudo; -- se calculan los dias de adeudo de capital
		--Calculo el interes moratorio a pagar al corte
		update calculo set amortizacion=xcapital_vencido,dias=ndias_capital,tasaintnormal=xtasa_moratoria where calculoid=2;
		SELECT formula into sformula from calculo where calculoid=2;
		for rec in execute
		  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||2
		loop
		  xmoratorio := rec.monto;
		end loop;
		xiva:=xmoratorio*0.16;
	else
		xcapital_vencido:=0;
	end if;
	--Interes mor dev no cob balance
	if ndias_capital>ndiastraspasovencida then
		ndias_calculo:=ndiastraspasovencida;
		update calculo set amortizacion=xcapital_vencido,dias=ndias_calculo,tasaintnormal=xtasa_moratoria where calculoid=2;
		SELECT formula into sformula from calculo where calculoid=2;
		for rec in execute
		  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||2
		loop
		  xint_mor_dev_balance := rec.monto;
		end loop;
		xint_mor_dev_balance:=coalesce(xint_mor_dev_balance,0);
	else
		xint_mor_dev_balance:=xmoratorio;
	end if;
	
	--Interes mor dev no cob ctas orden
	if ndias_capital>ndiastraspasovencida then
		ndias_calculo:=ndias_capital-ndiastraspasovencida;
		update calculo set amortizacion=xcapital_vencido,dias=ndias_calculo,tasaintnormal=xtasa_moratoria where calculoid=2;
		SELECT formula into sformula from calculo where calculoid=2;
		for rec in execute
		  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||2
		loop
		  xint_mor_dev_cuent_orden := rec.monto;
		end loop;
	else
		xint_mor_dev_cuent_orden:=0;
	end if;
	
	
	--
	--	Se verifica si hay un pago pendiente de interes
	--

	--monto de interes pagado en el periodo
	select coalesce(sum(haber),0) into xinteres_pagado_actual from movslinead(pprestamoid,pfecha_anterior,pfecha,1) where tipomov=4;
	raise notice 'xinteres_pagado_actual=%',xinteres_pagado_actual;
	raise notice 'xinteres_adeudado_anterior=%',xinteres_adeudado_anterior;
	--Distribuir interes pagado si lo hubo
	if xinteres_pagado_actual>0 then
		xmonto_distribuir:=xinteres_pagado_actual;
		while xmonto_distribuir>0 loop
			--busca donde meterlo
			select corteid,(int_ordinario-interes_pagado) into ncorte_id_distribuir,xmonto_pendiente from corte_linea where (int_ordinario-interes_pagado)>0 and lineaid=pprestamoid order by fecha_corte limit 1;
			xmonto_pendiente:=coalesce(xmonto_pendiente,0);
			--no hay, termina y se sale
			if xmonto_pendiente<=0 then
				exit;
			else --si hay? lo meto
				if xmonto_distribuir<xmonto_pendiente then --todavia hay suficiente
					xmonto_pendiente:=xmonto_distribuir;
				end if;
				update corte_linea set interes_pagado=(interes_pagado+xmonto_pendiente) where corteid=ncorte_id_distribuir;
				xmonto_distribuir:=xmonto_distribuir-xmonto_pendiente;
			end if;
		end loop;
	end if;
	--Cálculo del interes pendiente (el interes que no cubrió totalmente de corte a corte, si pagó posterior a la fecha limite ese moratiorio se le cobra en caja)
	xinteres_vencido:=xinteres_adeudado_anterior-xinteres_pagado_actual;
	raise notice 'xinteres_vencido=%',xinteres_vencido;
	if xinteres_vencido>0 then --tiene un saldo de interés que no cubrió
		xiva:=xiva+xinteres_vencido*0.16;
	else
		xinteres_vencido:=0;
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
	xsaldo_promedio:=round(xsaldo_promedio/ndias_corte,2);
	
	
	--
	-- Cálculo del capital a pagar (saldoinsoluto x el 5%) + el capital pendiente de pago (si lo hay)
	--
	select count(*) into nnumdisp from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov in (1);
	select spssaldoadeudolinea into xsaldo_insoluto from spssaldoadeudolinea(pprestamoid);
	raise notice 'xsaldo_insoluto=%',xsaldo_insoluto;
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
	-- Cálculo del interes ordinarios en base al saldo promedio diario
	--
	update calculo set saldopromdiario=xsaldo_promedio,dias=ndias_corte,tasaintnormal=xtasa_normal where calculoid=7;
	SELECT formula into sformula from calculo where calculoid=7;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||7
	loop
	  xordinario := rec.monto;
	end loop;
	xiva:=xiva+(xordinario*0.16);
	
	--Interes ord dev no cob balance
	select sum(coalesce(int_ordinario-interes_pagado,0)) into xint_ord_dev_balance from corte_linea where (pfecha-fecha_limite)<ndiastraspasovencida and fecha_corte<=pfecha;
	xint_ord_dev_balance:=coalesce(xint_ord_dev_balance,0);
	xint_ord_dev_balance:=xint_ord_dev_balance+xordinario;
	--Interes orde dev no cob ctas orden
	select sum(coalesce(int_ordinario-interes_pagado,0)) into xint_ord_dev_cuent_orden from corte_linea where (pfecha-fecha_limite)>=ndiastraspasovencida and fecha_corte<=pfecha;
	xint_ord_dev_cuent_orden:=coalesce(xint_ord_dev_cuent_orden,0);
	
	--
	-- Cálculo del pago mínimo
	--
	update calculo set saldoinsoluto=xsaldo_insoluto,saldopromdiario=xsaldo_promedio,dias=ndias_corte,tasaintnormal=xtasa_normal where calculoid=8;
	SELECT formula into sformula from calculo where calculoid=8;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||8
	loop
	  xpago_minimo := rec.monto;
	end loop;
	xiva:=round(xiva,2);
	xpago_minimo := xpago_minimo + xcapital_vencido + xinteres_vencido + xmoratorio + xiva;
	
	---
	--- Otros
	---
	select dia_mes_cobro into ndias_limite from prestamos where prestamoid=pprestamoid;
	dfecha_limte_pago:=pfecha+ndias_limite;
	--Los cortes que ya están pagados se ponen en estatus 0 (estatus=1 -> no pagado,estatus=0 -> pagado)
	update corte_linea set estatus=0 where (capital-capital_pagado)<=0 and (int_ordinario-interes_pagado)<=0 and estatus=1 and fecha_corte<pfecha;
	--Saco los dias de interes que debe
	select (pfecha-fecha_limite) into ndias_interes from corte_linea where (int_ordinario-interes_pagado)>0 and lineaid=pprestamoid order by fecha_corte limit 1;
	ndias_interes:=coalesce(ndias_interes,0);
	
	insert into corte_linea (lineaid,fecha_corte,dias_corte,saldo_inicial,saldo_final,saldo_promedio,num_disposiciones,monto_diposiciones,capital,int_ordinario,int_moratorio,iva,comisiones,pago_minimo,fecha_limite,dias_capital,dias_interes,fecha_pago_interes,fecha_pago_capital,capital_pagado,capital_vencido,interes_pagado,interes_vencido,int_ord_dev_balance,int_ord_dev_cuent_orden,int_mor_dev_balance,int_mor_dev_cuent_orden,estatus) values (pprestamoid,pfecha,ndias_corte,xsaldo_inicial,xsaldo_final,xsaldo_promedio,nnumdisp,xdisposiciones,xcapital,xordinario,xmoratorio,xiva,0,xpago_minimo,dfecha_limte_pago,ndias_capital,ndias_interes,null,null,0,xcapital_vencido,0,xinteres_vencido,xint_ord_dev_balance,xint_ord_dev_cuent_orden,xint_mor_dev_balance,xint_mor_dev_cuent_orden,1);
  return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

