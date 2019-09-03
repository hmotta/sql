CREATE OR REPLACE FUNCTION cuenta_amortizaciones_anticipadas(int4, numeric)
  RETURNS "pg_catalog"."int4" AS $BODY$ 
	DECLARE
		pprestamoid alias for $1;
		ppago_capital alias for $2;
		xmonto_amortizacion numeric;
		npagos_cubre integer;
		r record;
		xpago_capital numeric;
BEGIN
		xpago_capital:=ppago_capital;
		npagos_cubre:=0;
		--Descontamos la amortizacion no cubierta que le toca pagar a la fecha actual (ya que antes se debe validar que esté en 0 mora)
		select (importeamortizacion-abonopagado) into xmonto_amortizacion from amortizaciones where (importeamortizacion-abonopagado)>0 and abonopagado>0 and prestamoid=pprestamoid and fechadepago=current_date order by fechadepago desc limit 1;
		IF xpago_capital>=xmonto_amortizacion THEN
				xpago_capital:=xpago_capital-xmonto_amortizacion;
		END IF;
		--raise notice 'xpago_capital=%',xpago_capital;
		--Verifica cuantas amortizaciones cubre el pago
		FOR r IN
			select importeamortizacion from amortizaciones where abonopagado=0 and prestamoid=pprestamoid and fechadepago>current_date order by fechadepago desc limit 10
		LOOP
			IF xpago_capital>=r.importeamortizacion THEN
				xpago_capital:=xpago_capital-r.importeamortizacion;
				npagos_cubre:=npagos_cubre+1;
				--raise notice 'xpago_capital=%',xpago_capital;
				--raise notice 'npagos_cubre=%',npagos_cubre;
			ELSE
				EXIT;
			END IF;
		END LOOP;
	RETURN npagos_cubre;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;