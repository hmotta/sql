CREATE or replace FUNCTION interesdevengado(integer, date, integer, integer, date, numeric, integer, character) RETURNS numeric
    AS $_$
declare
  pprestamoid alias for $1;
  pfechacorte alias for $2;
  pdiasvencidos alias for $3;
  pdiascapital alias for $4;
  dultimo_abono_int      alias for $5;
  fsaldoinsoluto alias for $6;
  pdiastraspasovencida alias for $7;
  pmenorvencido alias for $8;

  dfecha_otorga date;
  dfechaf date;
  dfechai date;
  fmontoprestamo numeric;
  ftasanormal numeric;
  ftasareciprocidad numeric;
  finteres numeric;

  itantos int4;
  idias   int4;
  idiasinteres   int4;
  icalculonormalid int4;
  nrevolvente integer;

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
		p.calculonormalid,tp.revolvente
		into fmontoprestamo,ftasanormal,dfecha_otorga,itantos,
		icalculonormalid,nrevolvente
	from prestamos p, tipoprestamo tp
	where p.prestamoid = pprestamoid and
		tp.tipoprestamoid = p.tipoprestamoid;

	--   if saplica='N' then
	--      return ftasanormal;
	--   end if;
	--raise exception 'Fecha %',dultimo_abono_int;
	if nrevolvente=0 then
		if dultimo_abono_int<pfechacorte then
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

			idiasinteres := dfechaf - dultimo_abono_int; --Primero se calculan los dias de interes que adeuda, es decir la fechaactual - la fecha de ultimo pago de interes
			--se calcula el interes menor a vencido
			if pmenorvencido='S' then   --Interes en cuentas de balance
				if idiasinteres<1 then --si no hay dias de interes se regresa 0 y se termina el proceso
					finteres := 0;
					return finteres;
				end if;

				if pdiasvencidos>pdiastraspasovencida then --si es un credito vencido 
					if idiasinteres > pdiasvencidos then  --se verifica si el credito tiene pagos adelantados, si tiene pagos adelantados es decir los dias de interes son mayores a los dias vencidos 
						idias := (idiasinteres - pdiascapital) + pdiastraspasovencida;
					else
						if idiasinteres<pdiastraspasovencida then --Esta vencido pero tuvo un pago reciente de interes
							idias := idiasinteres;
						else
							idias := pdiastraspasovencida;
						end if;
					end if;
				else
					idias := idiasinteres;
				end if;
				--se calcula el interes mayor a vencido
			else  --Interes en cuentas de orden
				if idiasinteres > pdiasvencidos then --si tiene pagos adelantados
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
			finteres := round(finteres,2);
			--if round(finteres,2)-trunc(round(finteres,2))>=0.50 then
			--finteres := round(trunc(finteres)+1,2);
			--else
			--finteres := round(trunc(finteres),2);
			--end if;
		end if;
	else
		perform genera_interes_diario_linea(pprestamoid,pfechacorte);
		if dias_interes_linea(pprestamoid,pfechacorte) > 0 then
			select max(fecha_pago) into dfechai from credito_linea_interes_devengado where lineaid=pprestamoid and (interes_diario-interes_pagado)=0;
			if dfechai is null then
				select min(fecha) into dfechai from credito_linea_interes_devengado where lineaid=pprestamoid and (interes_diario-interes_pagado)>0;
			end if;
			dfechaf:=dfechai+pdiastraspasovencida;
			raise notice 'dfechaf=%',dfechaf;
			raise notice 'dfechai=%',dfechai;
			if pmenorvencido='S' then
				if pdiasvencidos>pdiastraspasovencida then --si es un credito vencido 
					select sum(interes_diario) into finteres from credito_linea_interes_devengado where fecha between dfechai and dfechaf ;
				else
					finteres:=calcula_int_ord_linea(pprestamoid,pfechacorte);
				end if;
			else
				if pdiasvencidos>pdiastraspasovencida then --si es un credito vencido 
					select sum(interes_diario) into finteres from credito_linea_interes_devengado where fecha > dfechaf ;
				else
					finteres:=0;
				end if;
			end if;
			finteres:=coalesce(finteres,0);
		else
			finteres:=0;
		end if;
	end if;
return finteres;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;