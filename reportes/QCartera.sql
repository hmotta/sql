drop TYPE tcarteracnbv cascade;
CREATE TYPE tcarteracnbv AS (
	clave_socio_cliente character varying(18),	--01 - NOMBRE DEL ACREDITADO
	nombresocio character varying(80),			--02 - NUMERO DE SOCIO
	curp character(20),							--03 - CURP
	num_credito character(18),					--04 - NO. DE CONTRATO
	sucursal character varying(16),				--05 - SUCURSAL 
	clasificacion character varying(30),		--06 - CLASIFICACION DEL CREDITO
	producto_de_credito character(30),			--07 - PRODUCTO DE CREDITO
	fecha_ortorgamiento date,
	fecha_vencimiento date,
	modalidad_de_pago character varying (50),
	monto_original numeric,
	frecuencia_de_pago integer,
	frecuencia_de_pago_interes integer,
	tasa_interes numeric,
	fecha_ultimo_pago_capital date,
	ultimo_pago_capital numeric,
	fecha_ultimo_pago_interes date,
	ultimo_pago_interes numeric,
	fecha_primer_incumplimiento date,
	dias_mora integer,
	tipo_credito character varying (30),
	emproblemado character varying (13), 
	situacion_del_credito character varying (50),
	cargo_del_acreditado_parte_relacionada character varying (30),
	capital_vigente numeric,
	capital_vencido numeric,
	intereses_vigentes numeric,
	intereses_vencidos numeric,
	intereses_moratorios numeric,
	intereses_capitalizados numeric,
	tipo_acreditado integer,
	tipo_cartera_para_calificacion character(1),
	calificacion_parte_cubierta character(1),
	calificacion_parte_expuesta character(1),
	monto_estimacion_parte_cubierta character(1),
	monto_estimacion_parte_expuesta character(1),
	estimaciones_prev_adicionales character(1),
	cuenta_garantia_liquida character varying (30),
	monto_garantia_liquida numeric,
	monto_garantia_prendaria character(1),
	monto_garantia_hipotecaria  character(1),
	fecha_consulta_buro date
	);

CREATE or replace FUNCTION spscarteracnbv(date) RETURNS SETOF tcarteracnbv
    AS $_$
declare
	pfechacierre alias for $1;
  
  r tcarteracnbv%rowtype;
  psucid char(4);

begin

