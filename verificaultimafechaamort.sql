CREATE OR REPLACE FUNCTION verificaultimafechaamort(iprestamoid integer) RETURNS INTEGER
    AS $$
declare
	--r rverificafecha;
	ftasanormal numeric;
	ftasa_moratoria numeric;
	finteresnormal numeric;
	ultimporte numeric;
	ultamortid integer;
	inumero_de_amor integer;
	penultamortid integer;
	dpenultfecpago date;
	dfechaotorga date;
	dfecha1erpago date;
	dfechavencimiento date;
	dnuevafecvenc date;
	dultfecpago date;
	idias integer;
	sformula text;
	icalculonormalid int4;
	finteres numeric;
	rec record;
begin
		--select su.nombre||' '||su.paterno||' '||su.materno as nombre,s.clavesocioint into r.nombre,r.clavesocioint from socio s,sujeto su where su.sujetoid=s.sujetoid and s.socioid = (select socioid from prestamos where prestamoid=iprestamoid);
		--se obtiene la tasa del credito
		select tasanormal,tasa_moratoria,fecha_otorga,fecha_1er_pago,fecha_vencimiento,calculonormalid,numero_de_amor into ftasanormal,ftasa_moratoria,dfechaotorga,dfecha1erpago,dfechavencimiento,icalculonormalid,inumero_de_amor from prestamos where prestamoid=iprestamoid;
		--se obtiene el id, la fecha y el monto de la ultima amortizacion
		select amortizacionid,fechadepago,importeamortizacion,interesnormal into ultamortid,dultfecpago,ultimporte,finteresnormal from amortizaciones where numamortizacion=(select max(numamortizacion) from amortizaciones where prestamoid=iprestamoid) and prestamoid = iprestamoid;
		--se obtiene el id y la fecha de la penultima amortizacion
		select amortizacionid,fechadepago into penultamortid,dpenultfecpago from amortizaciones where numamortizacion=(select max(numamortizacion)-1 from amortizaciones where prestamoid=iprestamoid) and prestamoid = iprestamoid;
		
		if dfechavencimiento = dultfecpago then
			idias = dfechavencimiento - dfechaotorga;
		else
			idias = dultfecpago - dfechaotorga;
			--Corrige la fecha de vencimiento de acuerdo al la fecha de ultimo pago.
			update prestamos set fecha_vencimiento=dultfecpago where prestamoid=iprestamoid;
		end if;
		
		--se calcula la nueva fecha de la ultima amortizacion y por ende la fecha de vencimiento
		if idias>1080 and inumero_de_amor=36 then 
			dnuevafecvenc = dultfecpago-(idias-1080);
			--valida inhabil
			while exists( select fecha from inabil where fecha=dnuevafecvenc)
			loop
				dnuevafecvenc:=dnuevafecvenc-1;
			end loop;
			
			--se calculan los dias de acuerdo a como quedó la nueva fecha de vencimiento
			idias=dnuevafecvenc-dpenultfecpago;
			
			--valida que no se traslapen las amortizaciones
			if dnuevafecvenc>dpenultfecpago then 
				-- se calcula el nuevo interes en base a  la fecha
				if idias<0 then
					idias := 0;
				end if;
			
				update calculo
				set saldoinsoluto = ultimporte,
					 dias = idias,
					 tasaintnormal = ftasanormal,
					 tasaintmoratorio = ftasa_moratoria
				where calculoid=icalculonormalid;

				SELECT formula into sformula from calculo where calculoid=icalculonormalid;

				for rec in execute
					'SELECT round(' || sformula || ',2) as interes FROM calculo where calculoid='||icalculonormalid
				loop
					--if round(rec.interes,2)-trunc(round(rec.interes,2))>=0.50 then
					--	finteres := round(trunc(rec.interes)+1,2);
					--else
						finteres := trunc(rec.interes,2);
					--end if;
				end loop;			
		
				-- si todo es correcto se upgradea la fecha y el interes de la ultima amortizacion.
				update amortizaciones set fechadepago=dnuevafecvenc,interesnormal=finteres,iva=trunc(finteres*0.16,2),totalpago=trunc(ultimporte+finteres+trunc(finteres*0.16,2),2) where amortizacionid = ultamortid;

				-- se upgradea la fecha de vencimiento del credito
				update prestamos set fecha_vencimiento=dnuevafecvenc where prestamoid = iprestamoid;
			end if;
		end if;
		--return next r;    
	--end loop;
	return 1;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;