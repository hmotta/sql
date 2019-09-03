CREATE OR REPLACE FUNCTION "corrige_matriz_riesgo"()
  RETURNS "pg_catalog"."int4" AS $BODY$ DECLARE
	snextprestamo CHAR ( 7 );
	lconsecutivo int4;
	dfecha_ingreso date;
	ndias int4;
	xvalor numeric;
	srespuesta text;
	snivel character varying(30);
	r record;
BEGIN
	FOR r IN 
		SELECT	socioid,preguntaid,respuesta FROM	matrizriesgo WHERE (valor = 0 OR respuesta='')	AND preguntaid = 23
	loop
		SELECT fechaingreso into dfecha_ingreso FROM solicitudingreso WHERE socioid=r.socioid;
		select (current_date	- dfecha_ingreso) into ndias;
		
		if ndias<=180 then
			srespuesta='DE 0 A 6 MESES';
			snivel='BAJO';
		elsif ndias>180 and ndias<=360 then
			srespuesta='DE 6 A 12 MESES';
			snivel='MEDIO';
		else
			srespuesta='MAYOR DE 12 MESES';
			snivel='ALTO';
		end if;
		
		SELECT valor into xvalor from nivelderiesgo where descripcion=snivel;
		update matrizriesgo set respuesta=srespuesta,valor=xvalor where preguntaid=r.preguntaid and socioid=r.socioid;
		
	END loop;
	
	FOR r IN 
		SELECT	socioid,preguntaid,respuesta FROM	matrizriesgo WHERE (valor = 0 OR respuesta='') 	AND preguntaid = 28
	loop
		ndias=0;
		--AÑOS
		select regexp_replace(tiempovivirendomicilio,'[A-Z]*|Ñ','','g') INTO ndias FROM solicitudingreso WHERE socioid=r.socioid and tiempovivirendomicilio SIMILAR TO '%AÑOS';
		select tiempovivirendomicilio INTO srespuesta FROM solicitudingreso WHERE socioid=r.socioid;
		
		if ndias>5 then
			srespuesta='MÁS DE 5 AÑOS';
			snivel='BAJO';
		elsif ndias>=2 and ndias<=5 then
			srespuesta='DE 6 A 12 MESES';
			snivel='MEDIO';
		else
			srespuesta='MENOS DE 2 AÑOS';
			snivel='ALTO';
		end if;
		SELECT valor into xvalor from nivelderiesgo where descripcion=snivel;
		update matrizriesgo set respuesta=srespuesta,valor=xvalor where preguntaid=r.preguntaid and socioid=r.socioid;
		
	end loop;
		

RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER