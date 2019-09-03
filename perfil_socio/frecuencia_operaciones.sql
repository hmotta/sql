CREATE OR REPLACE FUNCTION frecuencia_operaciones(integer,date,date)
  RETURNS integer AS $BODY$ 
	DECLARE
		psocioid alias for $1;
		pfecha_ini alias for $2;
		pfecha_fin alias for $3;
		ndias_transcurridos integer;
		nfrencuencia_dias integer;
		nnum_operaciones integer;
		nfrencuencia_operaciones integer;
		dfecha date;
		r record;
	BEGIN
		--ndias_transcurridos:=date_part('DAY',CURRENT_DATE);
		nfrencuencia_dias:=0;
		nnum_operaciones:=0;
		nfrencuencia_operaciones:=0;
		FOR r IN 
			select date(fechahora) as fecha  from movicaja mc inner join movipolizas mp on (mc.movipolizaid=mp.movipolizaid) where socioid=psocioid and tipomovimientoid in ('AC') and (mc.efectivo is not null and mc.efectivo>0 and mc.efectivo<>3) and date(mc.fechahora) between pfecha_ini and pfecha_fin group by date(fechahora) order by date(fechahora)
		LOOP
			IF dfecha IS NULL THEN --Es la primera vez que entra al ciclo
				dfecha=r.fecha;
			ELSE --Se saca la diferencia de dias con respecto a la operacion anterior
				nfrencuencia_dias = nfrencuencia_dias + (r.fecha - dfecha);
				dfecha=r.fecha;
			END IF;
			
			nnum_operaciones=nnum_operaciones+1; --Se incrementa el numero de operaciones para sacar el promedio
			raise notice 'dfecha=%',dfecha;
			raise notice 'nfrencuencia_dias=%',nfrencuencia_dias;
			raise notice 'nnum_operaciones=%',nnum_operaciones;
		END LOOP;
		IF nnum_operaciones>0 THEN
			nfrencuencia_operaciones=ceil(nfrencuencia_dias/nnum_operaciones);
		ELSE
			nfrencuencia_operaciones=0;
		END IF;
		
		RETURN nfrencuencia_operaciones;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;