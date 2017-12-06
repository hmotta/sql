CREATE TYPE rformatsolprestamo AS (
	clavesocio character varying(18),
	nombre text,
	nosolicitud integer,
	tipoprestamo character(40),
	desctipoprestamo character(30),
	fecha_solicitud character(10),
	monto_solicitado numeric,
	tasa_normal numeric,
	tasa_moratoria numeric,
	plazo integer,
	frecuencia integer,
	usuario_captura character(30),
	fecha_resultado character(10),
	fecha_entrega character(10),
	fecha_primerpago character(10),
	generado character(2),
	fecha_generacion character(10),
	referenciaprestamo character(18)
);

CREATE FUNCTION spssolprestamo(date, date) RETURNS SETOF rformatsolprestamo
    AS $_$
declare
	pfechaingreso alias for $1;
	pfecha alias for $2;
	r rformatsolprestamo%rowtype;
	pposicion integer;
	pnombre character varying(40);
	i int;
begin
	i:=1;
	for r in
select
--01-N򭥲o De Socio
	Rtrim(s.clavesocioint),
--02-Nombre
	trim(su.nombre)||' '||trim(su.paterno)||' '||trim(su.materno),
--03-Numero Solicitud
	so.nosolicitud,
--04-Tipo De Pr괴amo Solicitado
	so.tipoprestamoid,
--05-Descripcion tipo prestmao 
	(select desctipoprestamo from tipoprestamo where tipoprestamoid=so.tipoprestamoid),
--06-Fecha De Solicitud
	trim(to_char(so.fechasolicitud,'DD/MM/YYYY')),
--07-Monto Solicitado
	to_char(so.montosolicitado,'99999999.99'),
--08-Tasa Normal
	to_char(so.tasanormal,'999999.99'),
--09-Tasa Moratoria
	to_char(so.tasamoratorio,'999999.99'),
--10-Plazo  (12 meses, 36 meses, Etc
	(case when so.dias_de_cobro=7 then (so.abonospropuestos/4) else (case when so.dias_de_cobro=14 then (so.abonospropuestos/2) else (case when so.dias_de_cobro=15 then (so.abonospropuestos/2) else (case when so.dias_de_cobro=0 then (so.abonospropuestos/1) else (case when so.dias_de_cobro=29 then (so.abonospropuestos/1) else (case when so.dias_de_cobro=30 then (so.abonospropuestos/1) else (case when so.dias_de_cobro=31 then (so.abonospropuestos/1)   else (so.abonospropuestos/1) end) end) end) end) end) end) end),
--11-Frecuencia (Mensual, Semanal, cada n d..etc)
	(case when so.dias_de_cobro=0 then 30 else so.dias_de_cobro end),
--12-Usuario Que Apertura
	RTrim(so.usuarioid),
--13-Fecha  De Resultado (Seg򮠓olicitud)
	trim(to_char(so.fechacomite,'DD/MM/YYYY')),
--14-Fecha De Entrega (Seg򮠓olicitud)
	trim(to_char(so.fechaentrega,'DD/MM/YYYY')),
--15-Fecha De Primer Pago (Seg򮠓olicitud)
	trim(to_char(so.primerpago,'DD/MM/YYYY')),
--16-Generado (Si, No)
	(case when exists (select solicitudprestamoid from prestamos where solicitudprestamoid=so.solicitudprestamoid) then 'SI' else 'NO' end ),
--17-Fecha De Generaci󮮊	(case when exists (select solicitudprestamoid from prestamos where solicitudprestamoid=so.solicitudprestamoid) then (select fecha_otorga from prestamos where solicitudprestamoid=so.solicitudprestamoid) else null end ),
--18-Referencia
	(case when exists (select solicitudprestamoid from prestamos where solicitudprestamoid=so.solicitudprestamoid) then (select referenciaprestamo from prestamos where solicitudprestamoid=so.solicitudprestamoid) else '' end )
from socio s, 
	sujeto su,
	solicitudprestamo so
where s.socioid=so.socioid	
	and su.sujetoid=s.sujetoid
	and so.fechasolicitud >= pfechaingreso
	and so.fechasolicitud <= pfecha
order by fechasolicitud
loop
return next r;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.spssolprestamo(date, date) OWNER TO sistema;

--
-- Name: spssolprestamoc(date, date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE FUNCTION spssolprestamoc(date, date) RETURNS SETOF rformatsolprestamo
    AS $_$
declare
	pfechaingreso alias for $1;
	pfecha alias for $2;
	r rformatsolprestamo%rowtype;
	f record;
	dblink1 text;
	dblink2 text;
	i int;
begin
	i:=1;
	for f in
	select * from sucursales where vigente='S'
	loop
	raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;
	dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
	dblink2:='set search_path to public,'||f.esquema||';select * from  spssolprestamo('||''''||pfechaingreso||''''||','||''''||pfecha||''''||');';
	--dblink2:='set search_path to public,'||f.esquema||';select * from  spssolprestamo('||''''||pfecha||''''||');';
	--raise notice '% % ', dblink1,dblink2;
	for r in
	SELECT * FROM
	dblink(dblink1,dblink2) as
	t2(
	clavesocio character varying(18),
nombre text,
nosolicitud integer,
tipoprestamo character(40),
desctipoprestamo character(30),
fecha_solicitud character(10),
monto_solicitado numeric,
tasa_normal numeric,
tasa_moratoria numeric,
plazo integer,
frecuencia integer,
usuario_captura character(30),
fecha_resultado character(10), 
fecha_entrega character(10),
fecha_primerpago character(10),
generado character(2),
fecha_generacion character(10),
referenciaprestamo character(18)
)
loop
return next r;
end loop;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;