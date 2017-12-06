sCREATE or replace FUNCTION interesdevengado(integer, date, integer, integer, date, numeric, integer, character) RETURNS numeric
    AS $_$
declare
  pprestamoid alias for $1;
  pfechacorte alias for $2;
  pdiasvencidos alias for $3;
  pdiascapital alias for $4;
  dfecha      alias for $5;
  fsaldoinsoluto alias for $6;
  pdiastraspasovencida alias for $7;
  pmenorvencido alias for $8;

  dfecha_otorga date;
  dfechaf date;
  fmontoprestamo numeric;
  ftasanormal numeric;
  ftasareciprocidad numeric;
  finteres numeric;

  itantos int4;
  idias   int4;
  idiasinteres   int4;
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

	idiasinteres := dfechaf - dfecha; --Primero se calculan los dias de interes que adeuda, es decir la fechaactual - la fecha de ultimo pago de interes
	--se calcula el interes menor a vencido
    if pmenorvencido='S' then  
		  if idiasinteres<1 then --si no hay dias de interes se regresa 0 y se termina el proceso
			finteres := 0;
			return finteres;
		  end if;
		  
		  if pdiasvencidos>pdiastraspasovencida then --si es un credito vencido 
			if idiasinteres > pdiasvencidos then  --se verifica si el credito tiene pagos adelantados, si tiene pagos adelantados es decir los dias de interes son mayores a los dias vencidos 
				idias = (idiasinteres - pdiascapital) + pdiastraspasovencida;
			else
				idias := pdiastraspasovencida;
			end if;
		  else
			idias := idiasinteres;
		  end if;
	--se calcula el interes mayor a vencido
    else 
		  if idiasinteres > pdiasvencidos then
				idias = idiasinteres - ( (idiasinteres - pdiascapital) + pdiastraspasovencida );
				--reduciendo la formula anterior
				--idias = pdiascapital - pdiastraspasovencida ;
		  else
				idias = idiasinteres - pdiastraspasovencida;
		  end if;
		  
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