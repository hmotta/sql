CREATE FUNCTION spisolicitudprestamo(integer, integer, integer, character, character, character, integer, integer, date, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, integer, numeric, integer, numeric, numeric, date, date, character varying, date, integer, integer, character) RETURNS integer
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

  ptasanormal1 numeric;
  ptasamoratorio1 numeric;


begin


  select tasanormal,tasamoratoria into ptasanormal1,ptasamoratorio1 from spstasastipoprestamo(ptipoprestamoid,pmontosolicitado,psocioid,' ');

  ptasanormal1:=coalesce(ptasanormal1,ptasanormal);
  ptasamoratorio1:=coalesce(ptasamoratorio1,ptasamoratorio);


  if pabonospropuestos=1 and ptipoprestamoid <> 'P1' and ptipoprestamoid <> 'P4' and ptipoprestamoid <>'N16' then
      raise exception 'El tipo P1 es el unico que puede ser de 1 amortizacion!';
  end if;

  if ptotalingresos <=  ptotalegresos then 
     raise exception 'Los egresos son mayores o iguales  a los ingresos.';
  end if;

  ------- >> Validar la finalidad del prestamo acorde con el tipo de producto [consumo, comercial, vivienda]
   if pclavefinalidad='001' then--Comercial
		if ptipoprestamoid not in ('R1','C1','C4','C9','T1') then
			raise exception 'Este tipo de credito no puede ser Comercial';
		end if;
   elseif pclavefinalidad='002' then--Consumo
		if ptipoprestamoid not in ('CAS','P4','N8','N20','R2','T2','N1','N4','N15','N21','N9','N16','P1','N13','N14','N7','N22','N5','N53','N54','CF') then
			raise exception 'Este tipo de credito no puede Consumo';
		end if;
   else --vivienda
			raise exception 'Este tipo de credito no puede a la Vivienda';
   end if;
   ------- <<
  insert into
    solicitudprestamo(
      socioid,            
      sujetoid,           
      tipoprestamoid,     
      clavefinalidad,     
      clavegarantia,      
      domicilioid,        
      nosolicitud,        
      fechasolicitud,     
      sueldo,             
      sueldoconyuge,      
      otrosingresos,      
      totalingresos,      
      gastosordinarios,   
      otrosgastos,        
      otrosabonos,        
      totalegresos,       
      capacidadpago,      
      valorpropiedades,   
      totaldeudas,        
      abonospropuestos,   
      montosolicitado,    
      periodopagoid,      
      tasanormal,         
      tasamoratorio,      
      fecharesultado,     
      fechaentrega,       
      actano,             
      fechacomite,        
      resolucionid,       
      entregado,          
      usuarioid,
      lastusuarioid)

 values(
      psocioid,            
      psujetoid,           
      ptipoprestamoid,     
      pclavefinalidad,     
      pclavegarantia,     
      pdomicilioid,        
      pnosolicitud,        
      pfechasolicitud,     
      psueldo,             
      psueldoconyuge,      
      potrosingresos,      
      ptotalingresos,      
      pgastosordinarios,   
      potrosgastos,        
      potrosabonos,        
      ptotalegresos,       
      pcapacidadpago,      
      pvalorpropiedades,   
      ptotaldeudas,        
      pabonospropuestos,   
      pmontosolicitado,    
      pperiodopagoid,      
      ptasanormal1,         
      ptasamoratorio1,      
      pfecharesultado,     
      pfechaentrega,       
      pactano,             
      pfechacomite,        
      presolucionid,       
      pentregado,          
      pusuarioid,
      pusuarioid);



return currval('solicitudprestamo_solicitudprestamoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;