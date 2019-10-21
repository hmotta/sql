CREATE OR REPLACE FUNCTION spioperacionpld(integer,char,date,numeric,varchar,varchar,integer,integer,integer,varchar,varchar)
  RETURNS integer AS $BODY$
declare
	psocioid alias for $1;
	psucursal alias for $2;
	pfecha alias for $3;
	pmonto alias for $4;
	pmotivo alias for $5;
	priesgo alias for $6;
	ptipo_operacion alias for $7;
	ptipo_transaccion alias for $8;
	pinstrumento_monetario alias for $9;
	pfoliocaja alias for $10;
	pparametroid alias for $11;
	
	ncuenta integer;
	
begin
	--Sólo las operaciones con montos mayores o iguales a 100 
	if pparametroid not in ('I17','I26') and pmonto<100 then
		return 0;
	end if;
	
	--Verificar que no exista una operacion con los mismos datos (socio,monto,fecha,motivo) 
	select count(*) into ncuenta from operaciones_detectadas_pld where socioid=psocioid and parametroid=pparametroid and foliocaja=pfoliocaja;
	if ncuenta>0 then
		return 0;
	end if;
	
	
	
	insert into operaciones_detectadas_pld (socioid,sucursal,fecha,monto,motivo,riesgo,tipo_operacion,tipo_transaccion,instrumento_monetario,fecha_deteccion,foliocaja,parametroid) values (psocioid,psucursal,pfecha,pmonto,pmotivo,priesgo,ptipo_operacion,ptipo_transaccion,pinstrumento_monetario,pfecha,pfoliocaja,pparametroid);
	
	
	return currval('operaciones_detectadas_pld_operacionid_seq');
	
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;