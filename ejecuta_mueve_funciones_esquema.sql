CREATE OR REPLACE FUNCTION "public"."ejecuta_mueve_funciones_esquema"()
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		xresultado numeric;
	BEGIN
	-- Routine body goes here...
	xresultado:=2;
	WHILE xresultado=2 LOOP
		xresultado = mueve_funciones_esquema();
	END LOOP;
	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE