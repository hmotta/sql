drop TYPE rclientefinafim cascade;
CREATE TYPE rclientefinafim AS (
	ORG_ID character varying(15),
	ACRED_ID character varying(15),
	CURP character varying(20),
	IFE character varying(20),
	PRIMER_AP character varying(30),
	SEGUNDO_AP character varying(30),
	NOMBRE character varying(30),
	FECHA_NAC character (10),
	EDO_NAC character varying(20),
	SEXO character varying(6),
	TEL character(10),
	CVE_EDO_CIVIL character varying(15),
	EDO_RES character varying(20),
	MUNICIPIO character varying(50),
	LOCALIDAD character varying(50),
	CALLE character varying(30),
	NUMERO_EXTERIOR character varying(15),
	NUMERO_INTERIOR character varying(15),
	COLONIA character varying(100),
	CP character(5),
	METODOLOGIA character varying(15), 
	NOM_GRUPO character varying(25),
	ESTUDIOS character varying(20),
	ACTIVIDAD character varying(90),
	FECHA_INICIO_ACT_PRODUCTIVA character (10),
	UBICACION_NEGOCIO character varying(40),
	PERSONAS_TRABAJANDO integer,
	INGRESO_SEMANAL numeric,
	ROL_EN_HOGAR character varying(20),
	SUCURSAL character varying(15)
);


CREATE or replace FUNCTION spsclientefinafim(date) RETURNS SETOF rclientefinafim
    AS $_$
declare
	pfecha alias for $1;
	r rclientefinafim%rowtype;
begin
  for r in
       select
	--1 ORG_ID
		179,
	--2 ACRED_ID
		trim(s.clavesocioint),
	--3 CURP
		'',--trim(su.curp),
	--4 IFE
		'',
	--5 PRIMER_AP
		sburo(trim(su.paterno)),
	--6 SEGUNDO_AP
		sburo(trim(su.materno)),
	--7 NOMBRE
		sburo(trim(su.nombre)),
	--8 FECHA_NAC
		to_char(su.fecha_nacimiento,'DD/MM/YYYY'),
	--9 EDO_NAC
		(case when (select sburo(nombreestadomex) from estadosmex ed, ciudadesmex cd where cd.ciudadmexid=so.ciudadmexid and cd.estadomexid=ed.estadomexid)='VERACRUZ LLAVE' then 'VERACRUZ' else (select sburo(nombreestadomex) from estadosmex ed, ciudadesmex cd where cd.ciudadmexid=so.ciudadmexid and cd.estadomexid=ed.estadomexid) end),
	--10 SEXO
		(case when so.sexo=0 then 'HOMBRE' else 'MUJER' end),
	--11 TEL
		'',--trim(d.teldomicilio),
	--12 CVE_EDO_CIVIL
		(case when so.estadocivilid=0 then 'SOLTERO' else (case when so.estadocivilid=1 then 'CASADO' else (case when so.estadocivilid=2 then 'DIVORCIADO' else (case when so.estadocivilid=3 then 'VIUDO' else (case when so.estadocivilid=4 then 'UNION LIBRE' else 'SOLTERO' end) end) end) end) end),
	--13 EDO_RES
		sburo(trim(e.nombreestadomex)),
	--14 MUNICIPIO
		sburo(trim(c.nombreciudadmex)),
	--15 LOCALIDAD
		(case when trim(d.comunidad)='ACATLAN' then 'ACATLAN DE OSORIO' else (case when trim(d.comunidad)='ZAACHILA 2O' then 'ZAACHILA SEGUNDO' else (case when trim(d.comunidad)='BARRIO DEL NINO 2A SECCION' then 'BARRIO DEL NINO (SEGUNDA SECCION)' else sburo(trim(d.comunidad)) end) end) end),
	--16 CALLE
		sburo(trim(d.calle)),
	--17 NUMERO_EXTERIOR
		sburo(trim(d.numero_ext)),
	--18 NUMERO_INTERIOR
		'',--trim(d.numero_int),
	--19 COLONIA
		sburo(trim(col.nombrecolonia)),
	--20 CP
		lpad(trim(to_char(col.cp,'99999')),5,'0'),
	--21 METODOLOGIA
		(case when p.tipoprestamoid in ('N5','N53','N54') then 'GRUPAL' else 'INDIVIDUAL' end),
	--22 NOM_GRUPO
		(case when p.tipoprestamoid in ('N5','N53','N54') then (case when so.grupo<>'<NINGUNO>' then trim(so.grupo) else '' end) else '' end),
	--23 ESTUDIOS
		(case when so.nivelestudiosid=0  then 'NINGUNA' else (case when so.nivelestudiosid=1  then 'PRIMARIA' else (case when so.nivelestudiosid=2  then 'SECUNDARIA' else (case when so.nivelestudiosid=3  then 'BACHILLERATO' else (case when so.nivelestudiosid=4  then 'LICENCIATURA' else (case when so.nivelestudiosid=5  then 'POSTGRADO' else (case when so.nivelestudiosid=6  then 'POSTGRADO' else 'NINGUNA' end) end) end) end) end) end) end),
	--24 ACTIVIDAD
		(select actividad_finafim from ocupacion_actividad_finafim where ocupacion=trim(so.ocupacion)),
	--25 FECHA_INICIO_ACT_PRODUCTIVA
		to_char(so.fechaingreso,'DD/MM/YYYY'),
	--26 UBICACION_NEGOCIO
		cd.datoadicional1,
	--27 PERSONAS_TRABAJANDO
		1,
	--28 INGRESO_SEMANAL
		(select trunc(max(sueldo+otrosingresos)/4,2) from solicitudprestamo where socioid=s.socioid),
	--29 ROL_EN_HOGAR
		'JEFE',
	--30 SUCURSAL
		(select trim(nombresucursal) from empresa)
	from 
		carteradisposicion cd,
		prestamos p, 
		socio s, 
		sujeto su,
		solicitudingreso so,
		domicilio d,
		colonia col,
		ciudadesmex c,
		estadosmex e
	where 
		p.prestamoid=cd.prestamoid and
		s.socioid = p.socioid and
		su.sujetoid=s.sujetoid and
		so.socioid=s.socioid and
		d.sujetoid=su.sujetoid and
		col.coloniaid=d.coloniaid and
		c.ciudadmexid=d.ciudadmexid and
		e.estadomexid=c.estadomexid and
		cd.disposicionid='FOMMUR00002'
  loop
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

