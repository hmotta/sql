CREATE or replace FUNCTION isrinversionmes(integer) RETURNS numeric
    AS $_$
declare

  pinversionid alias for $1;

  pdias integer;
  fisr numeric;
  fisrxdia numeric;
  pinversionexenta numeric;
  pporcentajeinversion numeric;
  gdiasanualesinversion int4;

  fdepositoinversion numeric;
  dfechainversion date;
  dfechavencimiento date;
  dfechapagoinversion date;

  itiporeinversion integer;

begin
  fisr=0;
  select noderenovaciones into itiporeinversion from inversion i where i.inversionid=pinversionid;
	
 if itiporeinversion = 3 then 
		select depositoinversion,fechainversion,fechavencimiento,fechapagoinversion,isrxdia
		into fdepositoinversion,dfechainversion,dfechavencimiento,dfechapagoinversion,fisrxdia
		from inversion i where i.inversionid=pinversionid;
  
		select inversionexenta,porcentajeisrinversion,diasanualesinversion,periodopagoinversion
		  into  pinversionexenta,pporcentajeinversion,gdiasanualesinversion,pdias from empresa where empresaid=1;

		dfechapagoinversion:=coalesce(dfechapagoinversion,dfechainversion);
		pdias :=current_date - dfechapagoinversion;
	if dfechainversion>='2016-01-11' then --el calculo del ISR cambia para inversiones del 2016
		fisr=round(fisrxdia*pdias,2);
	else
		if fdepositoinversion > pinversionexenta then
		  fisr=round((fdepositoinversion-pinversionexenta)*pporcentajeinversion/gdiasanualesinversion*pdias,2);
		end if;
	end if;
end if;

  return fisr;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;