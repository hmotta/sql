CREATE OR REPLACE FUNCTION tmp_traspasa_clasif_amort()
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		r record;
		l record;
		nregistros integer;
	BEGIN
	-- Esta función migra los datos de la tabla clasificacioncartera a la tabla amortizaciones, para que ésta tenga los datos y fechas correctas
		FOR r IN
			select prestamoid from prestamos where claveestadocredito<>'008'
		LOOP
			FOR l IN 
				select amortizacionid,diasmora,fechapagoreal from calculadiasmora(r.prestamoid)
			LOOP
				update amortizaciones set dias_mora_capital=l.diasmora,ultimoabono=l.fechapagoreal where amortizacionid=l.amortizacionid;
				delete from clasificacioncartera where amortizacionid=l.amortizacionid;
			END LOOP;
		END LOOP;
		
		select count(*) into nregistros from clasificacioncartera;
		IF nregistros=0 THEN
			DROP TABLE clasificacioncartera;
			raise notice 'La tabla clasificacioncartera ha sido borrada';
		else
			raise notice 'Aun existen registros en la tabla clasificacioncartera';
		END IF;
	RETURN 1;
END$BODY$
  LANGUAGE plpgsql VOLATILE;