/*CREATE or replace FUNCTION spscreditopatmirc(date, date) RETURNS SETOF rformatocreditopatmir
    AS $_$
declare

  pfechaingreso alias for $1;
  pfecha alias for $2;

  r rformatocreditopatmir%rowtype;

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
	dblink2:='set search_path to public,'||f.esquema||';select * from  spscreditopatmir('||''''||pfechaingreso||''''||','||''''||pfecha||''''||');';
        --dblink2:='set search_path to public,'||f.esquema||';select * from  spscreditopatmir('||''''||pfecha||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	folio_if character(4),
	clave_socio_cliente character varying(18),
	--paterno character varying(26),
	--materno character varying(26),
	nombre character varying(100),
	--segundo character varying(100),
	no_de_contrato character varying (18),
	sucursal character varying(16),
	clasificacion_del_credito character varying(25),
	producto_de_credito character varying(30),
	modalidad_de_pago character varying (50),
	fecha_de_otorgamiento character(10),
	monto_original character(12),
	fecha_de_vencimiento character(10),
	tasa_ordinaria_nominal_anual character(12),
	tasa_moratoria_nominal_anual character(12),
	plazo_del_credito_meses numeric,
	frecuencia_de_pago_capital integer,
	frecuencia_de_pago_intereses integer,
	dias_de_mora integer,
	capital_vigente character(12),
	capital_vencido character(12),
	intereses_devengados_no_cobrados_vigente character(12),
	intereses_devengados_no_cobrados_vencido character(12),
	intereses_devengados_no_cobrados_cuentas_de_orden character(12),
	fecha_ultimo_pago_capital character varying(12),
	monto_ultimo_pago_capital character(12),
	fecha_ultimo_pago_intereses character varying(12),
	monto_ultimo_pago_intereses character(12),
	renovado_reestructurado_o_normal character varying(12),
	vigente_o_vencido character varying(12),
	monto_garantia_liquida character(12),
	tipo_de_tasa_ordinaria_nominal character varying(17),
	referenciaprestamo character varying(18),
	fechaingreso character(10)	
)
        loop

          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.spscreditopatmirc(date, date) OWNER TO sistema;

--
-- Name: spscreditosrelacionados(integer, integer, date, character); Type: FUNCTION; Schema: public; Owner: sistema
--

*/
