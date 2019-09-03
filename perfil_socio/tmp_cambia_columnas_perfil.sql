CREATE OR REPLACE FUNCTION "public"."tmp_cambia_columnas_perfil"()
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		scadena varchar(100);
		
		nlongitud int4;
		nsocioid int4;
		r record;
		arr_datos int4[];
		elemento int4;
	BEGIN
		--Pasar las columnas necesarias de varchar a tipo array
		---==========================================datosingresoconceatucliente==========================================
		alter table datosingresoconceatucliente add column operaciones_1 int4[];
		alter table datosingresoconceatucliente add column servicios_1 int4[];
		alter table datosingresoconceatucliente add column periodicidad_1 int4;
			
			--Columna: Operaciones
			FOR r IN 
				select socioid,operaciones from datosingresoconceatucliente where operaciones IS NOT NULL
			LOOP
				nlongitud = length(r.operaciones);
				arr_datos:='{}';
				FOR i IN 1..nlongitud LOOP
					elemento := substring(r.operaciones,i,1);
					arr_datos:=array_append(arr_datos,elemento);
				END LOOP;
				update datosingresoconceatucliente set operaciones_1=arr_datos where socioid=r.socioid;
			END LOOP;
			
			--Columna: servicios
			FOR r IN 
				select socioid,servicios from datosingresoconceatucliente where servicios IS NOT NULL
			LOOP
				scadena='{';
				nlongitud = length(r.servicios);
				arr_datos:='{}';
				FOR i IN 1..nlongitud LOOP
					elemento := substring(r.servicios,i,1);
					arr_datos:=array_append(arr_datos,elemento);
				END LOOP;
				scadena=scadena||'}';
				update datosingresoconceatucliente set servicios_1=arr_datos where socioid=r.socioid;
			END LOOP;
			
			--Columna: periodicidad
			FOR r IN 
				select socioid,periodicidad from datosingresoconceatucliente where periodicidad IS NOT NULL
			LOOP
				update datosingresoconceatucliente set periodicidad_1=r.periodicidad where socioid=r.socioid;
			END LOOP;
			
		alter table datosingresoconceatucliente drop column operaciones;
		alter table datosingresoconceatucliente drop column servicios;
		alter table datosingresoconceatucliente drop column periodicidad;
		
		alter table datosingresoconceatucliente rename column operaciones_1 to operaciones;
		alter table datosingresoconceatucliente rename column servicios_1 to servicios;
		alter table datosingresoconceatucliente rename column periodicidad_1 to periodicidad;
		
		--==========================================trabajoconceatucliente==========================================
		alter table trabajoconceatucliente add column comprobacioningresos_1 int4[];
			
			--Columna: comprobacioningresos
			FOR r IN 
				select socioid,comprobacioningresos from trabajoconceatucliente where comprobacioningresos IS NOT NULL
			LOOP
				
				nlongitud = length(r.comprobacioningresos);
				arr_datos:='{}';
				FOR i IN 1..nlongitud LOOP
					elemento := substring(r.comprobacioningresos,i,1);
					arr_datos:=array_append(arr_datos,elemento);
				END LOOP;
				
				update trabajoconceatucliente set comprobacioningresos_1=arr_datos where socioid=r.socioid;
			END LOOP;
		alter table trabajoconceatucliente drop column comprobacioningresos;
		alter table trabajoconceatucliente rename column comprobacioningresos_1 to comprobacioningresos;
		
		--==========================================ingresoegresoconceatucliente==========================================
		alter table ingresoegresoconceatucliente add column estadosactividad_1 int4[];
		alter table ingresoegresoconceatucliente add column coberturageografica_1 int4;
		alter table ingresoegresoconceatucliente add column origenrecursos_1 int4[];
		alter table ingresoegresoconceatucliente add column ventaactivo_1 int4;
		alter table ingresoegresoconceatucliente add column destinorecursos_1 int4[];
		alter table ingresoegresoconceatucliente add column otrodestino_1 text;
		
			--Columna: estadosactividad
			FOR r IN 
				select socioid,estadosactividad from ingresoegresoconceatucliente where estadosactividad IS NOT NULL
			LOOP
				
				nlongitud = length(r.estadosactividad);
				arr_datos:='{}';
				FOR i IN 1..nlongitud LOOP
					elemento := substring(r.estadosactividad,i,1);
					arr_datos:=array_append(arr_datos,elemento);
				END LOOP;
				
				update ingresoegresoconceatucliente set estadosactividad_1=arr_datos where socioid=r.socioid;
			END LOOP;
			
			--Columna: coberturageografica
			FOR r IN 
				select socioid,coberturageografica from ingresoegresoconceatucliente where coberturageografica IS NOT NULL
			LOOP
				update ingresoegresoconceatucliente set coberturageografica_1=coberturageografica where socioid=r.socioid;
			END LOOP;
			
			--Columna: origenrecursos
			FOR r IN 
				select socioid,origenrecursos from ingresoegresoconceatucliente where origenrecursos IS NOT NULL
			LOOP
				
				nlongitud = length(r.origenrecursos);
				arr_datos:='{}';
				FOR i IN 1..nlongitud LOOP
					elemento := substring(r.origenrecursos,i,1);
					arr_datos:=array_append(arr_datos,elemento);
				END LOOP;
				
				update ingresoegresoconceatucliente set origenrecursos_1=arr_datos where socioid=r.socioid;
			END LOOP;
			
			--Columna: origenrecursos
			FOR r IN 
				select socioid,ventaactivo from ingresoegresoconceatucliente where ventaactivo IS NOT NULL
			LOOP
				update ingresoegresoconceatucliente set ventaactivo_1=r.ventaactivo where socioid=r.socioid;
			END LOOP;
			
			--Columna: destinorecursos
			FOR r IN 
				select socioid,destinorecursos from ingresoegresoconceatucliente where destinorecursos IS NOT NULL
			LOOP
				
				nlongitud = length(r.destinorecursos);
				arr_datos:='{}';
				FOR i IN 1..nlongitud LOOP
					elemento := substring(r.destinorecursos,i,1);
					arr_datos:=array_append(arr_datos,elemento);
				END LOOP;
				
				update ingresoegresoconceatucliente set destinorecursos_1=arr_datos where socioid=r.socioid;
			END LOOP;
			
			--Columna: otrodestino
			FOR r IN 
				select socioid,otrodestino from ingresoegresoconceatucliente where otrodestino IS NOT NULL
			LOOP
				update ingresoegresoconceatucliente set otrodestino_1=r.otrodestino where socioid=r.socioid;
			END LOOP;
		
		alter table ingresoegresoconceatucliente drop column estadosactividad;
		alter table ingresoegresoconceatucliente drop column coberturageografica;
		alter table ingresoegresoconceatucliente drop column origenrecursos;
		alter table ingresoegresoconceatucliente drop column ventaactivo;
		alter table ingresoegresoconceatucliente drop column destinorecursos;
		alter table ingresoegresoconceatucliente drop column otrodestino;
		
		alter table ingresoegresoconceatucliente rename column estadosactividad_1 to estadosactividad;
		alter table ingresoegresoconceatucliente rename column coberturageografica_1 to coberturageografica;
		alter table ingresoegresoconceatucliente rename column origenrecursos_1 to origenrecursos;
		alter table ingresoegresoconceatucliente rename column ventaactivo_1 to ventaactivo;
		alter table ingresoegresoconceatucliente rename column destinorecursos_1 to destinorecursos;
		alter table ingresoegresoconceatucliente rename column otrodestino_1 to otrodestino;
		
		RETURN 1;
	END
$BODY$
  LANGUAGE plpgsql VOLATILE;