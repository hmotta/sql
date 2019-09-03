CREATE OR REPLACE FUNCTION "public"."garantias_disponibles"(int4)
  RETURNS SETOF "public"."rgarantias_disponibles" AS $BODY$
	DECLARE
		psocioid alias for $1;
		r rgarantias_disponibles;
	BEGIN
	-- Routine body goes here...
		for r in 
			select p.prestamoid,p.referenciaprestamo,'LIQUIDADO','AA: '||coalesce(cg.aa,0)||' P3: '||coalesce(cg.p3,0) from controlgarantialiquida cg inner join prestamos p on (cg.prestamoid=p.prestamoid) and p.claveestadocredito='002' and (cg.aa>0 or cg.p3>0) and p.socioid=psocioid
		loop
			RETURN NEXT r;
		end loop;
		--for r in 
			--select p.prestamoid,ag.referenciaprestamo,'GARANTIA LIBERADA','AA: '||coalesce(ag.montoaa,0)||' P3: '||coalesce(ag.montop3,0) from autorizaretirogarantia ag inner join prestamos p on (ag.referenciaprestamo=p.referenciaprestamo) where ag.aplicado=0 and p.socioid=psocioid
		--loop
			--RETURN NEXT r;
		--end loop;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000