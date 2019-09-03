CREATE OR REPLACE FUNCTION "public"."valida_garantia_desembolso"(int4, varchar)
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
			psocioid alias for $1;
			ptipoprestamo alias for $2;
			xcontrol_garantia numeric;
			ngarantiaactual numeric;
	BEGIN
	-- Routine body goes here...
		select sum(coalesce(aa,0))+sum(coalesce(p3,0)) into xcontrol_garantia from controlgarantialiquida where socioid=psocioid;
		
		select coalesce(sum(saldo),0) into ngarantiaactual from spssaldosmov(psocioid) where tipomovimientoid in ('P3','AA');
		
		IF ngarantiaactual < xcontrol_garantia AND 	ptipoprestamo<>'N16' THEN
			RAISE EXCEPTION 'Falta depositar el ahorro garantia o la parte social para este préstamo';
		END IF;
		

	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100