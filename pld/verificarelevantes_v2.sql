CREATE or replace FUNCTION verificarelevantes(integer,date,date) RETURNS text
    AS $_$
declare
	isocioid alias for $1;
	fechai alias for $2;
	fechaf alias for $3;
	filtro text;
	pmontorelevante numeric;
	pmontoinusual numeric;
	pdeposito numeric;
	pinusual numeric;
	isujetoid integer;
	dfecha date;
	stipomovimientoid char(2);
	--pretiroanterior numeric;
	--pretiroposterior numeric;
	
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

		select coalesce(salariomensual,0)*3,coalesce((select max(tipoderiesgoid) from  matrizclientes mc, tipoderiesgo tr where (promedio between nivelderiesgo and nivelderiesgomax) and socioid=isocioid),3),tieneantecedentes into fingresos,itipoderiesgoid,stieneantecedentes from conoceatucliente where sujetoid=isujetoid;
		--  raise notice ' antecedentes % %',itipoderiesgoid,stieneantecedentes;
		--  select current_date into dfecha;
		if stipomovimientoid not in ('RE') then
			--select coalesce(sum(valor),0) into pdeposito from sabana s, movicaja mc where mc.referenciacaja =preferenciacaja and seriecaja=pseriecaja and entradasalida=0 and efectivo in (1,4); ANTERIOR
			select max(mp.debe) into pdeposito from movicaja mc,movipolizas mp, polizas po where po.polizaid=mc.polizaid and mc.movipolizaid=mp.movipolizaid and fechapoliza between fechai and fechaf and tipomovimientoid not in ('CH','RE','AG','LE','BU','SM','SI','SQ','SB','ST','TC','MV','IU','OP','MC','CM','SK','CF','TU','ET','ID') and seriepoliza not in ('ZA','WW','Z') and efectivo=1 and socioid=isocioid;
			--select coalesce(sum(valor),0) into pretiroanterior from sabana where referenciacaja = (preferenciacaja-1) and seriecaja=pseriecaja and entradasalida=1 and socioid=isocioid;
			--select coalesce(sum(valor),0) into pretiroposterior from sabana where referenciacaja = (preferenciacaja+1) and seriecaja=pseriecaja and entradasalida=1 and socioid=isocioid;
			
			--select coalesce(max(montoprestamo),0) into nretiroprestamo from prestamos where claveestadocredito<>'008' and fecha_otorga=dfecha and socioid=isocioid and tipoprestamoid not in ('P4') and prestamoid in ((select distinct(prestamoid) from movibanco  natural join polizas where prestamoid is not null  and fechapoliza=dfecha) union (select distinct(prestamoid) from movicaja where estatusmovicaja='A' and tipomovimientoid='RM' and prestamoid is not null and date(fechahora)=dfecha));
			
			--select coalesce(max(retiroinversion),0) into nretiroinversion  from inversion where fechapagoinversion=dfecha and socioid=isocioid and retiroinversion>0 and inversionid in(select inversionid from movicaja where inversionid is not null and estatusmovicaja='A' and date(fechahora)=dfecha);
			
			--select coalesce(sum(valor),0) into pinusual from sabana where socioid = isocioid and (fecha between (dfecha-7) and dfecha);
			-- Verificando relevante
			--raise notice 'pdeposito=%',pdeposito;
			--raise notice 'pmontorelevante=%',pmontorelevante;
			--raise notice 'pretiroanterior=%',pretiroanterior;
			--raise notice 'pretiroposterior=%',pretiroposterior;
			--raise notice 'nretiroprestamo=%',nretiroprestamo;
			--raise notice 'nretiroinversion=%',nretiroinversion;
			if pdeposito > pmontorelevante  then 
				filtro := 'RELEVANTE';
				tdatosrelevante:=' MOV '||stipomovimientoid||' MONTO '||round(pdeposito,0);
				raise notice 'OPERACION RELEVANTE % % % %',imovicajaid,stipomovimientoid,dfecha,pdeposito;
			end if;
			
			
			-- Generando Operaciones
			--select * from spioperacionlavado(tipooperacionid,tiporegistro,movicajaid,observacionid,sujetoid,descripcionoperacion)

			if trim(coalesce(tdatosrelevante,''))<>'' then    
				select * into igenerado from spioperacionlavado(1,0,imovicajaid,0,0,tdatosrelevante);
				--raise notice 'Operacion Relevante generada: %',igenerado;
			end if;

		
		end if;    

		return filtro;
	end
$_$
LANGUAGE plpgsql SECURITY DEFINER;

