
--codigo de migracion explicado con manzanitas (´) (´) (´)
CREATE OR REPLACE FUNCTION migracion_matriz() RETURNS integer
    AS $_$
declare

	r record;
	l record;
	m record;
	pdescripcion character varying (75);
	psolicitudingresoid integer;
	psocioid integer;
	ppreguntaid_new integer;
	prespuesta text;
	pvalor numeric;
	psuma numeric;
begin
	--Explicado con manzanitas (´) (´) (´)
	-- por si estas instruciones no se corrieron por miedo
	if exists (SELECT column_name FROM information_schema.columns WHERE table_name = 'matrizriesgo' and column_name='riesgo') then
		alter table matrizriesgo drop column riesgo;
	end if;
	alter table matrizriesgo alter column valor type numeric;
	alter table matrizriesgo alter column respuesta type text;
	if exists (select * from pg_constraint  where conname='matrizriesgo_preguntaid_fkey') then
		alter table matrizriesgo drop constraint matrizriesgo_preguntaid_fkey;
	end if;
	delete from preguntasmatrizriesgo;
	insert into preguntasmatrizriesgo values (1,'Qué tipo de operaciones realizará en la Cooperativa');
	insert into preguntasmatrizriesgo values (2,'Qué tipo de servicios va a utilizar de la Cooperativa');
	insert into preguntasmatrizriesgo values (3,'Zona Geográfica. Lugar de Nacimiento');
	insert into preguntasmatrizriesgo values (4,'Nacionalidad');
	insert into preguntasmatrizriesgo values (5,'Edad');
	insert into preguntasmatrizriesgo values (6,'Estado Civil');
	insert into preguntasmatrizriesgo values (7,'Tiempo laborando en su actual empleo');
	insert into preguntasmatrizriesgo values (8,'Monto aproximado mensual de las Operaciones');
	insert into preguntasmatrizriesgo values (9,'Actividad principal');
	insert into preguntasmatrizriesgo values (10,'Sector Económico');
	insert into preguntasmatrizriesgo values (11,'Estado(s) de cobertura de la actividad económica');
	insert into preguntasmatrizriesgo values (12,'Cobertura Geográfica de la Actividad Económica desarrollada');
	insert into preguntasmatrizriesgo values (13,'Ingreso Total Mensual');
	insert into preguntasmatrizriesgo values (14,'Instrumento Monetario');
	insert into preguntasmatrizriesgo values (15,'Frecuencia de Operaciones al mes');
	insert into preguntasmatrizriesgo values (16,'Periodicidad de las operaciones');
	insert into preguntasmatrizriesgo values (17,'Propiedad de los Recursos');
	insert into preguntasmatrizriesgo values (18,'Origen de los Recursos');
	insert into preguntasmatrizriesgo values (19,'Mecanismos de comprobación de ingresos');
	insert into preguntasmatrizriesgo values (20,'Posible destino de los recursos');
	insert into preguntasmatrizriesgo values (21,'Tipo de Residencia');
	insert into preguntasmatrizriesgo values (22,'Ingreso del Conyuge');
	insert into preguntasmatrizriesgo values (23,'Antigüedad de la relación comercial con el socio');
	insert into preguntasmatrizriesgo values (24,'¿Tiene algún puesto público?/PEP´s');
	insert into preguntasmatrizriesgo values (25,'¿Algún familiar de usted, hasta segundo grado, ocupa algún puesto público?');
	insert into preguntasmatrizriesgo values (26,'Tipo de Personalidad Jurídica');
	insert into preguntasmatrizriesgo values (27,'Tiempo de Residencia en el Estado');
	insert into preguntasmatrizriesgo values (28,'Antigüedad domiciliaria');
	insert into preguntasmatrizriesgo values (29,'Se encuentra en la Lista de la OFAC');
	insert into preguntasmatrizriesgo values (30,'Actividades vulnerables');
	
	--Aqui empezamos la MIGRACION COMPLICADISIMA!!
	--esta tabla temporal servira para relacionar el numero de la pregunta anterior con el nuevo numero que le corresponde a la pregunta 
	CREATE TABLE preguntas_temp
	(
	  preguntaid_ant integer,
	  preguntaid_new integer
	);
	--Esta otra tabla nos servira para almacenar temporalmente las preguntas y asi poder borrar la matriz y actualizarla a la nueva version.
	CREATE TABLE matrizriesgo_temp
	(
	  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
	  socioid integer REFERENCES socio(socioid),
	  preguntaid_ant integer,
	  preguntaid_new integer,
	  respuesta character varying(100),
	  valor integer
	);
	
	--insertamos la relacion de las preguntas, que numero tenia y que numero tiene actualmente (igual lo saque de los PDF'S comparando un nuevo y un anterior, no es gran ciencia)
	insert into preguntas_temp values(20,13);
	insert into preguntas_temp values(19,29);
	insert into preguntas_temp values(18,28);
	insert into preguntas_temp values(17,27);
	insert into preguntas_temp values(16,26);
	insert into preguntas_temp values(15,25);
	insert into preguntas_temp values(14,24);
	insert into preguntas_temp values(13,22);
	insert into preguntas_temp values(12,21);
	insert into preguntas_temp values(11,17);
	insert into preguntas_temp values(10,15);
	insert into preguntas_temp values(9,14);
	insert into preguntas_temp values(8,9);
	insert into preguntas_temp values(7,8);
	insert into preguntas_temp values(6,7);
	insert into preguntas_temp values(5,6);
	insert into preguntas_temp values(4,5);
	insert into preguntas_temp values(3,4);
	insert into preguntas_temp values(2,3);
	insert into preguntas_temp values(1,1);
	
	
	--para todos los socios que tienen matriz de riesgo
	for l in
		--select socioid from matrizriesgo where socioid=7993 group by socioid
		select socioid from matrizriesgo group by socioid
	loop
		raise notice 'Migrando socio %...',l.socioid;
		--se procesa unicamente si la matriz es de 20 preguntas es decir aun no es migrada ( por lo que este proceso se puede correr varias veces)
		if (select count(*) from matrizriesgo where socioid=l.socioid)=20 then
			--extramos los datos de la matriz de riesgos del socio en cuestion
			for r in
				select * from matrizriesgo where socioid=l.socioid
			loop
				--tomamos el que seria el nuevo indice de la pregunta
				select preguntaid_new into ppreguntaid_new from preguntas_temp where preguntaid_ant=r.preguntaid;
				--y los insertamos en la tabla temporal
				insert into matrizriesgo_temp values (r.solicitudingresoid,r.socioid,r.preguntaid,ppreguntaid_new,r.respuesta,r.valor);
				raise notice 'Insertando en matriz temporal %,%,%,%,%,%',r.solicitudingresoid,r.socioid,r.preguntaid,ppreguntaid_new,r.respuesta,r.valor;
				delete from matrizriesgo where socioid=l.socioid;
				
			end loop;
			
			raise notice 'Insertando datos nuevos en la matriz...';
			--aqui hacemos un ciclo para verificar las 30 preguntas, insertar nuevas y reubicar anteriores 
			for i in 1..30 loop
				raise notice 'Procesando pregunta %...',i;
				--si la pregunta proviene de la matriz anterior se insertan los datos con su nuevo indice o numero y su nuevo valor correspondiente
				if exists (select * from matrizriesgo_temp where preguntaid_new=i )   then
					select solicitudingresoid,socioid,respuesta,valor into psolicitudingresoid,psocioid,prespuesta,pvalor from matrizriesgo_temp where preguntaid_new=i;
					
					--asignamos el valor de acuerdo a los nuevos parametros(esto se ve en el archivo de excel)
					if pvalor=0 then
						pvalor=0;
					elsif pvalor=2 then
						pvalor=3;
					elsif pvalor=5 then
						pvalor=2;
					elsif pvalor=8 then
						pvalor=-2;
					elsif pvalor=122 then
						pvalor=-2;
					end if;
					--insertamos la pregunta y respuesta con su nuevo valor ESTO ES LA MIGRACION!!!!
					insert into matrizriesgo values (psolicitudingresoid,psocioid,i,prespuesta,pvalor);
					raise notice 'insertando pregunta anterior %,%,%,%,%',psolicitudingresoid,psocioid,i,prespuesta,pvalor;
				--de lo contrario es una pregunta nueva y se inserta vacia con un valor de 0
				else
					insert into matrizriesgo values (r.solicitudingresoid,r.socioid,i,'',0);
					raise notice 'Insertando pregunta nueva...';
				end if;
			end loop;
		end if;
		
		select sum(valor) into psuma from matrizriesgo where socioid=l.socioid;
		select descripcion into pdescripcion from nivelderiesgo where psuma between nivelriesgomin and nivelriesgomax;
	
		if exists (select * from nivelderiesgosocio where socioid=l.socioid) then
			update  nivelderiesgosocio set promedio=psuma,descripcion=pdescripcion where socioid=l.socioid;
		else
			insert into nivelderiesgosocio (socioid,promedio,descripcion,riesgomanual) values(l.socioid,psuma,pdescripcion,'N');
		end if;



	end loop;
	drop table preguntas_temp;
	drop table matrizriesgo_temp;
	
	
     --y ya... xD eso era lo COMPLICADISIMO!!!!!!!!
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
