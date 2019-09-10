CREATE or replace FUNCTION respuesta_matriz(integer,integer) RETURNS tvalorrespuestamat
    AS $_$
declare
	psocioid alias for $1;
	ppreguntaid alias for $2;
	r tvalorrespuestamat%rowtype;
	nvalor integer;
	arrvalores integer[];
BEGIN
	--1	Qué tipo de operaciones realizará en la Cooperativa
	IF ppreguntaid=1 THEN 
		select operaciones into arrvalores from datosingresoconceatucliente where socioid=psocioid;

	--2	Qué tipo de servicios va a utilizar de la Cooperativa
	ELSIF ppreguntaid=2 THEN 
		select servicios into arrvalores from datosingresoconceatucliente where socioid=psocioid;

	--3	Zona Geográfica. Lugar de Nacimiento
	ELSIF ppreguntaid=3 THEN 
		select estadomexid into nvalor from solicitudingreso so inner join ciudadesmex cd on (so.ciudadmexid=cd.ciudadmexid) where socioid=psocioid;
		if nvalor in (4,30,27,7,20,12,23,31) then
			nvalor=1;
		elsif nvalor in (22,9,15,17,11,29,21,13,1,24,18) then
			nvalor=2;
		elsif nvalor in (2,3,19,8,5,26,28,25,10,32,14,16) then
			nvalor=3;
		end if;
		
	--4	Nacionalidad
	ELSIF ppreguntaid=4 THEN
		select nacionalidad into nvalor from generalesconceatucliente where socioid=psocioid;
	
	--5	Edad
	ELSIF ppreguntaid=5 THEN
		select extract( year from age(fecha_nacimiento)) into nvalor from sujeto su inner join socio so on (su.sujetoid=so.sujetoid) where so.socioid=psocioid;
	
	--6	Estado Civil
	ELSIF ppreguntaid=6 THEN
		select estadocivilid into nvalor from solicitudingreso where socioid=psocioid;
	
	--7	Tiempo laborando en su actual empleo
	ELSIF ppreguntaid=7 THEN
		select tiempolaborando into nvalor from trabajoconceatucliente where socioid=psocioid;
	
	--8	Monto aproximado mensual de las Operaciones
	ELSIF ppreguntaid=8 THEN
		select trunc(montooperaciones) into nvalor from datosingresoconceatucliente where socioid=psocioid;
		
	--9	Actividad principal
	ELSIF ppreguntaid=9 THEN
		select actividadgeneral into nvalor from ingresoegresoconceatucliente where socioid=psocioid;
		
	--10	Sector Económico
	ELSIF ppreguntaid=10 THEN
		select sectoreconomico into nvalor from ingresoegresoconceatucliente where socioid=psocioid;
		
	--11	Estado(s) de cobertura de la actividad económica
	ELSIF ppreguntaid=11 THEN
		select estadosactividad into arrvalores from ingresoegresoconceatucliente where socioid=psocioid;
		
	--12	Cobertura geográfica de la Actividad Económica desarrollada
	ELSIF ppreguntaid=12 THEN
		select coberturageografica into nvalor from ingresoegresoconceatucliente where socioid=psocioid;
		
	--13	Ingreso Total Mensual
	ELSIF ppreguntaid=13 THEN
		select trunc(ingresototal) into nvalor from ingresoegresoconceatucliente where socioid=psocioid;
		
	--14	Instrumento Monetario (Por Monto)
	ELSIF ppreguntaid=14 THEN
		select intrumentomonetario into nvalor from datosingresoconceatucliente where socioid=psocioid;
		
	--15	Frecuencia de Operaciones al mes (no tranfs. int.)
	ELSIF ppreguntaid=15 THEN
		select frecuenciaopera into nvalor from datosingresoconceatucliente where socioid=psocioid;
	
	--16	Periodicidad de las operaciones
	ELSIF ppreguntaid=16 THEN
		select periodicidad into nvalor from datosingresoconceatucliente where socioid=psocioid;
		
	--17	Propiedad de los Recursos
	ELSIF ppreguntaid=17 THEN
		select recursos into nvalor from datosingresoconceatucliente where socioid=psocioid;
		
	--18	Origen de los Recursos
	ELSIF ppreguntaid=18 THEN
		select origenrecursos into arrvalores from ingresoegresoconceatucliente where socioid=psocioid;
		
	--19	Mecanismos de comprobación de ingresos
	ELSIF ppreguntaid=19 THEN
		select comprobacioningresos into arrvalores from trabajoconceatucliente where socioid=psocioid;
		
	--20	Posible destino de los recursos
	ELSIF ppreguntaid=20 THEN
		select destinorecursos into arrvalores from ingresoegresoconceatucliente where socioid=psocioid;
		
	--21	Tipo de Residencia
	ELSIF ppreguntaid=21 THEN
		select tipocasaid into nvalor from solicitudingreso where socioid=psocioid;
	
	--22	Ingreso del Cónyuge
	ELSIF ppreguntaid=22 THEN
		select trunc(coalesce(ingresomensual,0)) into nvalor from conyugeconceatucliente where socioid = psocioid;
		nvalor:=coalesce(nvalor,0);
		raise notice '%',nvalor;
		
	--23	Antigüedad de la relación comercial con el socio
	ELSIF ppreguntaid=23 THEN
		SELECT (current_date	- fechaingreso) into nvalor FROM solicitudingreso WHERE socioid=psocioid;
	
	--24	A Tenido algún puesto público? PEPs
	ELSIF ppreguntaid=24 THEN
		SELECT puestopublico into nvalor FROM deppromedioconoceatucliente WHERE socioid=psocioid;
	
	--25	Algún familiar de usted, hasta segundo grado, ¿ocupa algún puesto público?
	ELSIF ppreguntaid=25 THEN
		SELECT familiarpuestoublico into nvalor FROM deppromedioconoceatucliente WHERE socioid=psocioid;
	
	--26	Tipo de Personalidad Jurídica
	ELSIF ppreguntaid=26 THEN
		SELECT personajuridicaid into nvalor FROM generalesconceatucliente WHERE socioid=psocioid;
	
	--27	Tiempo de Residencia en el Estado
	ELSIF ppreguntaid=27 THEN
		SELECT tiemporesidencia into nvalor FROM datosingresoconceatucliente WHERE socioid=psocioid;
	
	--28	Antigüedad domiciliaria
	ELSIF ppreguntaid=28 THEN
		select regexp_replace(tiempovivirendomicilio,'[A-Z]*|Ñ','','g') INTO nvalor FROM solicitudingreso WHERE socioid=psocioid and tiempovivirendomicilio SIMILAR TO '%AÑOS';
		nvalor:=coalesce(nvalor,1);
	--29	Se encuentra en la Lista de la OFAC
	ELSIF ppreguntaid=29 THEN
		select listaofac into nvalor FROM deppromedioconoceatucliente WHERE socioid=psocioid;
	
	--30	Actividades vulnerables
	ELSIF ppreguntaid=30 THEN
		select nivelderiesgo,nombre into r.riesgo,r.respuesta from actividadbanxico ab inner join ingresoegresoconceatucliente ic on (ab.actividadid=ic.actividadprincipal) where socioid=psocioid;
		RETURN r;
		
	END IF;


	select * into r from valor_respuesta_matriz(ppreguntaid,nvalor,arrvalores);
	RETURN r;
END
$_$
	LANGUAGE 'plpgsql' VOLATILE;