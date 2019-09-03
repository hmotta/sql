drop TYPE rfinancierarural2 cascade;
CREATE TYPE rfinancierarural2 AS (
	RFC character varying(16),
	No_de_cliente_del_acreditado character varying(15),
	Nombres_del_acreditado_o_Razon_Social character varying(30),
	Apellido_Paterno character varying(30),
	Apellido_Materno character varying(30),
	CURP character varying(20),
	Tipo_de_persona character varying(32),
	Tipo_de_productor character(3),
	Figura_juridica character varying(30),
	Sexo character varying(6),
	Entidad_federativa_de_nacimiento character varying(20),
	Fecha_de_nacimiento date,
	Estado character varying(20),
	Municipio character varying(50),
	Localidad character varying(50),
	Telefono character varying(20),
	Celular character varying(20),
	Correo_electronico character(1),
	Calle character varying(30),
	No_Exterior character varying(15)

);


CREATE or replace FUNCTION spsfinancierarural2(date,character varying) RETURNS SETOF rfinancierarural2
    AS $_$
declare
	pfecha alias for $1;
	pdisposicion alias for $2;
	r rfinancierarural2%rowtype;
begin
  for r in
       select
	--1 RFC
		trim(su.rfc),
	--2 No de cliente del acreditado
		trim(s.clavesocioint),
	--3 Nombre (s) del acreditado (o Razon Social)
		trim(su.nombre),
	--4 Apellido Paterno
		trim(su.paterno),
	--5 Apellido Materno
		trim(su.materno),
	--6 CURP
		trim(su.curp),
	--7 Tipo de persona
		'Fisica',
	--8 Tipo de productor
		'PD1',
	--9 Figura juridica
		'PERSONA FiSICA',
	--10 Sexo
		(case when so.sexo=0 then 'Hombre' else 'Mujer' end),
	--11 Entidad federativa de nacimiento
		(select nombreestadomex from estadosmex ed, ciudadesmex cd where cd.ciudadmexid=so.ciudadmexid and cd.estadomexid=ed.estadomexid),
	--12 Fecha de nacimiento
		to_char(su.fecha_nacimiento,'DD/MM/YYYY'),
	--13 Estado
		trim(e.nombreestadomex),
	--14 Municipio
		trim(c.nombreciudadmex),
	--15 Localidad
		trim(d.comunidad),
	--16 Telefono
		trim(d.teldomicilio),
	--17 Celular
		(select celular from extensionsujeto where sujetoid=su.sujetoid),
	--18 Correo electronico
		null,
	--19 Calle
		trim(d.calle),
	--20 No. Exterior
		d.numero_ext
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
		e.estadomexid=c.estadomexid --and
		--cd.disposicionid=pdisposicion
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