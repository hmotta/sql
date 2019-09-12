CREATE OR REPLACE FUNCTION genera_matrices_pld()
  RETURNS pg_catalog.int4 AS $BODY$
	DECLARE
		r record;
	BEGIN
		for r in 
			select socioid from socio where estatussocio in (1,3) order by socioid
		loop
			perform genera_matriz_riesgo(r.socioid);
			raise notice 'Socio: % procesado correctamente',r.socioid;
		end loop;
	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;