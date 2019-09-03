drop TYPE rfinancierarural cascade;
CREATE TYPE rfinancierarural AS (
	prestamoid integer,
	No_de_disposicion character(18),
	RFC character varying(16),
	No_de_credito_asignado_al_acreditado_final character varying(11),
	Fecha_de_vencimiento_del_Contrato date,
	Tipo_de_credito character varying(20),
	Subramas character varying(20),
	Producto_Cultivo character varying(35),
	Destino_del_credito character varying(50),
	Tipo_de_unidad character varying(20),
	Unidades_a_habilitar numeric,
	Ciclo_agricola character varying(20),
	Riego_o_temporal character varying(20),
	Fecha_de_apertura date,
	Fecha_de_vencimiento date,
	Monto_del_credito numeric,
	Monto_Total_del_Proyecto numeric,
	Monto_Otorgado_Financiera_Rural numeric,
	Numero_de_pagares integer,
	Monto_de_pagares numeric,
	Periodicidad_de_pagos character varying(20),
	Tipo_de_moneda character varying(20),
	Estatus_del_credito character varying(20),
	No_de_dias_de_atraso integer,
	Capital_vigente numeric,
	Intereses_vigentes numeric,
	Capital_vencido numeric,
	Intereses_vencidos numeric,
	Saldo_total numeric,
	Fecha_de_saldo date,
	Tipo_de_tasa character varying(20),
	Base_de_referencia character varying(20),
	Puntos_adicionales_a_la_base character varying(20),
	Periodicidad_de_Tasa character varying(20),
	Tasa numeric,
	Apoyo_FONAGA character varying(20),
	Apoyo_de_otro_programa_gubernamental character varying(20),
	No_Ministracion integer,
	Tipo_de_garantia character varying(50),
	Valor_garantia_prendaria numeric,
	Valor_garantia_hipotecaria numeric,
	Valor_garantia_fiduciaria numeric,
	Valor_garantia_natural numeric,
	Valor_garantia_liquida numeric,
	Valor_garantia_solidaria numeric,
	Valor_garantia_aval numeric,
	Valor_de_la_garantia numeric,
	Registro_unico_de_Garantias character varying(20),
	Datos_de_Inscripcion character varying(20),
	Nombre_Obligado_Solidario character varying(200),
	Calificacion_cliente_o_credito character varying(20)
);


CREATE or replace FUNCTION spsfinancierarural(date) RETURNS SETOF rfinancierarural
    AS $_$
declare
	pfecha alias for $1;
	r rfinancierarural%rowtype;
	l record;
