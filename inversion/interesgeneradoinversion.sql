CREATE or replace FUNCTION interesgeneradoinversion(integer) RETURNS numeric
    AS $_$
declare
  pinversionid alias for $1;

  rec record;
  fdepositoinversion numeric;
  dfechainversion date;
  dfechavencimiento date;
  ftasainteresnormalinversion numeric;
  dfechapagoinversion date;

  iperiodo numeric;
  pdias integer;
  idias integer;

  finteres numeric;
  pcalculoid int4;
  sformula text;
  itiporeinversion integer;

begin

  finteres:=0;

  select depositoinversion,fechainversion,fechavencimiento,tasainteresnormalinversion,ti.calculoid,noderenovaciones,fechapagoinversion
  into fdepositoinversion,dfechainversion,dfechavencimiento,ftasainteresnormalinversion,pcalculoid,itiporeinversion,dfechapagoinversion
  from inversion i, tipoinversion ti where i.inversionid=pinversionid and i.tipoinversionid=ti.tipoinversionid; 

 select periodopagoinversion into pdias from empresa where empresaid=1;

  if itiporeinversion = 3 then

    idias :=current_date-dfechapagoinversion;
   
    raise notice ' Dias %  Periodo % ',idias,iperiodo;
   
   update calculo
    set saldoinsoluto = fdepositoinversion,
      dias = idias,
      tasaintnormal = ftasainteresnormalinversion
    where calculoid = pcalculoid;

    SELECT formula into sformula from calculo where calculoid=pcalculoid;

    for rec in execute
        'SELECT ' || sformula || ' as interes FROM calculo where calculoid='||pcalculoid
     loop
        finteres := round(rec.interes,2);
     end loop;

  else
    finteres:=0;
  end if;

  return finteres;
  
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;