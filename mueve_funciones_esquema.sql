CREATE OR REPLACE FUNCTION "public"."mueve_funciones_esquema"()
  RETURNS "pg_catalog"."int4" AS $BODY$
	declare
		r record;
		l record;
	BEGIN
	
	FOR r IN
		select nspname as esquema from pg_catalog.pg_namespace where nspname not in ('pg_toast','pg_temp_1','pg_catalog','information_schema','public')
	LOOP
		EXECUTE 'set search_path to public,'||r.esquema;
		FOR l IN
			SELECT proname ||'('||	pg_catalog.oidvectortypes ( proargtypes )||')' AS "funcion" FROM pg_catalog.pg_proc	JOIN pg_catalog.pg_namespace NAMESPACE ON pronamespace = NAMESPACE.oid WHERE	nspname = r.esquema
		LOOP
				raise notice 'Moviendo la Funcion % ',l.funcion;
				EXECUTE 'alter function '||l.funcion||' set schema "public";';
				
		END LOOP;
	END LOOP;
	
	RETURN 1;
EXCEPTION WHEN OTHERS THEN
	raise notice 'Error en la funcion % ,% ,%',l.funcion,SQLERRM, SQLSTATE;
	raise notice 'Borrando funcion %.% ...',r.esquema,l.funcion;
	execute 'drop function '||r.esquema||'.'||l.funcion||';';
	--raise notice 'drop function %.%',r.esquema,l.funcion;
	RETURN 2;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100