begin
  for r in
       select
	--X Prestamoid
		p.prestamoid,
	--1 No de disposicion
		cd.disposicionid,
	--2 RFC
		trim(su.rfc),
	--3 No de credito asignado al acreditado final
		(select substring(sucid,1,4) from empresa where empresaid=1)||trim(p.referenciaprestamo),
	--x Fecha de vencimiento del Contrato
		to_char(p.fecha_vencimiento,'DD/MM/YYYY'),
	--4 Tipo de credito
		'SIMPLE',
	--5 Subramas
		'COMERCIAL',
	--6 Producto/Cultivo
		'Comercio al por mayor, otros',
	--7 Destino del credito
		(case when (select subfinalidad1 from finalidad where solicitudprestamoid=p.solicitudprestamoid) in ('PAGO DE DEUDAS') then 'Descuento de cartera' else (case when (select subfinalidad1 from finalidad where solicitudprestamoid=p.solicitudprestamoid) in ('GASTOS PERSONALES','DEL SOCIO','PAGO DE COLEGIATURAS') then 'Diversos' else (case when (select subfinalidad1 from finalidad where solicitudprestamoid=p.solicitudprestamoid) in ('CAPITAL DE TRABAJO','COMPRA DE MAQUINARIA','PAGO DE TRACTOR','REFACCIONES VARIAS','MUEBLES VARIOS') then 'Herramientas, maquinaria y equipo' else (case when (select subfinalidad1 from finalidad where solicitudprestamoid=p.solicitudprestamoid) in ('NEGOCIO NUEVO','COMPRA DE ARTICULOS NAVIDEÑOS') then 'Materias primas e Insumos' else (case when (select subfinalidad1 from finalidad where solicitudprestamoid=p.solicitudprestamoid) in ('REMODELACION O AMPLIACION') and (select subfinalidad2 from finalidad where solicitudprestamoid=p.solicitudprestamoid) in ('MEJORAR CONDICIONES DE VIVIENDA','MANTENIMIENTO DE VIVIENDA') then 'Construcción' else ('Materias primas e Insumos') end) end) end) end) end),
	--8 Tipo de unidad
		'Otros',
	--9 Unidades a habilitar
		1.0,
	--10 Ciclo agricola
		'No Aplica',
	--11 Riego o temporal
		'No Aplica',
	--12 Fecha de apertura
		to_char(p.fecha_otorga,'DD/MM/YYYY'),
	--13 Fecha de vencimiento
		to_char(p.fecha_vencimiento,'DD/MM/YYYY'),
	--14 Monto del credito
		trunc(p.montoprestamo,2),
	--15 Monto Total del Proyecto
		trunc(p.montoprestamo,2),
	--16 Monto Otorgado Financiera Rural
		trunc(p.montoprestamo*0.8,2),
	--17 Numero de pagares
		1,
	--18 Monto de pagares
		trunc(p.montoprestamo,2),
	--19 Periodicidad de pagos
		(case when p.meses_de_cobro=2 then '2 Meses' else (case when p.meses_de_cobro=3 then '3 Meses' else ( case when p.dias_de_cobro=7 then 'Semanal' else ( case when p.dias_de_cobro=14 then 'Catorcenal' else ( case when p.dias_de_cobro=15 then 'Quincenal' else '1 Mes' end) end) end) end) end),
	--20 Tipo de moneda
		'Pesos',
	--21 Estatus del credito
		(case when p.saldoprestamo=0 then 'Saldado' else (case when (pfecha-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfecha))) >89 then 'Vencido' else 'Vigente' end) end),
	--22 No de dias de atraso
		(case when p.saldoprestamo>0 then (case when (pfecha-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfecha)))>0 then (pfecha-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfecha))) else 0 end) else 0 end),
	--23 Capital vigente
		(case when p.saldoprestamo>0 then (case when (pfecha-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfecha))) >89 then 0 else trunc(p.saldoprestamo,2) end) else 0 end),
	--24 Intereses vigentes
		(case when p.saldoprestamo>0 then (case when (pfecha-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfecha))) >89 then 0 else (SELECT trunc(interes,2) FROM spscalculopago(p.prestamoid)) end) else 0 end),
	--25 Capital vencido
		(case when p.saldoprestamo>0 then (case when (pfecha-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfecha))) >89 then trunc(p.saldoprestamo,2) else 0 end ) else 0 end),
	--26 Intereses vencidos
		(case when p.saldoprestamo>0 then (case when (pfecha-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfecha))) >89 then (SELECT trunc(interes,2) FROM spscalculopago(p.prestamoid)) else 0 end) else 0 end),
	--27 Saldo total
		trunc(p.saldoprestamo,2),
	--28 Fecha de saldo
		to_char(pfecha,'DD/MM/YYYY'),
	--29 Tipo de tasa
		'Fija',
	--30 Base de referencia
		'No Aplica',
	--31 Puntos adicionales a la base
		'',
	--32 Periodicidad de Tasa
		'Anual',
	--33 Tasa
		trunc(p.tasanormal,2),
	--34 Apoyo FONAGA
		'Sin apoyo',
	--35 Apoyo de otro programa gubernamental 
		'',
	--36 No. Ministracion
		1,
	--37 Tipo de garantia
		(case when (select count(*) from avales where prestamoid=p.prestamoid)>0 then 'Personales (Aval, obligado solidario)' else 'Fiduciaria o Liquidas' end),
	--00 Valor garantia prendaria
		0,
	--00 Valor garantia hipotecaria
		0,
	--00 Valor garantia fiduciaria
		0,
	--00 Valor garantia natural
		0,
	--00 Valor garantia liquida
		0,
	--00 Valor garantia solidaria
		0,
	--00 Valor garantia aval
		0,
	--38 Valor de la garantia
		0,
	--39 Registro unico de Garantias
		'',
	--40 Datos de Inscripcion
		'',
	--41 Nombre Obligado Solidario
		'',
	--42 Calificacion cliente o credito
		'Habitual'	
	from 
		carteradisposicion cd,
		prestamos p, 
		socio s,
		sujeto su
	where 
		p.prestamoid=cd.prestamoid and
		s.socioid = p.socioid and
		su.sujetoid=s.sujetoid
  loop
	for l in
		select (select su.nombre||' '||su.paterno||' '||su.materno from sujeto su where su.sujetoid=a.sujetoid) as nombre from avales a where prestamoid =r.prestamoid
	loop
		if r.Nombre_Obligado_Solidario='' then
			r.Nombre_Obligado_Solidario:=l.nombre;
		else
			r.Nombre_Obligado_Solidario:=r.Nombre_Obligado_Solidario||', '||l.nombre;
		end if;
	end loop;
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
