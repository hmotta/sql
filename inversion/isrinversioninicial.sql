CREATE or replace FUNCTION isrinversioninicial(integer) RETURNS numeric
    AS $_$
declare
  pinversionid alias for $1;
  
  pdias integer;
  fisr numeric;
  fisrxdia numeric;
  dfechainversion date;
  dfechavencimiento date;
  pinversionexenta numeric;
  pporcentajeinversion numeric;
  gdiasanualesinversion int4;
  psocioid integer;
  fdepositoinversion numeric;
  
begin
 fisr=0;
 select depositoinversion,fechainversion,fechavencimiento,socioid,isrxdia
  into fdepositoinversion,dfechainversion,dfechavencimiento,psocioid,fisrxdia
  from inversion i where i.inversionid=pinversionid;

    select inversionexenta,porcentajeisrinversion,diasanualesinversion
      into  pinversionexenta,pporcentajeinversion,gdiasanualesinversion from empresa where empresaid=1;
	
	pdias :=dfechavencimiento-dfechainversion;
	
	if dfechainversion>='2016-08-18' then --el calculo del ISR cambia para inversiones del 2016
		fisr=round(fisrxdia*pdias,2);
	else
		if fdepositoinversion > pinversionexenta then
			fisr=round((fdepositoinversion-pinversionexenta)*pporcentajeinversion/gdiasanualesinversion*pdias,2);
		end if;
	end if;

  return fisr;
  
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;