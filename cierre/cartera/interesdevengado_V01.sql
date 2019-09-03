CREATE or replace FUNCTION interesdevengado(integer, date, date, numeric, integer, character) RETURNS numeric
    AS $_$
declare
  pprestamoid alias for $1;
  pfechacorte alias for $2;
  dfecha      alias for $3;
  fsaldoinsoluto alias for $4;
  pdiastraspasovencida alias for $5;
  pmenorvencido alias for $6;

  dfecha_otorga date;
  dfechaf date;
  fmontoprestamo numeric;
  ftasanormal numeric;
  ftasareciprocidad numeric;
  finteres numeric;
  itantos int4;
  idias   int4;
  icalculonormalid int4;

  sformula text;
  rec record;

  saplica char(1);
begin

   select aplicareciprocidad
     into saplica
     from empresa
    where empresaid=1;

   finteres:=0; 

    select p.montoprestamo,p.tasanormal,p.fecha_otorga,tp.tantos,
           p.calculonormalid
      into fmontoprestamo,ftasanormal,dfecha_otorga,itantos,
           icalculonormalid
      from prestamos p, tipoprestamo tp
     where p.prestamoid = pprestamoid and
           tp.tipoprestamoid = p.tipoprestamoid;

--   if saplica='N' then
--      return ftasanormal;
--   end if;

  --raise exception 'Fecha %',dfecha;

  if dfecha<pfechacorte then

    dfechaf := pfechacorte;

    --raise exception 'Fecha Final para calculo de interes %',dfechaf;

    -- Calcular interes devengado hasta la fecha final
     
    if saplica='S' then
      ftasareciprocidad := tasareciprocidad(fmontoprestamo,fsaldoinsoluto,dfecha_otorga,itantos);

      if ftasareciprocidad<ftasanormal then
        ftasanormal := ftasareciprocidad;
      end if;
    --else
    
    end if;

    if pmenorvencido='S' then
      idias := dfechaf - dfecha;
      if idias<1 then
        finteres := 0;
        return finteres;
      end if;
      if idias>pdiastraspasovencida then
        idias := pdiastraspasovencida;
      end if;
    else
      idias := dfechaf - dfecha - pdiastraspasovencida;
      if idias<1 then
        finteres := 0;
        return finteres;
      end if;
    end if;

    --raise notice 'Interes Devengado Saldo Insoluto %   Tasa %  Dias %',fsaldoinsoluto,ftasanormal,idias;

    finteres := fsaldoinsoluto*idias*((ftasanormal/100)/360);
    if round(finteres,2)-trunc(round(finteres,2))>=0.50 then
      finteres := round(trunc(finteres)+1,2);
    else
      finteres := round(trunc(finteres),2);
    end if;


  end if;

return finteres;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;