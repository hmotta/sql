CREATE OR REPLACE FUNCTION "public"."valida_retiro_garantia"(int4, varchar, numeric)
  RETURNS "pg_catalog"."numeric" AS $BODY$
	--Esta función valida el retiro directo del ahorro en caja, es decir sin aplicar al credito. por lo cual no toma en cuenta lo autorizado por autorizaretirogarantia
	DECLARE
		psocioid alias for $1;
		ptipomovimientoid alias for $2;
		psaldo_retirar alias for $3;
		ngarantiaactual numeric;
		ngarantiarequerida numeric;
	BEGIN
		select coalesce(sum(saldo),0) into ngarantiaactual from spssaldosmov(psocioid) where tipomovimientoid in ('P3','AA');
		select coalesce(sum(monto_garantia),0) into ngarantiarequerida from prestamos where claveestadocredito='001' and  socioid=psocioid and prestamoid in (select prestamoid from movicaja where prestamoid is not null union select prestamoid from movibanco where prestamoid is not null);
		raise notice '(ngarantiaactual-fretiro)==% , %',(ngarantiaactual-psaldo_retirar),ngarantiarequerida;
		if (ngarantiaactual-psaldo_retirar)<ngarantiarequerida then 
			raise exception 'El monto total en garantía de los créditos activos del socio, no puede ser menor a: % ',round(ngarantiarequerida,2);
		end if;
	RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100