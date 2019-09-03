CREATE OR REPLACE FUNCTION "public"."corrige_suma_amortizaciones"(integer)
  RETURNS "pg_catalog"."int4" AS $BODY$ 
	DECLARE
		pprestamoid alias for $1;
		xsuma_amort numeric;
		xmonto_ajustar numeric;
		xmonto_prestamo numeric;
		xsaldo_insoluto numeric;
		nultima_amor numeric;
		estado_prestamo varchar(3);
		r record;
		l record;
	BEGIN
			
			select montoprestamo,claveestadocredito into xmonto_prestamo,estado_prestamo from prestamos where prestamoid=pprestamoid;
			select sum(importeamortizacion) into xsuma_amort from amortizaciones where prestamoid=pprestamoid;
			xsaldo_insoluto:=xmonto_prestamo;
			xmonto_ajustar:=xsuma_amort-xmonto_prestamo;
			if xmonto_ajustar>0 then --La suma de las amortizaciones es mayor al monto del prestamo
				if estado_prestamo='001' then --Prestamo Activo
					for r in --Recorre las amortizaciones NO PAGADAS de la ultima a la primera, para buscar donde ajustar el pago
						select amortizacionid,numamortizacion,importeamortizacion,abonopagado from amortizaciones where importeamortizacion<>0 and (importeamortizacion-abonopagado)>0 and prestamoid=pprestamoid order by numamortizacion desc
					loop
						if xmonto_ajustar<=(r.importeamortizacion-r.abonopagado) then
							update amortizaciones set importeamortizacion=(importeamortizacion-xmonto_ajustar) where amortizacionid=r.amortizacionid and prestamoid=pprestamoid;
							if xmonto_ajustar=(r.importeamortizacion-r.abonopagado) then
								update amortizaciones set ultimoabono=current_date where amortizacionid=r.amortizacionid and prestamoid=pprestamoid;
							end if;
							exit;
						end if;
					end loop;
				else
					select max(numamortizacion) into nultima_amor from amortizaciones where prestamoid=pprestamoid;
					update amortizaciones set importeamortizacion=(importeamortizacion-xmonto_ajustar) where numamortizacion=nultima_amor and prestamoid=pprestamoid;
				end if;
			else  --La suma de las amortizaciones es menor al monto del prestamo
				if estado_prestamo='001' then --Prestamo Activo
				select max(numamortizacion) into nultima_amor from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=pprestamoid;
					update amortizaciones set importeamortizacion=(importeamortizacion-xmonto_ajustar) where numamortizacion=nultima_amor and prestamoid=pprestamoid;
				else
					select max(numamortizacion) into nultima_amor from amortizaciones where prestamoid=pprestamoid;
					update amortizaciones set importeamortizacion=(importeamortizacion-xmonto_ajustar) where numamortizacion=nultima_amor and prestamoid=pprestamoid;
				end if;
			end if;
			
			for l in --Recorre TODAS las amortizaciones de la primera a la ultima para ajustar el saldo insoluto y el moto total del pago
				select amortizacionid,numamortizacion,importeamortizacion,interesnormal,iva from amortizaciones where prestamoid=pprestamoid order by numamortizacion
			loop
				update amortizaciones set totalpago=(l.importeamortizacion+l.interesnormal+l.iva) where amortizacionid=l.amortizacionid and prestamoid=pprestamoid;
				xsaldo_insoluto:=xsaldo_insoluto-l.importeamortizacion;
				update amortizaciones set saldo_absoluto=xsaldo_insoluto where amortizacionid=l.amortizacionid and prestamoid=pprestamoid;
			end loop;		
	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;