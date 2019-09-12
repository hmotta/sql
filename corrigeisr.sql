CREATE OR REPLACE FUNCTION corrigeisr() RETURNS integer
    AS $_$
declare
  --psocioid alias for $1;
  --pinversionid alias for $1;
  r record;
  fisrxdia numeric;
  pdias integer;
  fisr numeric;
  pinversionexenta numeric;
  pporcentajeinversion numeric;
  gdiasanualesinversion int4;
  ntotalinversiones numeric;
  fdepositoinversion numeric;
  dfechainversion date;
  dfechavencimiento date;
  dfechapagoinversion date;

  --psocioid integer;
begin
  for r in 
  select inversionid,socioid,depositoinversion,fechainversion,fechavencimiento,tasainteresnormalinversion from inversion where fechainversion>='2016-08-18' and depositoinversion<>retiroinversion 
  loop
	  raise notice 'Socioid=% inversionid=%',r.socioid,r.inversionid;
	  --Sumar todas las inversiones que tenia al momento
	  --select sum(depositoinversion) into ntotalinversiones from inversion i,tipoinversion t where i.socioid = r.socioid and i.tipoinversionid = t.tipoinversionid and i.inversionid in(select in versionid from movicaja) and i.tipoinversionid not in ('PSO','PSV','PS2') and fechavencimiento>=r.fechainversion and fechainversion<=r.fechainversion;
	  select saldomov into ntotalinversiones from saldomov(r.socioid,'IN',r.fechainversion);
	  
	  raise notice 'Totalinversiones=% ',ntotalinversiones;
	   
	  select inversionexenta,porcentajeisrinversion,diasanualesinversion
		  into  pinversionexenta,pporcentajeinversion,gdiasanualesinversion from empresa where empresaid=1;

	  --Calcular el isr por dia para la inversion
	  if ntotalinversiones > pinversionexenta then
			fisrxdia=(r.depositoinversion)*pporcentajeinversion/gdiasanualesinversion;
	  else
			fisrxdia=0;
	  end if;
	  raise notice 'inversionid=% fisrxdia=%',r.inversionid,fisrxdia;
	  update inversion set isrxdia=fisrxdia where inversionid=r.inversionid;
	  
  end loop;
  
  return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
select * from corrigeisr();