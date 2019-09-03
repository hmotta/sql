--alter table autorizabonificacion add referenciaprestamo character(18);

CREATE or replace FUNCTION  poliza_movimiento_linea(integer,numeric,numeric) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  xmonto_parametro alias for $2;
  pmovimiento alias for $3;
  pfecha date;
  pnumero_poliza int4;
  preferencia int4;
  ppolizaid int4;
  sreferenciaprestamo varchar(14);
  sconcepto_poliza varchar(30);
  pserie_user varchar(2);
  xmonto numeric;
begin
	pserie_user='WW';
	pfecha:=current_date;
	xmonto:=xmonto_parametro;
	select *
    into pnumero_poliza,preferencia
    from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');
    
 
	if pmovimiento=1 then
		sconcepto_poliza:='Autorización de Linea:'||sreferenciaprestamo;
		select montoprestamo into xmonto from prestamos where prestamoid=pprestamoid;
	elsif pmovimiento=2 then
		sconcepto_poliza:='Disposición de Linea:'||sreferenciaprestamo;
	elsif pmovimiento=3 then
		sconcepto_poliza:='Abono de Linea:'||sreferenciaprestamo;
	else
		sconcepto_poliza:='Cancelación de Linea:'||sreferenciaprestamo;
		select montoprestamo into xmonto from prestamos where prestamoid=pprestamoid;
	end if;
-- ********************* Encabezado de la poliza  ***************************** --
	select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ',sconcepto_poliza,pfecha);
	
-- ********************* Cuerpo de la poliza  ***************************** --
	if pmovimiento=1 then --Autorización
		perform spimovipoliza(ppolizaid,'7103',' ','A',xmonto,0,' ',' ',sconcepto_poliza,pprestamoid,0);
		
		perform spimovipoliza(ppolizaid,'7203',' ','A',0,xmonto,' ',' ',sconcepto_poliza,pprestamoid,0);
			
	elsif pmovimiento=2 then --Disposición
		perform spimovipoliza(ppolizaid,'7103',' ','A',0,xmonto,' ',' ',sconcepto_poliza,pprestamoid,0);
		
		perform spimovipoliza(ppolizaid,'7203',' ','A',xmonto,0,' ',' ',sconcepto_poliza,pprestamoid,0);
	elsif pmovimiento=3 then --Abono
		perform spimovipoliza(ppolizaid,'7103',' ','A',xmonto,0,' ',' ',sconcepto_poliza,pprestamoid,0);
		
		perform spimovipoliza(ppolizaid,'7203',' ','A',0,xmonto,' ',' ',sconcepto_poliza,pprestamoid,0);
	else --Cancelacion
		perform spimovipoliza(ppolizaid,'7103',' ','A',0,xmonto,' ',' ',sconcepto_poliza,pprestamoid,0);
		
		perform spimovipoliza(ppolizaid,'7203',' ','A',xmonto,0,' ',' ',sconcepto_poliza,pprestamoid,0);
	end if;
     
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;