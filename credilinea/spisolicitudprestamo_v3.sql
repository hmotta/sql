CREATE or replace FUNCTION spisolicitudprestamo( integer, integer, character, character, character, date, integer, date, integer, integer, numeric, numeric, numeric, integer, integer, integer, numeric, integer,numeric,numeric,date,date,character,integer,integer,integer) RETURNS integer
    AS $_$
declare
  psocioid alias for $1;
  psujetoid alias for $2;
  ptipoprestamoid alias for $3;
  pclavefinalidad alias for $4;
  pclavegarantia alias for $5;
  pvigencia alias for $6;
  pnosolicitud alias for $7;
  pfechasolicitud alias for $8;
  pdiasdecobro alias for $9;
  pdiamescobro alias for $10;
  preciprocidad alias for $11;
  ppartesocial alias for $12;
  pahorrogarantia alias for $13;
  pfinalidadid alias for $14;
  pcalculonormalid alias for $15;
  pabonospropuestos alias for $16;
  pmontosolicitado alias for $17;
  pperiodopagoid alias for $18;
  ptasanormal alias for $19;
  ptasamoratorio alias for $20;
  pprimerpago alias for $21;
  pfechaentrega alias for $22;
  pusuarioid alias for $23;
  petapa  alias for $24;
  pperiododegracia alias for $25;
  ppagainteresgracia alias for $26;
  ptasanormal1 numeric;
  ptasamoratorio1 numeric;
  pgrupo character varying (25);
  
  pconsultaburoid integer;
  
begin

  if pabonospropuestos=1 and ptipoprestamoid <> 'P1' and ptipoprestamoid <> 'P4' and ptipoprestamoid <>'N16' then
      raise exception 'El tipo P1 es el unico que puede ser de 1 amortizacion!';
  end if;

  ------- >> Validar la finalidad del prestamo acorde con el tipo de producto [consumo, comercial, vivienda]
   if pclavefinalidad='001' then--Comercial
if ptipoprestamoid not in ('R1','C1','C4','C9','T1') then
raise exception 'Este tipo de credito no puede ser Comercial';
end if;
   elseif pclavefinalidad='002' then--Consumo
if ptipoprestamoid not in ('CAS','P4','N8','N20','R2','T2','N1','N4','N15','N21','N9','N16','P1','N13','N14','N7','N22','N5','N53','N54','CF','LN') then
raise exception 'Este tipo de credito no puede Consumo';
end if;
   else --vivienda
raise exception 'Este tipo de credito no puede a la Vivienda';
   end if;
   ------- <<
   
   select grupo into pgrupo from solicitudingreso where socioid=psocioid;
   
   --select ultimaconsultaburo into pconsultaburoid from ultimaconsultaburo(psujetoid);
   pconsultaburoid:=3099;
  insert into
    solicitudprestamo(
      socioid,            
      sujetoid,           
      tipoprestamoid,     
      clavefinalidad,     
      clavegarantia,      
      vigencia,        
      nosolicitud,        
      fechasolicitud,     
      dias_de_cobro,
	  meses_de_cobro,	
      dia_mes_cobro,      
      reciprocidad,   
      partesocial,        
      ahorrogarantia,        
      finalidadid,   
      calculonormalid,        
      abonospropuestos,   
      montosolicitado,    
      periodopagoid,      
      tasanormal,         
      tasamoratorio,      
      primerpago,     
      fechaentrega,       
      grupo,
      usuarioid,
	  lastupdate,
	  estatus,
  	  etapa,
	  periododegracia,
	  pagainteresgracia,
	  consultaburoid)

 values(
      psocioid,            
      psujetoid,           
      ptipoprestamoid,     
      pclavefinalidad,     
      pclavegarantia,     
      pvigencia,        
      pnosolicitud,        
      pfechasolicitud,     
      pdiasdecobro,
	  0,
      pdiamescobro,      
      preciprocidad,   
      ppartesocial,        
      pahorrogarantia,       
      pfinalidadid,   
      pcalculonormalid,        
      pabonospropuestos,   
      pmontosolicitado,    
      pperiodopagoid,      
      ptasanormal,         
      ptasamoratorio,      
      pprimerpago,     
      pfechaentrega,       
      pgrupo,             
      pusuarioid,
	  current_date,
	  0,
	  petapa,
	  pperiododegracia,
	  ppagainteresgracia,
	  pconsultaburoid);



return currval('solicitudprestamo_solicitudprestamoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;