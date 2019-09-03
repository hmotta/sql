--drop type inversiongarantia cascade;
CREATE TYPE inversiongarantia AS (
	garantiainversionid integer,
	referenciaprestamo character varying(18),
	inversionid integer,
	desctipoinversion character varying(30),
	depositoinversion numeric,
	montocomprometido numeric,
	montodisponible numeric
);

CREATE or replace  FUNCTION spsinversiongrabada(integer) RETURNS SETOF inversiongarantia
    AS $_$
declare
  psocioid alias for $1;  
  r inversiongarantia%rowtype;
  --l record;
  --m record;
  nsumacomprometido numeric;
  iprestamos integer;
  iinversiones integer;
begin

	for r in 
		select g.garantiainversionid,
		(select referenciaprestamo from prestamos where prestamoid=g.prestamoid),
		i.inversionid,
		(select desctipoinversion from tipoinversion where tipoinversionid=i.tipoinversionid),
		(select depositoinversion from inversion where inversionid=g.inversionid),
		g.montocomprometido,
		0
		from inversion i right join garantiainversion g on (i.inversionid=g.inversionid and g.vigente=true) where i.depositoinversion<>i.retiroinversion and i.depositoinversion>0 and i.socioid=psocioid and tipoinversionid not in ('PSV','PSO','K3') order by garantiainversionid
	loop
		select coalesce(sum(montocomprometido),0) into nsumacomprometido from garantiainversion where inversionid=r.inversionid and vigente=true;
		r.montodisponible:=r.depositoinversion-coalesce(nsumacomprometido,0);
		
		return next r;
	end loop;
	return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

