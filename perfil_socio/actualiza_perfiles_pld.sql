CREATE OR REPLACE FUNCTION actualiza_perfiles_pld()
  RETURNS pg_catalog.int4 AS $BODY$
	DECLARE
		r record;
	BEGIN
		--Socios de reciente ingreso que ya cumplieron 6 meses o mas y socios que ya tiene 6 meses que se le actualizó su perfil
		for r in 
			select socioid from socio natural join generalesconceatucliente where estatussocio in (1,2) AND  (fecha_act_perfil is null and extract (month from age(fechaalta)) >= 6) OR (fecha_act_perfil is not null and extract (month from age(fecha_act_perfil)) >= 6) group by socioid order by socioid
		loop
			perform actualiza_perfil_socio(r.socioid);
			raise notice 'Socio: % procesado correctamente',r.socioid;
		end loop;
	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;