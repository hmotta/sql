CREATE TYPE rpagoanticipado AS (
	monto_aplicar numeric,
	num_amortizacion numeric,
	num_pagos integer,
	fecha_entrega date,
	fecha_primer_pago date
);

CREATE or replace FUNCTION aplica_pago_anticpado_amort(integer,numeric,numeric,integer) RETURNS rpagoanticipado
AS $_$
declare
	pprestamoid alias for $1;
	pcap_pagado alias for $2;
	pint_pagado alias for $3;
	popcion alias for $4;
	
	xcap_pagado numeric;
	r rpagoanticipado%rowtype;
	l record;
	namortizacionid integer;
	nnumamortizacion numeric;
	nnumamortizacion_ini numeric;
	nnumamortizacion_hija numeric;
	dfechaamortizacion date;
	
	xcap_restante_amort numeric;
	xcap_restante numeric;
	xint_pagado_amor numeric;
	xmonto_prestamo numeric;
	xsuma_amort numeric;
	lsaldoprestamo numeric;
	ndias_mora_capital integer;
	dfechaultimopago date;
	
  begin
	xcap_pagado := round(pcap_pagado,2);
	perform copia_tabla_amort(pprestamoid);
	r.num_pagos:=0;
	xint_pagado_amor:=0;
	select montoprestamo into xmonto_prestamo from prestamos where prestamoid=pprestamoid;
	if popcion=2 then --opcion 2 -> reducir monto
		----> Tomar la amortizacion adecuada
		--Obtener la ultima amortizacion no pagada en orden ascendente
		select amortizacionid,numamortizacion,fechadepago,(importeamortizacion-abonopagado) into namortizacionid,nnumamortizacion_ini,dfechaamortizacion,xcap_restante_amort from amortizaciones where prestamoid=pprestamoid and (importeamortizacion-abonopagado)>0 order by numamortizacion limit 1;
		
		IF dfechaamortizacion<>current_date THEN --Si no le toca hoy, se toma la ultima amortizacion pagada
			select amortizacionid,numamortizacion,fechadepago into namortizacionid,nnumamortizacion,r.fecha_entrega from amortizaciones where prestamoid=pprestamoid and importeamortizacion<>0 and (importeamortizacion-abonopagado)=0 and numamortizacion<nnumamortizacion_ini and ceil(numamortizacion)=numamortizacion order by numamortizacion desc limit 1;
			xint_pagado_amor:=pint_pagado;
			xcap_restante_amort := 0;
		ELSE
			nnumamortizacion:=nnumamortizacion_ini;
			r.fecha_entrega:=dfechaamortizacion;
		END IF;
		r.num_amortizacion:=nnumamortizacion+1;
		------< Tomar la amortizacion adecuada
		
		--Regresar a 0 las amortizaciones restantes no pagadas
		for l in 
			select amortizacionid,numamortizacion,importeamortizacion,abonopagado from amortizaciones where importeamortizacion<>0 and (importeamortizacion-abonopagado)>0 and numamortizacion>nnumamortizacion and prestamoid=pprestamoid order by numamortizacion desc
		loop
			if l.abonopagado=0 then
				update amortizaciones set importeamortizacion=0,interesnormal=0,saldo_absoluto=0,iva=0,totalpago=0 where amortizacionid=l.amortizacionid;
			else
				update amortizaciones set importeamortizacion=l.abonopagado+0.1 where amortizacionid=l.amortizacionid;
			end if;
			r.num_pagos:=r.num_pagos+1;
		end loop;
		
		select fechadepago into r.fecha_primer_pago from amortizaciones where prestamoid=pprestamoid and numamortizacion=(nnumamortizacion+1);
		
		--Sacamos el numero de la amortizacion hija
		select max(numamortizacion) into nnumamortizacion_hija from amortizaciones where numamortizacion>=nnumamortizacion and numamortizacion<nnumamortizacion+1;
		nnumamortizacion_hija:=nnumamortizacion_hija+0.1;
		
		-->>>Realizamos el pago de la amortizacion
			update prestamos set saldoprestamo = saldoprestamo - pcap_pagado, fechaultimopago = now()  where prestamoid=pprestamoid;
			if dfechaamortizacion=current_date then --unicamente si le toca el pago hoy, pagamos la amortizacion
				if xcap_pagado>xcap_restante_amort then
					update amortizaciones set abonopagado=importeamortizacion,ultimoabono=now() where numamortizacion=nnumamortizacion and prestamoid=pprestamoid;
					xcap_pagado := xcap_pagado - xcap_restante_amort;
					-- y se distribuye el interes
					xint_pagado_amor:=0;
				end if;
			end if;
		--<<<Realizamos el pago de la amortizacion
		
		  --Despues se inserta la amortizacion hija ya pagada
		insert into amortizaciones (prestamoid,numamortizacion,fechadepago,importeamortizacion,interesnormal,abonopagado,ultimoabono,dias_mora_capital,saldo_absoluto,interespagado) values (pprestamoid,nnumamortizacion_hija,current_date,xcap_pagado,xint_pagado_amor,xcap_pagado,current_date,0,0,xint_pagado_amor);
		
		
		--La tabla se completa con el algoritmo del SIOEF
		select sum(importeamortizacion) into xsuma_amort from amortizaciones where prestamoid=pprestamoid;
		xsuma_amort:=coalesce(xsuma_amort,0);
		
		--Se devuelve el monto restante que se debe reestructurar en el plan de pagos
		r.monto_aplicar:=xmonto_prestamo - xsuma_amort;
		return r;
	elsif popcion=3 then --opcion 3 -> reducir plazo
		
		xcap_restante_amort:=0;
		namortizacionid:=0;
		--Obtengo el monto del prestamo
		
		--Descontamos la amortizacion que le toca pagar a la fecha actual
		select amortizacionid,(importeamortizacion-abonopagado) into namortizacionid,xcap_restante_amort from amortizaciones where abonopagado>0 and (importeamortizacion-abonopagado)>0 and prestamoid=pprestamoid and fechadepago=current_date order by fechadepago desc limit 1;
		xcap_restante:=pcap_pagado-coalesce(xcap_restante_amort,0);
		
		--Posterioemente se van pagando las ultimas amortizaciones hasta donde alcance el pago.
		for l in
			select amortizacionid,importeamortizacion from amortizaciones where prestamoid=pprestamoid and (importeamortizacion-abonopagado)>0 order by fechadepago desc
		loop
			if xcap_restante>0 then
				if xcap_restante>=l.importeamortizacion then
					xcap_restante:=xcap_restante-l.importeamortizacion;
					update amortizaciones set abonopagado=importeamortizacion,ultimoabono=current_date,interesnormal=0,interespagado=0,iva=0,totalpago=importeamortizacion where amortizacionid=l.amortizacionid;
				else
					update amortizaciones set abonopagado=xcap_restante,ultimoabono=current_date,interesnormal=0,interespagado=0,iva=0,totalpago=xcap_restante where amortizacionid=l.amortizacionid;
					xcap_restante:=0;
				end if;
			else
				exit;
			end if;
		end loop;
		perform spabonoprestamo(pprestamoid,0);
		
		--Se devuelve el capital restante para aplicarlo a la amortizacion siguiente en el SIOEF
		r.monto_aplicar:=xcap_restante;
		return r;
	end if;
	
  
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

