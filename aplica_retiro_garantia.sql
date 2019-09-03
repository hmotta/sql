CREATE OR REPLACE FUNCTION "public"."aplica_retiro_garantia"(int4, varchar, numeric)
  RETURNS "pg_catalog"."int4" AS $BODY$
	--Dosminuye la garantia registrada del credito en cuestion ya que fue retirada
	DECLARE
		pprestamoid alias for $1;
		ptipomovimientoid alias for $2;
		pmonto_retiro alias for $3;
		xmonto_aa numeric;
		xmonto_p3 numeric;
		xResto numeric;
	BEGIN
		select coalesce(aa,0),coalesce(p3,0) into xmonto_aa,xmonto_p3 from controlgarantialiquida where prestamoid=pprestamoid;
		xResto:=0;
		IF ptipomovimientoid='AA' THEN
			xResto=xmonto_aa-pmonto_retiro;
			update controlgarantialiquida set aa=xResto,ultimomov=current_date where prestamoid=pprestamoid;
		END IF;
		IF ptipomovimientoid='P3' THEN
			xResto=xmonto_p3-pmonto_retiro;
			update controlgarantialiquida set p3=xResto,ultimomov=current_date where prestamoid=pprestamoid;
		END IF;
	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100