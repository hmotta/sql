CREATE OR REPLACE FUNCTION "public"."mueve_tablas_esquema"()
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
			SELECT table_name as nombre_tabla FROM information_schema.tables WHERE table_schema=r.esquema AND table_type='BASE TABLE'
		LOOP
				raise notice 'Moviendo la Tabla % ',l.nombre_tabla;
				EXECUTE 'alter table '||l.nombre_tabla||' set schema "public";';
				
		END LOOP;
	END LOOP;
	
	RETURN 1;
EXCEPTION WHEN OTHERS THEN
	raise notice 'Error en la Tabla % ,% ,%',l.nombre_tabla,SQLERRM, SQLSTATE;
	RETURN 2;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100