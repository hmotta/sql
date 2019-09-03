CREATE OR REPLACE FUNCTION "public"."actualiza_perfil_socio"(int4)
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		psocioid alias for $1;
		scadena varchar(100);
		nlongitud int4;
		nsocioid int4;
		nentero int4;
		nfrencuencia_dias int4;
		nnum_operaciones int4;
		nfrencuencia_operaciones int4;
		xnumeric numeric;
		dfecha date;
		r record;
	BEGIN
		
		--1 Qué tipo de operaciones realizará en la Cooperativa
		--Prestamos
		select prestamoid into nentero from  prestamos where socioid=psocioid and claveestadocredito<>'008' limit 1;
		if found then
			update datosingresoconceatucliente set operaciones[1]=1 where socioid=psocioid;
		end if;
		--Ahorro-Inversion
		select movicajaid into nentero from  movicaja where socioid=psocioid and tipomovimientoid in (select tipomovimientoid from spsmovimientosmayor(1)) or tipomovimientoid='IN' limit 1;
		if found then
			update datosingresoconceatucliente set operaciones[2]=1 where socioid=psocioid;
		end if;
		--Remesas-Dispercion de fondos
		select movicajaid into nentero from  movicaja where socioid=psocioid and tipomovimientoid in (select tipomovimientoid from movimientosenvioremesas() union select tipomovimientoid from movimientospagoremesas()) limit 1;
		if found then
			update datosingresoconceatucliente set operaciones[3]=1 where socioid=psocioid;
		end if;
		
		--2 Qué tipo de servicios va a utilizar de la Cooperativa
		update datosingresoconceatucliente set servicios[1]=1 where socioid=psocioid;
		
		--7	Tiempo laborando en su actual empleo
		select extract( year from age(fechaingresotrabajo)) into nentero from trabajoconceatucliente where socioid=psocioid;
		if nentero<2 then
			update  trabajoconceatucliente set tiempolaborando=1 where socioid=psocioid;
		elsif nentero between 2 and 5 then
			update  trabajoconceatucliente set tiempolaborando=2 where socioid=psocioid;
		elsif nentero > 5 then
			update  trabajoconceatucliente set tiempolaborando=3 where socioid=psocioid;
		else
			
		end if;
			
		--8 Monto aproximado mensual de las Operaciones (6 meses)
		--select sum(debe) into xnumeric from movicaja mc inner join movipolizas mp on (mc.movipolizaid=mp.movipolizaid) where socioid=psocioid and (tipomovimientoid in (select tipomovimientoid from spsmovimientosmayor(1)) or tipomovimientoid in ('IN','00')) and date(mc.fechahora) between (current_date-180) and current_date;
		select avg(debe) into xnumeric from movicaja mc inner join movipolizas mp on (mc.movipolizaid=mp.movipolizaid) where socioid=psocioid and mp.debe>0 and tipomovimientoid in ('AC') and (mc.efectivo is not null and mc.efectivo>0 and mc.efectivo<>3) and date(mc.fechahora) between (current_date-180) and current_date;
		
		update datosingresoconceatucliente set montooperaciones=xnumeric where socioid=psocioid;
		
		--14	Instrumento Monetario (Se toma el de mayor monto) (6 meses)
	select A.efectivo into nentero from  (select sum(debe) as monto,mc.efectivo  from movicaja mc inner join movipolizas mp on (mc.movipolizaid=mp.movipolizaid) where socioid=psocioid and tipomovimientoid in ('AC') and (mc.efectivo is not null and mc.efectivo>0 and mc.efectivo<>3) and date(mc.fechahora) between (current_date-180) and current_date group by mc.efectivo) as A order by A.monto desc limit 1;
		if nentero in (1,4) then --Efectivo
			update  datosingresoconceatucliente set intrumentomonetario=1 where socioid=psocioid;
		elseif nentero in (2,5) then --Cheque
			update  datosingresoconceatucliente set intrumentomonetario=2 where socioid=psocioid;
		elseif nentero in (6) then --Transferencia
			update  datosingresoconceatucliente set intrumentomonetario=3 where socioid=psocioid;
		end if;
		
		--15	Frecuencia de Operaciones al mes (6 meses)
		select count(*) into nnum_operaciones  from movicaja mc inner join movipolizas mp on (mc.movipolizaid=mp.movipolizaid) where socioid=psocioid  and tipomovimientoid in ('AC')and (mc.efectivo is not null and mc.efectivo>0 and mc.efectivo<>3) and date(mc.fechahora) between (current_date-180) and current_date;
		nentero = ceil(nnum_operaciones::decimal/6.00);
		if nentero between 1 and 4 then
			update  datosingresoconceatucliente set frecuenciaopera=1 where socioid=psocioid;
		elsif nentero between 5 and 6 then
			update  datosingresoconceatucliente set frecuenciaopera=2 where socioid=psocioid;
		elsif nentero>6 then
			update  datosingresoconceatucliente set frecuenciaopera=3 where socioid=psocioid;
		else
			
		end if;
		
		
		--16	Periodicidad de las operaciones (6 meses)
		nfrencuencia_operaciones:=frecuencia_operaciones(psocioid,current_date-180,current_date);
		IF nfrencuencia_operaciones BETWEEN 1 AND 2 THEN --DIARIA
			update datosingresoconceatucliente set periodicidad=7 where socioid=psocioid;
		ELSIF nfrencuencia_operaciones BETWEEN 2 AND 7 THEN --SEMANAL
			update datosingresoconceatucliente set periodicidad=6 where socioid=psocioid;
		ELSIF nfrencuencia_operaciones BETWEEN 8 AND 15 THEN --QUINCENAL
			update datosingresoconceatucliente set periodicidad=5 where socioid=psocioid;
		ELSIF nfrencuencia_operaciones BETWEEN 16 AND 30 THEN --MENSUAL
			update datosingresoconceatucliente set periodicidad=4 where socioid=psocioid;
		ELSIF nfrencuencia_operaciones BETWEEN 31 AND 60 THEN --BIMESTRAL
			update datosingresoconceatucliente set periodicidad=3 where socioid=psocioid;
		ELSIF nfrencuencia_operaciones BETWEEN 61 AND 180 THEN --SEMESTRAL
			update datosingresoconceatucliente set periodicidad=2 where socioid=psocioid;
		ELSE --ESPORÁDICA
			update datosingresoconceatucliente set periodicidad=1 where socioid=psocioid;
		END IF;
		
		--23	Antigüedad de la relación comercial con el socio
		select (current_date-fechaingreso) into nentero from solicitudingreso where socioid=psocioid;
		if nentero<=180 then
			update  deppromedioconoceatucliente set antiguedad=1 where socioid=psocioid;
		elsif nentero>180 and nentero<=360 then
			update  deppromedioconoceatucliente set antiguedad=2 where socioid=psocioid;
		else
			update  deppromedioconoceatucliente set antiguedad=3 where socioid=psocioid;
		end if;
		
		--27	Tiempo de Residencia en el Estado (No se tiene un fecha de referencia)
		
		--28	Antigüedad domiciliaria (No se tiene un fecha de referencia)
		
		update generalesconceatucliente set fecha_act_perfil=current_date where socioid=psocioid;
		
		RETURN 1;
	END
$BODY$
  LANGUAGE plpgsql VOLATILE;