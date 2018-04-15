CREATE or replace FUNCTION spscalculopago_linea(integer) RETURNS SETOF tcalculopago
    AS $_$
declare
  pprestamoid alias for $1;
  r tcalculopago%rowtype;
  
  rec record;
  xtasa_moratoria numeric;
  sformula text;
  
  ncorte_anterior_id integer;
  ndias_mora integer;
  dfecha_limite date;
  dfecha_corte date;
  
  xcapital_corte numeric;
  xinteres_corte numeric;
  xmoratorio_corte numeric;
  
  xcapital_pagar numeric;
  xinteres_pagar numeric;
  xmoratorio_pagar numeric;
  
  xpago_minimo numeric;
  xiva numeric;
  xmoratorio_adicional numeric;
  
  xcapital_pagado_actual numeric;
  xinteres_pagado_actual numeric;
  
  xsaldo_linea numeric;
  
  xsaldo_promedio numeric;
begin
	xcapital_corte:=0;
	xinteres_corte:=0;
	xmoratorio_corte:=0;
	xpago_minimo:=0;
    xiva:=0;
    xmoratorio_adicional:=0;
	xcapital_pagado_actual:=0;
    xinteres_pagado_actual:=0;
	xcapital_pagar:=0;
    xinteres_pagar:=0;
    xmoratorio_pagar:=0;
	xsaldo_promedio:=0;
	
	select saldoprestamo into xsaldo_linea from prestamos where prestamoid=pprestamoid;
	--
	-- Verifica si hay un corte anterior 
	--
	select corteid into ncorte_anterior_id from corte_linea where lineaid=pprestamoid and fecha_corte<=current_date order by fecha_corte desc limit 1;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		r.prestamoid   := pprestamoid;
		r.amortizacion := 0;
		r.capital      := round(xsaldo_linea,2);
		r.interes      := 0;
		r.moratorio    := 0;
		r.iva          := 0;
		r.total        := 0;
		return next r;
	else
		--Ya hay un corte anterior
		select 
			saldo_promedio,
			fecha_limite,
			fecha_corte,
			(capital+coalesce(capital_vencido,0)),
			(int_ordinario+coalesce(interes_vencido,0)),
			int_moratorio 
			into 
			xsaldo_promedio,
			dfecha_limite,
			dfecha_corte,
			xcapital_corte,
			xinteres_corte,
			xmoratorio_corte 
		from corte_linea where corteid=ncorte_anterior_id;
		
		
		--
		-- ====================== Verifico los pagos realizados en el periodo (si lo hay) ===========================
		--
		-- Capital pagado en el periodo
		select coalesce(sum(haber),0) into xcapital_pagado_actual from movslinead(pprestamoid,dfecha_corte,current_date,1) where tipomov=3;
		-- Interes pagado en el periodo
		select coalesce(sum(haber),0) into xinteres_pagado_actual from movslinead(pprestamoid,dfecha_corte,current_date,1) where tipomov=4;
		
		--a lo calculado del corte se le resta los pagos que realizó en el periodo si es que los hay
		raise notice 'xcapital_corte=% xcapital_pagado_actual=%',xcapital_corte,xcapital_pagado_actual;
		xcapital_pagar:=xcapital_corte-xcapital_pagado_actual;
		raise notice 'xinteres_corte=% xinteres_pagado_actual=%',xinteres_corte,xinteres_pagado_actual;
		xinteres_pagar:=xinteres_corte-xinteres_pagado_actual;
		
		if xcapital_pagar>0 then
			--
			-- ====================== Calculo del moratorio del periodo (si lo hay) ===========================
			--
			ndias_mora:= current_date - dfecha_limite;
			if ndias_mora>0 then --hay un monto pendiente de capital, solo verificar que no esté en mora, si lo esta se adiciona
				select tasa_moratoria into xtasa_moratoria from prestamos where prestamoid=pprestamoid;
				
				update calculo set amortizacion=xcapital_corte,dias=ndias_mora,tasaintnormal=xtasa_moratoria where calculoid=2;
				SELECT formula into sformula from calculo where calculoid=2;
				for rec in execute
				  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||2
				loop
				  xmoratorio_adicional := rec.monto;
				end loop;
			end if;
			
			xmoratorio_pagar:=xmoratorio_corte+xmoratorio_adicional;
			xiva:= round((xinteres_pagar+xmoratorio_pagar)*0.16,2);
			
			r.prestamoid   := pprestamoid;
			r.amortizacion := xsaldo_promedio;
			r.capital      := round(xcapital_pagar,2);
			r.interes      := round(xinteres_pagar,2);
			r.moratorio    := round(xmoratorio_pagar,2);
			r.iva          := round(xiva,2);
			r.total        := round(xcapital_pagar,2)+round(xinteres_pagar,2)+round(xmoratorio_pagar,2)+round(xiva,2);
			return next r;
		else
			r.prestamoid   := pprestamoid;
			r.amortizacion := 0;
			r.capital      := round(xsaldo_linea,2);
			r.interes      := 0;
			r.moratorio    := 0;
			r.iva          := 0;
			r.total        := 0;
			return next r;
		end if;
		
		
	end if;
	--ncorte_anterior_id:=coalesce(ncorte_anterior_id,0);

	
	return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
