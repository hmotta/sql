drop type rformatocreditopatmir cascade;

CREATE TYPE rformatocreditopatmir AS (
	folio_if character(4),
	clave_socio_cliente character varying(18),
	nombre character varying(100),
	no_de_contrato character varying(18),
	sucursal character varying(16),
	clasificacion_del_credito character varying(25),
	producto_de_credito character varying(30),
	modalidad_de_pago character varying(50),
	fecha_de_otorgamiento character(10),
	monto_original numeric,
	fecha_de_vencimiento character(10),
	tasa_ordinaria_nominal_anual numeric,
	tasa_moratoria_nominal_anual numeric,
	plazo_del_credito_meses numeric,
	frecuencia_de_pago_capital integer,
	frecuencia_de_pago_intereses integer,
	dias_de_mora integer,
	capital_vigente numeric,
	capital_vencido numeric,
	intereses_devengados_no_cobrados_vigente numeric,
	intereses_devengados_no_cobrados_vencido numeric,
	intereses_devengados_no_cobrados_cuentas_de_orden numeric,
	fecha_ultimo_pago_capital character varying(12),
	monto_ultimo_pago_capital numeric,
	fecha_ultimo_pago_intereses character varying(12),
	monto_ultimo_pago_intereses numeric,
	renovado_reestructurado_o_normal character varying(12),
	vigente_o_vencido character varying(12),
	monto_garantia_liquida numeric,
	tipo_de_tasa_ordinaria_nominal character varying(17),
	tipo_garantia_adicional character varying(16),
	monto_garantia_adicional numeric,
	asesor_del_credito character(12),
	referenciaprestamo character varying(18),
	fechaingreso character(10),
	cat numeric
);



CREATE or replace FUNCTION spscreditopatmir(date, date) RETURNS SETOF rformatocreditopatmir
    AS $_$
declare

	pfechaingreso alias for $1;
	pfecha alias for $2;
  
  r rformatocreditopatmir%rowtype;
  pposicion integer;
  pnombre character varying(40);
  i int;
