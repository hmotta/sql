CREATE OR REPLACE FUNCTION spusolicitudprestamo(int4, int4, int4, bpchar, bpchar, bpchar, int4, int4, numeric, numeric, numeric, int4, int4, int4, numeric, int4, numeric, numeric, date, date, varchar, int4, int4)
  RETURNS pg_catalog.int4 AS $BODY$
declare
  
  psolicitudprestamoid alias for $1;
  psocioid alias for $2;
  psujetoid alias for $3;
  ptipoprestamoid alias for $4;
  pclavefinalidad alias for $5;
  pclavegarantia alias for $6;
  pdiasdecobro alias for $7;
  pdiamescobro alias for $8;
  preciprocidad alias for $9;
  ppartesocial alias for $10;
  pahorrogarantia alias for $11;
  pfinalidadid alias for $12;
  pcalculonormalid alias for $13;
  pabonospropuestos alias for $14;
  pmontosolicitado alias for $15;
  pperiodopagoid alias for $16;
  ptasanormal alias for $17;
  ptasamoratorio alias for $18;
  pprimerpago alias for $19;
  pfechaentrega alias for $20;
  pusuarioid alias for $21;
  pperiododegracia alias for $22;
  ppagainteresgracia alias for $23;
  
  pgrupo character varying (25);
  


begin
  if pabonospropuestos=1 and ptipoprestamoid <> 'P1' and ptipoprestamoid <> 'P4' and ptipoprestamoid <>'N16' then
      raise exception 'El tipo P1 es el unico que puede ser de 1 amortizacion!';
  end if;

  
  ------- >> Validar la finalidad del prestamo acorde con el tipo de producto [consumo, comercial, vivienda]
   /*if pclavefinalidad='001' then--Comercial
		if ptipoprestamoid not in ('R1','C1','C4','C9','T1') then
			raise exception 'Este tipo de credito no puede ser Comercial';
		end if;
   elseif pclavefinalidad='002' then--Consumo
		if ptipoprestamoid not in ('CAS','P4','N8','N20','R2','T2','N1','N4','N15','N21','N9','N16','P1','N13','N14','N7','N22','N5','N53','N54','CF', 'LN') then
			raise exception 'Este tipo de credito no puede Consumo';
		end if;
   else --vivienda
			raise exception 'Este tipo de credito no puede a la Vivienda';
   end if;*/
   ------- <<
   
   select grupo into pgrupo from solicitudingreso where socioid=psocioid;
   
   
  update solicitudprestamo set
      tipoprestamoid=ptipoprestamoid,     
      clavefinalidad=pclavefinalidad,     
      clavegarantia=pclavegarantia,      
      dias_de_cobro=pdiasdecobro,             
      dia_mes_cobro=pdiamescobro,      
      reciprocidad=preciprocidad,   
      partesocial=ppartesocial,        
      ahorrogarantia=pahorrogarantia,        
      finalidadid=pfinalidadid,   
      calculonormalid=pcalculonormalid,        
      abonospropuestos=pabonospropuestos,   
      montosolicitado=pmontosolicitado,    
      periodopagoid=pperiodopagoid,      
      tasanormal=ptasanormal,         
      tasamoratorio=ptasamoratorio,      
      primerpago=pprimerpago,     
      fechaentrega=pfechaentrega,       
      grupo=pgrupo,             
      usuarioid=pusuarioid,
	  periododegracia=pperiododegracia,
	  pagainteresgracia=ppagainteresgracia
 where solicitudprestamoid=psolicitudprestamoid;
	
	update solicitudprestamo set etapa=1 where solicitudprestamoid = psolicitudprestamoid and etapa=0;
	
	update solicitudprestamo set etapa=4 where solicitudprestamoid = psolicitudprestamoid and tipoprestamoid in ('N8','N16','P4');
	
	return psolicitudprestamoid;
	
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;