for r in
select 
	s.clavesocioint,
	su.nombre||' '||su.paterno||' '||su.materno as Nombre,
	(case when length(su.curp)<18 then '' else su.curp end),
	p.referenciaprestamo,
	(select nombresucursal from empresa) as NombreSucursal,
	finalidaddefault(pr.tipoprestamoid),
	(select desctipoprestamo from tipoprestamo where tipoprestamoid=p.tipoprestamoid) as producto,
	to_char(p.fecha_otorga,'DD/MM/YYYY') as fechaotorgamiento,
	to_char(p.fecha_vencimiento,'DD/MM/YYYY') as fechavencimiento,
	(case when p.numero_de_amor > 1 then 'Pago periódico de capital e intereses' else 'Pago único de capital e intereses al vencimiento' end) as modalidadpago,
	p.montoprestamo,
	(case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end) as frecuenciacap,
	(case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end) as frecuenciaint,
	p.tasanormal,
	pr.ultimoabono,
	pr.pagocapitalenperiodo,
	pr.ultimoabonointeres,
	pr.pagointeresenperiodo,
	(case when pr.diasvencidos>0 then to_char(pr.primerincumplimiento,'DD/MM/YYYY') else null end) as primera_amortizacion_no_cubierta,
	pr.diasvencidos as diasmora,
	'NORMAL',
	'' as emproblemado,
	(case when pr.diasvencidos <= pr.diastraspasoavencida and pr.tipoprestamoid not in ('T1','T2','T3','R1','R2','R3') then (case when pr.diasvencidos>0 then 'Vigente con pagos vencidos' else 'Vigente sin pagos vencidos' end) else (case when pr.diasvencidos > pr.diastraspasoavencida and pr.tipoprestamoid not in ('T1','T2','T3','R1','R2','R3') then (case when exists (select prestamoid from carteracobrador where prestamoid=pr.prestamoid and cobradorid in (select cobradorid from cobradores natural join sujeto where (paterno='Franco' and materno='Salcedo' and nombre='Sergio Eduardo') or (paterno='Rojas' and materno='Islas' and nombre='Edmundo') or (paterno='Mendez' and materno='Diaz' and nombre='Alberto Anival'))) then 'Vencido en litigio' else 'Vencido en tramite administrativo' end) else (case when pr.diasvencidos <= pr.diastraspasoavencida and pr.tipoprestamoid in ('T1','T2','T3') then (case when pr.diasvencidos>0 then 'Vigente con pagos vencidos' else 'Vigente sin pagos vencidos' end) else (case when pr.diasvencidos > pr.diastraspasoavencida and pr.tipoprestamoid in ('T1','T2','T3') then (case when exists (select prestamoid from carteracobrador where prestamoid=pr.prestamoid and cobradorid in (select cobradorid from cobradores natural join sujeto where (paterno='Franco' and materno='Salcedo' and nombre='Sergio Eduardo') or (paterno='Rojas' and materno='Islas' and nombre='Edmundo') or (paterno='Mendez' and materno='Diaz' and nombre='Alberto Anival'))) then 'Vencido en litigio' else 'Vencido en tramite administrativo' end) else (case when pr.diasvencidos <= pr.diastraspasoavencida and pr.tipoprestamoid in ('R1','R2','R3') then (case when pr.diasvencidos>0 then 'Vigente con pagos vencidos' else 'Vigente sin pagos vencidos' end) else (case when pr.diasvencidos > pr.diastraspasoavencida and pr.tipoprestamoid in ('R1','R2','R3') then (case when exists (select prestamoid from carteracobrador where prestamoid=pr.prestamoid and cobradorid in (select cobradorid from cobradores natural join sujeto where (paterno='Franco' and materno='Salcedo' and nombre='Sergio Eduardo') or (paterno='Rojas' and materno='Islas' and nombre='Edmundo') or (paterno='Mendez' and materno='Diaz' and nombre='Alberto Anival'))) then 'Vencido en litigio' else 'Vencido en tramite administrativo' end) end) end) end) end) end) end),
	(select puesto from empleado e, relacionados re where re.socioidem=e.socioid and re.socioidre=p.socioid limit 1),
	pr.saldovencidomenoravencido,
	pr.saldovencidomayoravencido,
	(case when  pr.diasvencidos <= pr.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as devengadovigente,
	(case when  pr.diasvencidos > pr.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as devengadovencido,
	(pr.interesdevengadomayoravencido+pr.interesdevmormayor) as int_moratorios,
	0 as intereses_capitalizados,
	(case when exists (select * from conoceatucliente where socioid=p.socioid and estatus='Directivo') then 2 else (case when exists (select * from relacionados where socioidre=p.socioid and socioidem in (select socioid from conoceatucliente where estatus='Directivo')) then 3 else 0 end) end),
	'' as tipo_cartera_calificacion,
	'' as calificacion_cubierta, 
	'' as calificacion_expuesta, 
	'' as estimacion_parte_cubierta, 
	'' as estimacion_parte_expuesta,
	'' as estimaciones_prev_adic,
	'AHORRO SOLUCION',
	pr.depositogarantia-(trunc(pr.depositogarantia/500)*500),
	0,
	0 as garantiahipotecaria,
	null as fecha_consulta_soc_cred 
	from precorte pr,prestamos p,socio s,sujeto su 
	where p.prestamoid=pr.prestamoid and 
	s.socioid=p.socioid and 
	su.sujetoid=s.sujetoid and 
	pr.fechacierre = pfechacierre order by s.clavesocioint


loop 
  
  return next r;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