begin

  i:=1;
  for r in
       select
	--1 folio
		'0017',
	--2 clave socio
		trim(s.clavesocioint),
	--3 paterno
		--(case when su.paterno = null or su.paterno = ' ' or su.paterno = '' or su.paterno = 'X' then 'NO PROPORCIONADO' else trim(su.paterno) end),
	--4 materno 
		--(case when su.materno = null or su.materno = ' ' or su.materno = '' or su.materno = 'X' then 'NO PROPORCIONADO' else trim(su.materno) end),
	--5 primer_nombre  
		trim(su.nombre)||' '||(case when su.paterno = null or su.paterno = ' ' or su.paterno = '' or su.paterno = 'X' then 'NO PROPORCIONADO' else trim(su.paterno) end)||' '||(case when su.materno = null or su.materno = ' ' or su.materno = '' or su.materno = 'X' then 'NO PROPORCIONADO' else trim(su.materno) end),
	--segundo
	--'',
	--6 creditos-numero de contrato 
		(select substring(sucid,1,3) from empresa where empresaid=1)||substring(p.referenciaprestamo,1,6)||substring(p.referenciaprestamo,8,10),
	--7 sucursal
		(select Rtrim(nombresucursal) from empresa where empresaid=1),
	--8 clasificacion del credito consumo, vivienda, comercial
		(case when Rtrim(p.clavefinalidad)='001' then 'COMERCIAL' else (case when Rtrim(p.clavefinalidad)='002' then 'CONSUMO' else 'VIVIENDA' end) end),
	--9 producto de credito descripcion
		Rtrim(tp.desctipoprestamo),
	--10 modalidad de pago
		(case when Rtrim(p.numero_de_amor) >1 then 'PAGO PERIODICO DE CAPITAL E INTERESES' else 'PAGO UNICO DE CAPITAL E INTERESES AL VENCIMIENTO' end),
	--11 fecha de otorgamiento
		to_char(p.fecha_otorga,'DD/MM/YYYY'),
	--12 monto original del prestamo 
		to_char(p.montoprestamo,'99999999.99'),
	--13 fecha de vencimiento
		to_char(p.fecha_vencimiento,'DD/MM/YYYY'),
	--14 tasa ordinario nominal anual 
		to_char(p.tasanormal,'999999.99'),
	--15 tasa moratoria nominal anual 
		to_char(p.tasa_moratoria,'999999.99'),
	--16 plazo en meses 
		(case when p.dias_de_cobro=7 then (p.numero_de_amor/4) else (case when p.dias_de_cobro=14 then (p.numero_de_amor/2) else (case when p.dias_de_cobro=15 then (p.numero_de_amor/2) else (case when p.dias_de_cobro=0 then (p.numero_de_amor/1) else (case when p.dias_de_cobro=29 then (p.numero_de_amor/1) else (case when p.dias_de_cobro=30 then (p.numero_de_amor/1) else (case when p.dias_de_cobro=31 then (p.numero_de_amor/1)   else (p.numero_de_amor/1) end) end) end) end) end) end) end),
	--17 frecuencia de pago en capital
		(case when p.dias_de_cobro=0 then 30 else p.dias_de_cobro end),
	--18 frecuencia de pago en interes  
		(case when p.dias_de_cobro=0 then 30 else p.dias_de_cobro end),
	--19 dias de mora 
		pr.diasvencidos,
	--20 capital vigente
		to_char(pr.saldovencidomenoravencido,'99999999.99'),
	--21 capital vencido
		to_char(pr.saldovencidomayoravencido,'99999999.99'),
	--22 intereses devengamos no cobrados vigente
		(case when  pr.diasvencidos <= pr.diastraspasoavencida then interesdevengadomenoravencido else 0 end),
	--23 intereses devengamos no cobrados vencido
		(case when  pr.diasvencidos > pr.diastraspasoavencida then interesdevengadomenoravencido else 0 end),
	--24 intereses devengados no cobrados en cuentas de orden
		round(pr.interesdevengadomayoravencido,2),
	--25 fecha de ultimo abono a capital
		(case when pr.pagocapitalenperiodo > 0 then to_char(pr.ultimoabono,'DD/MM/YYYY') else Rtrim('') end),
	--26 monto ultimo a capital
		to_char(pr.pagocapitalenperiodo,'99999999.99'),
	--27 fecha de ultimo pago intereses
		(case when pr.pagointeresenperiodo > 0 then to_char(pr.ultimoabonointeres,'DD/MM/YYYY') else Rtrim('') end),
	--28 monto ultimo pago intereses
		to_char(pr.pagointeresenperiodo,'99999999.99'),
	--29 renovado , reestructurado o normal
		(case when  p.renovado=1  then 'RENOVADO' else 'NORMAL' end),
	--30 vigente o vencido
		(case when Rtrim(pr.diasvencidos) <=89 then 'VIGENTE' else 'VENCIDO' end),
	--31 monto garantia liquida
		to_char(p.monto_garantia,'99999999.99'),
	--32 tipo de tasa ordinaria nominal
		'SALDOS INSOLUTOS',
	--tipo_garantia_adicional character varying(16),
		--'Aval',
		(select  * from spsgarantiaprestamo(p.prestamoid)) as tipogar,

	--monto_garantia_adicional character(12),
		0.00,
	--asesor_del_credito
	--'stapia',
		p.usuarioid,
	--33 referecnia del credito 
		p.referenciaprestamo,
	--34 fecha de alta
		so.fechaingreso,
	--35 cat
		p.cat
	from precorte pr, 
		prestamos p, 
		socio s, 
		solicitudingreso so, 
		sujeto su,
		domicilio d,
		colonia col,
		ciudadesmex c,
		estadosmex e,
		tipoprestamo tp
	where 
		pr.fechacierre = pfecha  --modificado el 07 de septiembre del 2012, se agrego el tipo 05
		--and so.personajuridicaid = 0 
		and p.prestamoid = pr.prestamoid 
		and s.socioid = p.socioid 
		and su.sujetoid=s.sujetoid 
		and so.socioid=s.socioid 
		and d.sujetoid=su.sujetoid 
		and col.coloniaid=d.coloniaid 
		and c.ciudadmexid=d.ciudadmexid 
		and e.estadomexid=c.estadomexid 
		and p.tipoprestamoid=tp.tipoprestamoid 
		
		and p.tipoprestamoid<>'CAS'
		--and s.clavesocioint in (select clave_socio_cliente from spssociopatmir(pfechaingreso,pfecha))
		--and p.fecha_otorga <= pfecha

  loop
   	--IF r.paterno = 'NO PROPORCIONADO' AND r.materno <> 'NO PROPORCIONADO' THEN
	--r.paterno = r.materno; r.materno = 'NO PROPORCIONADO';
	--END IF;
	
	--pnombre := r.primer_nombre;
	--pposicion := position(' ' in pnombre);
	--IF pposicion > 3 THEN
	--r.primer_nombre:=substring(pnombre,0,pposicion);
	--r.segundo :=substring(pnombre,pposicion+1,character_length(pnombre));
	--END IF;
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

CREATE or replace FUNCTION spscreditopatmirc(date, date) RETURNS SETOF rformatocreditopatmir
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
	nombre character varying(100),
	no_de_contrato character varying(18),
	sucursal character varying(16),
	clasificacion_del_credito character varying(25),
	producto_de_credito character varying(30),
	modalidad_de_pago character varying(50),
	fecha_de_otorgamiento character(10),
	monto_original numeric,
	fecha_de_vencimiento character(10),
	tasa_ordinaria_nominal_anual numeric,
	tasa_moratoria_nominal_anual numeric,
	plazo_del_credito_meses numeric,
	frecuencia_de_pago_capital integer,
	frecuencia_de_pago_intereses integer,
	dias_de_mora integer,
	capital_vigente numeric,
	capital_vencido numeric,
	intereses_devengados_no_cobrados_vigente numeric,
	intereses_devengados_no_cobrados_vencido numeric,
	intereses_devengados_no_cobrados_cuentas_de_orden numeric,
	fecha_ultimo_pago_capital character varying(12),
	monto_ultimo_pago_capital numeric,
	fecha_ultimo_pago_intereses character varying(12),
	monto_ultimo_pago_intereses numeric,
	renovado_reestructurado_o_normal character varying(12),
	vigente_o_vencido character varying(12),
	monto_garantia_liquida numeric,
	tipo_de_tasa_ordinaria_nominal character varying(17),
	tipo_garantia_adicional character varying(16),
	monto_garantia_adicional numeric,
	asesor_del_credito character(12),
	referenciaprestamo character varying(18),
	fechaingreso character(10),
	cat numeric
)
        loop

          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

