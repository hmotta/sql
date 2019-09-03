-- Ultima modificacion 2011-07-16 JAVS

CREATE or replace FUNCTION verificaprevencion(integer, character) RETURNS text
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

  -- generadas
  igenerado integer;

  crefprestamo character(18);
  dvenciprestamo date;
  dultiabono date;
  
begin
  tdatosrelevante:='';
  tdatosinusual:='';
  tdatospreocupante:='';

  filtro := 'NORMAL';

  select coalesce(monedavalor,0)*10000, coalesce(monedavalor,0)*3000 into pmontorelevante,pmontoinusual from monedas where monedaid ='DL';

  select socioid,tipomovimientoid,movicajaid,date(fechahora) into isocioid,stipomovimientoid,imovicajaid,dfecha from movicaja where referenciacaja =preferenciacaja and seriecaja=pseriecaja limit 1;

  select sujetoid into isujetoid from socio where socioid=isocioid;
  
  select coalesce(salariomensual,0)*3,coalesce((select tipoderiesgoid from  matrizclientes mc, tipoderiesgo tr where (promedio between nivelderiesgo and nivelderiesgomax) and socioid=isocioid),3),tieneantecedentes into fingresos,itipoderiesgoid,stieneantecedentes from conoceatucliente where sujetoid=isujetoid;

--  raise notice ' antecedentes % %',itipoderiesgoid,stieneantecedentes;
         
--  select current_date into dfecha;

  if stipomovimientoid not in ('RE') then
  
     select coalesce(sum(valor),0) into pdeposito from sabana where referenciacaja =preferenciacaja and seriecaja=pseriecaja and entradasalida=0;

     select coalesce(sum(valor),0) into pinusual from sabana where socioid = isocioid and (fecha between (dfecha-7) and dfecha);

     -- Verificando relevante
     if pdeposito > pmontorelevante then 
       filtro := 'RELEVANTE';
         tdatosrelevante:=' MOV '||stipomovimientoid||' MONTO '||round(pdeposito,0);
     end if;
  
     raise notice ' % % %',pinusual,pmontoinusual,pdeposito;
     -- Verificando Inusual/Preocupante
     if (pinusual > pmontoinusual) and pdeposito>0 then 
       if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
         filtro := 'PREOCUPANTES';
         tdatospreocupante:=tdatospreocupante||' MOV '||stipomovimientoid||' INUSUAL MONTO '||round(pdeposito,0)||' MOVIMIENTOS EN ULTIMA SEMANA '||round(pinusual,0);     
       else
         filtro := 'INUSUAL';
         tdatosinusual:=tdatosinusual||' MOV '||stipomovimientoid||' INUSUAL MONTO '||round(pdeposito,0)||' MOVIMIENTOS EN ULTIMA SEMANA '||round(pinusual,0);
       end if;
     end if;
  
     if pdeposito > fingresos then 
       if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
         filtro := 'PREOCUPANTES';
         tdatospreocupante:=tdatospreocupante||' EL MOVIMIENTO EXCEDE EL TRIPLE DE INGRESOS DEL EMPLEADO';
       else
         filtro := 'INUSUAL';
         tdatosinusual:=tdatosinusual||' EL MOVIMIENTO EXCEDE EL TRIPLE DE INGRESOS DEL SOCIO';
       end if;	 
     end if;

     -- Identificar a una persona con antecedentes
  
     if stieneantecedentes='S' then 
       if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
         filtro := 'PREOCUPANTES';
         tdatospreocupante:=tdatospreocupante||' PERSONA CON ANTECEDENTES PENALES';
       else
         filtro := 'INUSUAL';
         tdatosinusual:=tdatosinusual||' PERSONA CON ANTECEDENTES PENALES';
       end if;
     end if;
     -- Identificar a una persona con riesgo alto

     if itipoderiesgoid=1 then 
       if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
         filtro := 'PREOCUPANTES';
         tdatospreocupante:=tdatospreocupante||' PERSONA CON RIESGO ALTO';
       else
         filtro := 'INUSUAL';
         tdatosinusual:=tdatosinusual||' PERSONA CON RIESGO ALTO';
       end if;
     end if;


--raise notice 'Liquidacion previa';
     -- Liquidacion previa de credito
     if stipomovimientoid='00' then
       select p.prestamoid,cuentaactivo,p.montoprestamo,p.referenciaprestamo,fecha_vencimiento,fechaultimopago into iprestamoid,ccuentaactivo,fmontoprestamo,crefprestamo,dvenciprestamo,dultiabono from prestamos p, tipoprestamo tp where tp.tipoprestamoid=p.tipoprestamoid and prestamoid =(select prestamoid from movicaja where referenciacaja=preferenciacaja and seriecaja=pseriecaja and tipomovimientoid='00' limit 1);

       if ((coalesce((select sum(haber) from movipolizas where polizaid in(select polizaid from movicaja where prestamoid=iprestamoid and tipomovimientoid='00') and cuentaid=ccuentaactivo),0))=fmontoprestamo) and (dvenciprestamo>dultiabono) then
       if isocioid in (select socioid from socio where clavesocioint in (select clavesocioint from parametros where (trim(clavesocioint)<>'') and clavesocioint is not null)) then  
           filtro := 'PREOCUPANTES';
           tdatospreocupante:=tdatospreocupante||' LIQUIDACION ANTICIPADA DE CREDITO REF '||crefprestamo||' MONTO CREDITO '||round(fmontoprestamo,0)||' VENCIMIENTO '||dvenciprestamo ||' LIQUIDA '||dultiabono;
         else
           filtro := 'INUSUAL';
           tdatosinusual:=tdatosinusual||' LIQUIDACION ANTICIPADA DE CREDITO REF '||crefprestamo||' MONTO CREDITO '||round(fmontoprestamo,0)||' VENCIMIENTO '||dvenciprestamo ||' LIQUIDA '||dultiabono;
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

	-- Generando Operaciones
	--select * from spioperacionlavado(tipooperacionid,tiporegistro,movicajaid,observacionid,sujetoid,descripcionoperacion)

        if trim(coalesce(tdatosrelevante,''))<>'' then    
	  select * into igenerado from spioperacionlavado(1,0,imovicajaid,0,0,tdatosrelevante);
	  raise notice 'Operacion Relevante generada: %',igenerado;
	end if;

        if trim(coalesce(tdatosinusual,''))<>'' then    
	  select * into igenerado from spioperacionlavado(2,1,imovicajaid,0,0,tdatosinusual);
	  raise notice 'Operacion Inusual generada: %',igenerado;
	end if;

        if trim(coalesce(tdatospreocupante,''))<>'' then    
	  select * into igenerado from spioperacionlavado(3,1,imovicajaid,0,0,tdatospreocupante);
	  raise notice 'Operacion Preocupante generada: %',igenerado;
	end if;
  end if;    
 
     
return filtro;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;