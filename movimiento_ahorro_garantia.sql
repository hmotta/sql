CREATE OR REPLACE FUNCTION "public"."movimiento_ahorro_garantia"(varchar)
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		ptipomovimientoid alias for $1;
	BEGIN
	-- Routine body goes here...
		IF ptipomovimientoid IN ('AA','P3') THEN
			RETURN 1;
		END IF;
	RETURN 0;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100