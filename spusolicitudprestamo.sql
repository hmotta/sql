CREATE OR REPLACE FUNCTION spusolicitudprestamo(integer, integer, integer, character, character, character, integer, integer, date, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, integer, numeric, integer, numeric, numeric, date, date, character varying, date, integer, integer, character) RETURNS integer
    AS $_$
declare
  
  psolicitudprestamoid alias for $1;
  psocioid alias for $2;
  psujetoid alias for $3;
  ptipoprestamoid alias for $4;
  pclavefinalidad alias for $5;
  pclavegarantia alias for $6;
  pdomicilioid alias for $7;
  pnosolicitud alias for $8;
  pfechasolicitud alias for $9;
  psueldo alias for $10;
  psueldoconyuge alias for $11;
  potrosingresos alias for $12;
  ptotalingresos alias for $13;
  pgastosordinarios alias for $14;
  potrosgastos alias for $15;
  potrosabonos alias for $16;
  ptotalegresos alias for $17;
  pcapacidadpago alias for $18;
  pvalorpropiedades alias for $19;
  ptotaldeudas alias for $20;
  pabonospropuestos alias for $21;
  pmontosolicitado alias for $22;
  pperiodopagoid alias for $23;
  ptasanormal alias for $24;
  ptasamoratorio alias for $25;
  pfecharesultado alias for $26;
  pfechaentrega alias for $27;
  pactano alias for $28;
  pfechacomite alias for $29;
  presolucionid alias for $30;
  pentregado alias for $31;
  pusuarioid alias for $32;
--  plastusuarioid alias for $33;
--  plastupdate alias for $34;
--  pprimerpago alias for $35;
--  pempresatrabaja alias for $36;
--  pjefedirecto alias for $37;
--  pverificado alias for $38;
--  pobsinvestigaion alias for $39;
--  pobservaciones alias for $40;

  ptasanormal1 numeric;
  ptasamoratorio1 numeric;

begin

  raise notice ' 1 % % ',ptasanormal1,ptasamoratorio1;


  if   ptotalingresos <=  ptotalegresos then 
    raise exception 'Los egresos son mayores a los ingresos.';
  end if;

  if exists (select prestamoid from prestamos where solicitudprestamoid=psolicitudprestamoid) then
      raise exception 'No se pueden modificar solicitudes ya autorizadas !';
  end if;
	
	------- >> Validar la finalidad del prestamo acorde con el tipo de producto [consumo, comercial, vivienda]
   if pclavefinalidad='001' then--Comercial
		if ptipoprestamoid not in ('R1','C1','C4','C9','T1') then
			raise exception 'Este tipo de credito no puede ser Comercial';
		end if;
   elseif pclavefinalidad='002' then--Consumo
		if ptipoprestamoid not in ('CAS','P4','N8','N20','R2','T2','N1','N4','N15','N21','N9','N16','P1','N13','N14','N7','N22','N5','N53','N54','CF') then
			raise exception 'Este tipo de credito no puede ser al Consumo';
		end if;
   else --vivienda
			raise exception 'Este tipo de credito no puede a la Vivienda';
   end if;
   ------- <<
   

  select tasanormal,tasamoratoria into ptasanormal1,ptasamoratorio1 from spstasastipoprestamo(ptipoprestamoid,pmontosolicitado,psocioid,' ');

  ptasanormal1:=coalesce(ptasanormal1,ptasanormal);
  ptasamoratorio1:=coalesce(ptasamoratorio1,ptasamoratorio);

  raise notice ' 2 % % ',ptasanormal1,ptasamoratorio1;


  update solicitudprestamo
     set socioid=psocioid,            
      sujetoid=psujetoid,           
      tipoprestamoid=ptipoprestamoid,     
      clavefinalidad=pclavefinalidad,     
      clavegarantia=pclavegarantia,      
      domicilioid=pdomicilioid,        
--      nosolicitud=pnosolicitud,        
      fechasolicitud=pfechasolicitud,     
      sueldo=psueldo,             
      sueldoconyuge=psueldoconyuge,      
      otrosingresos=potrosingresos,      
      totalingresos=ptotalingresos,      
      gastosordinarios=pgastosordinarios,   
      otrosgastos=potrosgastos,        
      otrosabonos=potrosabonos,        
      totalegresos=ptotalegresos,       
      capacidadpago=pcapacidadpago,      
      valorpropiedades=pvalorpropiedades,   
      totaldeudas=ptotaldeudas,        
      abonospropuestos=pabonospropuestos,   
      montosolicitado=pmontosolicitado,    
      periodopagoid=pperiodopagoid,      
      tasanormal=ptasanormal,         
      tasamoratorio=ptasamoratorio,      
      fecharesultado=pfecharesultado,     
      fechaentrega=pfechaentrega,       
      actano=pactano,             
      fechacomite=pfechacomite,        
      resolucionid=presolucionid,       
      entregado=pentregado,          
      usuarioid=pusuarioid,
      lastusuarioid=pusuarioid
--      lastusuarioid=plastusuarioid,      
--      lastupdate=plastupdate,         
--      primerpago=pprimerpago,         
--      empresatrabaja=pempresatrabaja,     
--      jefedirecto=pjefedirecto,        
--      verificado=pverificado,         
--      obsinvestigacion=pobsinvestigacion,   
--      observaciones=pobservaciones
  where solicitudprestamoid=psolicitudprestamoid;


return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;