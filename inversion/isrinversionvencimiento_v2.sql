CREATE OR REPLACE FUNCTION isrinversionvencimiento(integer) RETURNS numeric
    AS $_$
declare

  pinversionid alias for $1;
  fisrxdia numeric;
  pdias integer;
  fisr numeric;
  pinversionexenta numeric;
  pporcentajeinversion numeric;
  gdiasanualesinversion int4;

  fdepositoinversion numeric;
  dfechainversion date;
  dfechavencimiento date;
  dfechapagoinversion date;

  psocioid integer;
begin
  fisr=0;
  select depositoinversion,fechainversion,fechavencimiento,fechapagoinversion,isrxdia
  into fdepositoinversion,dfechainversion,dfechavencimiento,dfechapagoinversion,fisrxdia
  from inversion i where i.inversionid=pinversionid;

    select inversionexenta,porcentajeisrinversion,diasanualesinversion
      into  pinversionexenta,pporcentajeinversion,gdiasanualesinversion from empresa where empresaid=1;

	pdias :=current_date-dfechapagoinversion;

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