CREATE or replace FUNCTION isrinversionvencimiento(integer) RETURNS numeric
    AS $_$
declare

  pinversionid alias for $1;

  pdias integer;
  fisr numeric;
  pinversionexenta numeric;
  pporcentajeinversion numeric;
  phaberes numeric;
  gdiasanualesinversion int4;

  fdepositoinversion numeric;
  dfechainversion date;
  dfechavencimiento date;
  ftasainteresnormalinversion numeric;
  dfechapagoinversion date;

  iperiodo numeric;
  idias integer;
  pcalculoid int4;
  itiporeinversion integer;

begin

  select depositoinversion,fechainversion,fechavencimiento,tasainteresnormalinversion,ti.calculoid,noderenovaciones,fechapagoinversion
  into fdepositoinversion,dfechainversion,dfechavencimiento,ftasainteresnormalinversion,pcalculoid,itiporeinversion,dfechapagoinversion
  from inversion i, tipoinversion ti where i.inversionid=pinversionid and i.tipoinversionid=ti.tipoinversionid;

    select inversionexenta,porcentajeisrinversion,diasanualesinversion,periodopagoinversion
      into  pinversionexenta,pporcentajeinversion,gdiasanualesinversion,pdias from empresa where empresaid=1;

    pdias :=dfechavencimiento-dfechapagoinversion;

    if fdepositoinversion > pinversionexenta then
      fisr=round((fdepositoinversion-pinversionexenta)*pporcentajeinversion/gdiasanualesinversion*pdias,2);
    else
      fisr=0;
    end if;

  return fisr;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;