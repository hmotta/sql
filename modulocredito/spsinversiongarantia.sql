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

CREATE or replace  FUNCTION spsinversiongarantia(integer) RETURNS SETOF inversiongarantia
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
		select 0,
		0,
		i.inversionid,
		(select desctipoinversion from tipoinversion where tipoinversionid=i.tipoinversionid),
		i.depositoinversion,
		coalesce(g.montocomprometido,0),
		0
		from inversion i left join garantiainversion g on (i.inversionid=g.inversionid and g.vigente=true) where i.depositoinversion<>i.retiroinversion and i.depositoinversion>0 and i.socioid=psocioid and tipoinversionid not in ('PSV','PSO','K3') group by i.inversionid,i.depositoinversion,i.tipoinversionid,g.montocomprometido,g.garantiainversionid order by garantiainversionid
	loop
		select coalesce(sum(montocomprometido),0) into nsumacomprometido from garantiainversion where inversionid=r.inversionid and vigente=true;
		r.montodisponible:=r.depositoinversion-nsumacomprometido;
		
		return next r;
	end loop;
	return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

