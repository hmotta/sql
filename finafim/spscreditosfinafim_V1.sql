drop TYPE rcreditosfinafim cascade;
CREATE TYPE rcreditosfinafim AS (
	No_de_disposicion character(18),
	ORG_ID character varying(11),
	ACRED_ID character varying(15),
	CREDITO_ID character varying(11),
	DESTINO_CREDITO character varying(90),
	MONTO_CREDITO numeric,
	FECHA_ENTREGA character(10),
	FECHA_VENCIMIENTO character(10),
	TASA_MENSUAL numeric,
	TIPO_TASA character varying(20),
	FRECUENCIA_PAGOS character varying(20),
	finalidad character varying(90),
	subfinalidad1 character varying(90),
	subfinalidad2 character varying(90)
);


CREATE or replace FUNCTION spscreditosfinafim(date) RETURNS SETOF rcreditosfinafim
    AS $_$
declare
	pfecha alias for $1;
	r rcreditosfinafim%rowtype;
	l record;
begin
  for r in
       select
	--X 
		trim(cd.disposicionid),
	--1 ORG_ID
		179,
	--2 ACRED_ID
		trim(s.clavesocioint),
	--3 CREDITO_ID
		(select substring(sucid,1,4) from empresa where empresaid=1)||trim(p.referenciaprestamo),
	--4 DESTINO_CREDITO
		(select destino_finafim from finalidad_destino_finafim where finalidad=(select trim(finalidad) from finalidad where solicitudprestamoid=p.solicitudprestamoid) and subfinalidad1=(select trim(subfinalidad1) from finalidad where solicitudprestamoid=p.solicitudprestamoid) and subfinalidad2=(select trim(subfinalidad2) from finalidad where solicitudprestamoid=p.solicitudprestamoid)),
	--5 MONTO_CREDITO
		trunc(p.montoprestamo,2),
	--6 FECHA_ENTREGA
		to_char(p.fecha_otorga,'DD/MM/YYYY'),
	--7 FECHA_VENCIMIENTO
		to_char(p.fecha_vencimiento,'DD/MM/YYYY'),
	--8 TASA_MENSUAL
		trunc((p.tasanormal/12)/100,4),
	--9 TIPO_TASA
		'SALDOS INSOLUTOS',
	--7 FRECUENCIA_PAGOS
		(case when p.meses_de_cobro=2 then 'MENSUAL' else (case when p.meses_de_cobro=3 then 'MENSUAL' else ( case when p.dias_de_cobro=7 then 'SEMANAL' else ( case when p.dias_de_cobro=14 then 'CATORCENAL' else ( case when p.dias_de_cobro=15 then 'QUINCENAL' else ( case when p.dias_de_cobro=1 then 'PAGO UNICO' else 'MENSUAL' end) end) end) end) end) end),
		(select trim(finalidad) from finalidad where solicitudprestamoid=p.solicitudprestamoid),
		(select trim(subfinalidad1) from finalidad where solicitudprestamoid=p.solicitudprestamoid),
		(select trim(subfinalidad2) from finalidad where solicitudprestamoid=p.solicitudprestamoid)
	from 
		carteradisposicion cd,
		prestamos p, 
		socio s,
		sujeto su
	where 
		p.prestamoid=cd.prestamoid and
		s.socioid = p.socioid and
		su.sujetoid=s.sujetoid and 
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
