CREATE OR REPLACE FUNCTION "public"."genera_matriz_riesgo"(int4)
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		psocioid alias for $1;
		nentero int4;
		xsuma numeric;
		xvalor numeric;
		srespuesta text;
		sriesgo_manual varchar(1);
		sdescripcion_nivel varchar(10);
		nnocooperante integer;
		nparaisofiscal integer;
		spaisnombre text;
	BEGIN
	
	
	for i in 1..30
	loop
		select * into xvalor,srespuesta from respuesta_matriz(psocioid,i);
		select preguntaid into nentero from matrizriesgo where preguntaid=i and socioid=psocioid;
		if found then
			update matrizriesgo set respuesta=srespuesta,valor=xvalor where preguntaid=i and socioid=psocioid;
		else
			insert into matrizriesgo (socioid,preguntaid,respuesta,valor) values (psocioid,i,srespuesta,xvalor);
		end if;
	end loop;
	
	--//forzado de nivel para Nacionalidad
	IF (select nacionalidad from generalesconceatucliente where socioid=psocioid)=2 THEN
			select nocooperante,paraisofiscal,paisnombre into nnocooperante,nparaisofiscal,spaisnombre from paisespld inner join generalesconceatucliente on (paisespld.clavepais=generalesconceatucliente.clavepais) where socioid=psocioid;
			IF nnocooperante=0 AND nparaisofiscal=0 THEN
				update matrizriesgo set respuesta=respuesta||', '||spaisnombre||', COOPERANTE, NO PARAISO FISCAL' WHERE preguntaid = 4 AND socioid = psocioid;
			ELSIF nnocooperante=0 AND nparaisofiscal=1 AND (SELECT SUM(valor) FROM matrizriesgo WHERE socioid = psocioid)>=46 THEN
				update matrizriesgo set valor=(SELECT (SUM(valor)-((1+45)/2))*-1 FROM matrizriesgo WHERE socioid = psocioid),respuesta=respuesta||', '||spaisnombre||', COOPERANTE, PARAISO FISCAL' WHERE preguntaid = 4 AND socioid = psocioid;
			ELSIF nnocooperante=1 AND nparaisofiscal=0 AND (SELECT SUM(valor) FROM matrizriesgo WHERE socioid = psocioid)>=46 THEN
				update matrizriesgo set valor=(SELECT (SUM(valor)-((1+45)/2))*-1 FROM matrizriesgo WHERE socioid = psocioid),respuesta=respuesta||', '||spaisnombre||', NO COOPERANTE, NO PARAISO FISCAL' WHERE preguntaid = 4 AND socioid = psocioid;
			ELSIF nnocooperante=1 AND nparaisofiscal=1 THEN
				update matrizriesgo set valor=(SELECT -60-SUM(valor) FROM matrizriesgo WHERE socioid = psocioid),respuesta=respuesta||', '||spaisnombre||', NO COOPERANTE, NO PARAISO FISCAL' WHERE preguntaid = 4 AND socioid = psocioid;
			END IF;
	END IF;
	
	--//forzado de nivel para ¿Tiene algún puesto público?/PEP´s
	IF (SELECT puestopublico FROM deppromedioconoceatucliente WHERE socioid=psocioid)=3 THEN
			update matrizriesgo set valor=(SELECT -60-SUM(valor) FROM matrizriesgo WHERE socioid = psocioid) WHERE preguntaid = 24 AND socioid = psocioid;
	ELSIF (SELECT puestopublico FROM deppromedioconoceatucliente WHERE socioid=psocioid)=2 AND (SELECT SUM(valor) FROM matrizriesgo WHERE socioid = psocioid)>=46  THEN
			update matrizriesgo set valor=(SELECT (SUM(valor)-((1+45)/2))*-1 FROM matrizriesgo WHERE socioid = psocioid) WHERE preguntaid = 24 AND socioid = psocioid;
	END IF;
	
	--//forzado de nivel ¿Algún familiar de usted, hasta segundo grado, ocupa algún puesto público?
	IF (SELECT familiarpuestoublico FROM deppromedioconoceatucliente WHERE socioid=psocioid)=3 THEN
			update matrizriesgo set valor=(SELECT -60-SUM(valor) FROM matrizriesgo WHERE socioid = psocioid) WHERE preguntaid = 25 AND socioid = psocioid;
	ELSIF (SELECT familiarpuestoublico FROM deppromedioconoceatucliente WHERE socioid=psocioid)=2 AND (SELECT SUM(valor) FROM matrizriesgo WHERE socioid = psocioid)>=46  THEN
			update matrizriesgo set valor=(SELECT (SUM(valor)-((1+45)/2))*-1 FROM matrizriesgo WHERE socioid = psocioid) WHERE preguntaid = 25 AND socioid = psocioid;
	END IF;
	
	--//forzado de nivel alto para la Lista de la OFAC
	IF (select listaofac from deppromedioconoceatucliente WHERE socioid = psocioid)=1 THEN
			update matrizriesgo set valor=(SELECT -60-SUM(valor) FROM matrizriesgo WHERE socioid = psocioid) WHERE preguntaid = 29 AND socioid = psocioid;
	END IF;
	
	--Establece Nivel Riesgo Total del Socio
	select round(sum(valor),2) into xsuma FROM matrizriesgo WHERE socioid = psocioid;
	select descripcion into sdescripcion_nivel from nivelderiesgo where xsuma between nivelriesgomin and nivelriesgomax;
	select riesgomanual into sriesgo_manual from nivelderiesgosocio where socioid =psocioid;	
	IF FOUND THEN
		IF sriesgo_manual='N' THEN 
			update nivelderiesgosocio set promedio=xsuma,descripcion=sdescripcion_nivel where socioid=psocioid;
		ELSE
			update nivelderiesgosocio set promedio=xsuma where socioid=psocioid;
		END IF;
	ELSE
		insert into nivelderiesgosocio (socioid,promedio,descripcion,riesgomanual) values (psocioid,xsuma,sdescripcion_nivel,'N');
	END IF;
	
	
	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;