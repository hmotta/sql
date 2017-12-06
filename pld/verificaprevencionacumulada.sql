CREATE or replace FUNCTION verificaprevencionacumulada(integer, character) RETURNS text
    AS $_$
declare
	preferenciacaja alias for $1;
	pseriecaja alias for $2;
	filtro text;
	pmontorelevante numeric;
	pmontoinusual numeric;
	pdeposito numeric;
	pinusual numeric;
	isocioid integer;
	isujetoid integer;
	dfecha date;
	stipomovimientoid char(2);
	pretiroanterior numeric;
	pretiroposterior numeric;
	
	nretiroprestamo numeric;
	nretiroinversion numeric;
	
	-- Variables de conoce a tu cliente
	fingresos numeric;  
	itipoderiesgoid integer;
	stieneantecedentes character(1);

	tobsermov text;
	-- datos observaciones
	tdatosrelevante text;
	tdatosinusual text;
	tdatospreocupante text;

	imovicajaid integer;

	--liquidaprevia
	iprestamoid integer;
	ccuentaactivo character(24);
	fmontoprestamo numeric;
	idias int;
	fpagocapital  numeric;

	-- generadas
	igenerado integer;

	crefprestamo character(18);
	dvenciprestamo date;
	dultiabono date;
	dotorga date;
	dfechamedioplazo date;
	begin
		tdatosrelevante:='';
		tdatosinusual:='';
		tdatospreocupante:='';
		filtro := 'NORMAL';
		--select coalesce(monedavalor,0)*10000, coalesce(monedavalor,0)*5000 into pmontorelevante,pmontoinusual from monedas where monedaid ='DL';
		select coalesce(monedavalor,0)*10000, coalesce(monedavalor,0)*5000 into pmontorelevante,pmontoinusual from monedas where monedaid ='DL';
		select socioid,tipomovimientoid,movicajaid,date(fechahora) into isocioid,stipomovimientoid,imovicajaid,dfecha from movicaja where referenciacaja =preferenciacaja and seriecaja=pseriecaja limit 1;
		select sujetoid into isujetoid from socio where socioid=isocioid;

		select coalesce(salariomensual,0)*3,coalesce((select max(tipoderiesgoid) from  matrizclientes mc, tipoderiesgo tr where (promedio between nivelderiesgo and nivelderiesgomax) and socioid=isocioid),3),tieneantecedentes into fingresos,itipoderiesgoid,stieneantecedentes from conoceatucliente where sujetoid=isujetoid;
		--  raise notice ' antecedentes % %',itipoderiesgoid,stieneantecedentes;
		--  select current_date into dfecha;
		if stipomovimientoid not in ('RE') then
			select coalesce(sum(valor),0) into pdeposito from sabana where referenciacaja =preferenciacaja and seriecaja=pseriecaja and entradasalida=0;
			select coalesce(sum(valor),0) into pretiroanterior from sabana where referenciacaja = (preferenciacaja-1) and seriecaja=pseriecaja and entradasalida=1 and socioid=isocioid;
			select coalesce(sum(valor),0) into pretiroposterior from sabana where referenciacaja = (preferenciacaja+1) and seriecaja=pseriecaja and entradasalida=1 and socioid=isocioid;
			
			select coalesce(max(montoprestamo),0) into nretiroprestamo from prestamos where claveestadocredito<>'008' and fecha_otorga=dfecha and socioid=isocioid and tipoprestamoid not in ('P4') and prestamoid in ((select distinct(prestamoid) from movibanco  natural join polizas where prestamoid is not null  and fechapoliza=dfecha) union (select distinct(prestamoid) from movicaja where estatusmovicaja='A' and tipomovimientoid='RM' and prestamoid is not null and date(fechahora)=dfecha));
			
			select coalesce(max(retiroinversion),0) into nretiroinversion  from inversion where fechapagoinversion=dfecha and socioid=isocioid and retiroinversion>0 and inversionid in(select inversionid from movicaja where inversionid is not null and estatusmovicaja='A' and date(fechahora)=dfecha);
			
			--select coalesce(sum(valor),0) into pinusual from sabana where socioid = isocioid and (fecha between (dfecha-7) and dfecha);
			-- Verificando relevante
			--raise notice 'pdeposito=%',pdeposito;
			--raise notice 'pmontorelevante=%',pmontorelevante;
			--raise notice 'pretiroanterior=%',pretiroanterior;
			--raise notice 'pretiroposterior=%',pretiroposterior;
			--raise notice 'nretiroprestamo=%',nretiroprestamo;
			--raise notice 'nretiroinversion=%',nretiroinversion;
			if pdeposito > pmontorelevante and pdeposito>pretiroanterior and pdeposito>pretiroposterior and (pdeposito<(0.95*nretiroprestamo) or (pdeposito>nretiroprestamo)) and pdeposito<>nretiroinversion then 
				filtro := 'RELEVANTE';
				tdatosrelevante:=' MOV '||stipomovimientoid||' MONTO '||round(pdeposito,0);
			end if;
			--raise notice ' % % %',pinusual,pmontoinusual,pdeposito;
			-- Verificando Inusual/Preocupante
			if (pdeposito >= pmontoinusual) and pdeposito>0 and pdeposito>pretiroanterior and pdeposito>pretiroposterior and (pdeposito<(0.95*nretiroprestamo) or (pdeposito>nretiroprestamo)) and pdeposito<>nretiroinversion then 
				if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then
					filtro := 'PREOCUPANTES';
					tdatospreocupante:=tdatospreocupante||' MOV '||stipomovimientoid||' INUSUAL MONTO '||round(pdeposito,0);     
				else
					filtro := 'INUSUAL';
					tdatosinusual:=tdatosinusual||' MOV '||stipomovimientoid||' INUSUAL MONTO '||round(pdeposito,0);
				end if;
			end if;

			if pdeposito > fingresos and pdeposito>pretiroanterior and pdeposito>pretiroposterior and (fingresos - (fingresos*2))>10000 then 
				if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
					filtro := 'PREOCUPANTES';
					tdatospreocupante:=tdatospreocupante||'; EL MOVIMIENTO EXCEDE EL TRIPLE DE INGRESOS DEL EMPLEADO';
				else
					filtro := 'INUSUAL';
					tdatosinusual:=tdatosinusual||'; EL MOVIMIENTO EXCEDE EL TRIPLE DE INGRESOS DEL SOCIO';
				end if;	 
			end if;

			-- Identificar a una persona con antecedentes

			if stieneantecedentes='S' then 
				if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
					filtro := 'PREOCUPANTES';
					tdatospreocupante:=tdatospreocupante||'; PERSONA CON ANTECEDENTES PENALES';
				else
					filtro := 'INUSUAL';
					tdatosinusual:=tdatosinusual||'; PERSONA CON ANTECEDENTES PENALES';
				end if;
			end if;
			-- Identificar a una persona con riesgo alto

			if itipoderiesgoid=1 then 
				if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
					filtro := 'PREOCUPANTES';
					tdatospreocupante:=tdatospreocupante||'; PERSONA CON RIESGO ALTO';
				else
					filtro := 'INUSUAL';
					tdatosinusual:=tdatosinusual||'; PERSONA CON RIESGO ALTO';
				end if;
			end if;



			--raise notice 'Creditos';

			if stipomovimientoid='00' then
				select p.prestamoid,cuentaactivo,p.montoprestamo,p.referenciaprestamo,fecha_vencimiento,fechaultimopago,fecha_otorga into iprestamoid,ccuentaactivo,fmontoprestamo,crefprestamo,dvenciprestamo,dultiabono,dotorga from prestamos p, tipoprestamo tp where tp.tipoprestamoid=p.tipoprestamoid and prestamoid =(select prestamoid from movicaja where referenciacaja=preferenciacaja and seriecaja=pseriecaja and tipomovimientoid='00' limit 1);
				--raise notice  'prestamoid=%',iprestamoid;

				-- Identificar una persona con mas de 4 creditos en el año
				if fmontoprestamo>=25000.00 then
					if ( coalesce((select count(*) from prestamos where claveestadocredito='002' and  tipoprestamoid not in ('P4') and socioid=isocioid and montoprestamo>=25000 and fecha_otorga  between date_part('year',current_date)||'-01-01' and current_date ),0))>=4 and (select count(*) from operacionlavado where sujetoid=isujetoid)=0 then
						if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
							filtro := 'PREOCUPANTES';
							tdatospreocupante:=tdatospreocupante||'; PERSONA CON 4 CREDITOS O MAS EN EL ANIO';
						else
							filtro := 'INUSUAL';
							tdatosinusual:=tdatosinusual||'; PERSONA CON 4 CREDITOS O MAS EN EL ANIO';
						end if;
					end if;
				end if;
				
				if dultiabono=dfecha or fmontoprestamo>=50000.00 then
					select coalesce(sum(haber),0) into fpagocapital from movipolizas where polizaid in (select polizaid from movicaja where referenciacaja=preferenciacaja and tipomovimientoid='00') and cuentaid=ccuentaactivo;
				end if;
				
				-- Liquidacion previa (a medio plazo) de credito
				if dultiabono=dfecha then
					idias:=(dvenciprestamo-dotorga)/2;
					--raise notice  'idias=%',idias;
					dfechamedioplazo:= dotorga + idias+1;
					--raise notice  'dfechamedioplazo=%',dfechamedioplazo;
					if ((coalesce((select sum(haber) from movipolizas where polizaid in(select polizaid from movicaja where prestamoid=iprestamoid and tipomovimientoid='00') and cuentaid=ccuentaactivo),0))=fmontoprestamo) and (dfechamedioplazo>=dultiabono) and fpagocapital>=50000.00 then
						if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
							filtro := 'PREOCUPANTES';
							tdatospreocupante:=tdatospreocupante||'; LIQUIDACION ANTICIPADA DE CREDITO REF '||crefprestamo||' MONTO CREDITO '||round(fmontoprestamo,0)||' VENCIMIENTO '||dvenciprestamo ||' LIQUIDA '||dultiabono||' PAGO A CAPITAL '||fpagocapital;
						else
							filtro := 'INUSUAL';
							tdatosinusual:=tdatosinusual||'; LIQUIDACION ANTICIPADA DE CREDITO REF '||crefprestamo||' MONTO CREDITO '||round(fmontoprestamo,0)||' VENCIMIENTO '||dvenciprestamo ||' LIQUIDA '||dultiabono||' PAGO A CAPITAL '||fpagocapital;
						end if;
					end if;
				end if;

				if fmontoprestamo>=50000.00 then
					-- Pago del 80% del credito en una exhibición para montos mayores o iguales a 50,000.00
					if (fpagocapital>=(fmontoprestamo*0.80))  then
						if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
							filtro := 'PREOCUPANTES';
							tdatospreocupante:=tdatospreocupante||'; PAGO EN UNA EXHIBICION DEL 80 POR CIENTO DEL CREDITO REF '||crefprestamo||' MONTO CREDITO '||round(fmontoprestamo,0)||' PAGO A CAPITAL '||fpagocapital;
						else
							filtro := 'INUSUAL';
							tdatosinusual:=tdatosinusual||'; PAGO EN UNA EXHIBICION DEL 80 POR CIENTO DEL CREDITO REF '||crefprestamo||' MONTO CREDITO '||round(fmontoprestamo,0)||' PAGO A CAPITAL '||fpagocapital;
						end if;
					end if;
				end if;

				--raise notice 'termina Liquidacion previa';

				select observaciones into tobsermov from perfiltransaccional where perfiltransaccionalid=(select max(perfiltransaccionalid) from perfiltransaccional where socioid=isocioid and referencia=preferenciacaja and serie=pseriecaja);
				tobsermov:=coalesce(trim(tobsermov),'');
				if (trim(tobsermov))<>'' then
					if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
						filtro := 'PREOCUPANTES';
						tdatospreocupante:=tdatospreocupante||' '||trim(tobsermov);
					else
						filtro := 'INUSUAL';
						tdatosinusual:=tdatosinusual||' '||trim(tobsermov);
					end if;
				end if;
			end if;
			-- Generando Operaciones
			--select * from spioperacionlavado(tipooperacionid,tiporegistro,movicajaid,observacionid,sujetoid,descripcionoperacion)

			if trim(coalesce(tdatosrelevante,''))<>'' then    
				select * into igenerado from spioperacionlavado(1,0,imovicajaid,0,0,tdatosrelevante);
				--raise notice 'Operacion Relevante generada: %',igenerado;
			end if;

			if trim(coalesce(tdatosinusual,''))<>'' then    
				select * into igenerado from spioperacionlavado(2,1,imovicajaid,0,0,tdatosinusual);
				--raise notice 'Operacion Inusual generada: %',igenerado;
			end if;

			if trim(coalesce(tdatospreocupante,''))<>'' then    
				select * into igenerado from spioperacionlavado(3,1,imovicajaid,0,0,tdatospreocupante);
				--raise notice 'Operacion Preocupante generada: %',igenerado;
			end if;
		end if;    

		return filtro;
	end
$_$
LANGUAGE plpgsql SECURITY DEFINER;

