--23/02/2016 se agrega la parte de relacionados
drop type tregulatorioC451 cascade;
create type tregulatorioC451 as (
	cve_subreporte varchar(4),
	cve_municipio_siti varchar(10),
	cve_estado varchar(3),
	dat_numero_dedudor varchar(20),
	cve_persona integer,
	dat_nombre_acred varchar(200),
	dat_primer_apellido varchar(200),
	dat_segundo_apellido varchar(200),
	dat_rfc varchar(13),
	dat_curp_acred varchar(18),
	cve_genero_acred integer,
	dat_numero_credito varchar(20),
	dat_nombre_sucursal varchar(200),
	cve_clasfica_contable char(12),
	dat_producto_credito varchar(200),
	dat_fecha_disposicion char(8),
	dat_fecha_vencimiento char(8),
	cve_modalidad_pago integer,
	dat_monto_credito integer,
	dat_frec_pagos_capital integer,
	dat_frec_pagos_interes integer,
	dat_tasa_interes numeric,
	dat_fecha_ult_pago_capital char(8),
	dat_monto_ult_pago_capital integer,
	dat_fecha_ult_pago_interes char(8),
	dat_monto_ult_pago_interes integer,
	dat_fecha_primer_amor_no_cub char(8),
	dat_monto_condonac_quita integer,
	dat_fecha_condonac_quita char(8),
	dat_num_dias_mora integer,
	cve_tipo_credito integer,
	cve_situacion_credito integer,
	dat_capital integer,
	dat_interes_ordinario integer,
	dat_interes_moratorio integer,
	dat_interes_ord_venc_fuera_bal integer,
	dat_interes_mora_fuera_bal integer,
	dat_interes_refin_o_capit integer,
	dat_saldo_insoluto integer,
	cve_acreditado integer,
	cve_tipo_cartera_califica integer,
	dat_calif_deudor varchar(2),
	dat_calif_parte_cub varchar(2),
	dat_calif__parte_exp varchar(2),
	dat_estim_prev_parte_cub integer,
	dat_estim_prev_parte_exp integer,
	dat_estim_adicion_car_ven integer,
	dat_estim_prev_adic_ries_oper integer,
	dat_estim_adicion_cnbv integer,
	dat_fecha_consulta_sic char(8),
	cve_prevencion integer,
	dat_valor_gtia_liquida integer,
	dat_valor_gtia_hipotecaria integer,
	socioid integer
);
CREATE or replace FUNCTION regulatorioC451(date) RETURNS SETOF tregulatorioC451
    AS $_$
declare
  pfecha alias for $1;
  r tregulatorioC451%rowtype;
  
  ntiposocio integer;
  ntiposociorelacionado integer;
  npuestoid integer;
begin
	for r in
select
	--cve_subreporte
	'451',
	--cve_municipio_siti
	cd.claveconapo,
	--cve_estado
	ed.claveestadomex,
	--dat_numero_dedudor
	replace(trim(s.clavesocioint),'-','') as clavesocioint,
	--cve_persona
	1,
	--dat_nombre_acred
	su.nombre,
	--dat_primer_apellido
	su.paterno,
	--dat_segundo_apellido
	su.materno,
	--dat_rfc
	su.rfc,
	--dat_curp_acred
	su.curp,
	--cve_genero_acred
	(select (case sexo when 0 then 2 when 1 then 1 else 0 end) from solicitudingreso where socioid=s.socioid),
	--dat_numero_credito
	(select substring(sucid,1,3) from empresa where empresaid=1)||substring(p.referenciaprestamo,1,6)||substring(p.referenciaprestamo,8,10),
	--dat_nombre_sucursal
	(select nombresucursal from empresa) as nombresucursal,
	--cve_clasfica_contable
	substring(trim(ct.clasificacioncontable),1,12),
	--dat_producto_credito
	(select trim(desctipoprestamo) from tipoprestamo where tipoprestamoid=pr.tipoprestamoid),
	--dat_fecha_disposicion
	to_char(pr.fecha_otorga,'YYYYMMDD'),
	--dat_fecha_vencimiento
	to_char(pr.fecha_vencimiento,'YYYYMMDD'),
	--cve_modalidad_pago
	(case t.revolvente
	when 1 then 7
	else
		(case 
			when (select count(*) from amortizaciones where prestamoid=pr.prestamoid and importeamortizacion<>0)=1 then 2 
		else 
			(case 
				when pr.frecuencia<=28 and pr.frecuencia<=32 then 6
				when pr.frecuencia=7 then 4
				when pr.frecuencia<=14 and pr.frecuencia<=15 then 5
				when pr.frecuencia<=32 then 3
			else
				0
			end)
		end)
	end),
	--dat_monto_credito
	pr.montoprestamo,
	--dat_frec_pagos_capital
	pr.frecuencia,
	--dat_frec_pagos_interes
	pr.frecuencia,
	--dat_tasa_interes
	pr.tasanormal,
	--dat_fecha_ult_pago_capital
	to_char(pr.ultimoabono,'YYYYMMDD'),
	--dat_monto_ult_pago_capital
	pr.pagocapitalenperiodo,
	--dat_fecha_ult_pago_interes
	to_char(coalesce(pr.ultimoabonointeres,p.fecha_otorga),'YYYYMMDD'),
	--dat_monto_ult_pago_interes
	pr.pagointeresenperiodo,
	--dat_fecha_primer_amor_no_cub
	to_char(coalesce(pr.primerincumplimiento,(select fecha_limite from corte_linea where fecha_corte>=pfecha and lineaid=p.prestamoid order by fecha_limite limit 1)),'YYYYMMDD'),
	--dat_monto_condonac_quita
	0,
	--dat_fecha_condonac_quita
	0,
	--dat_num_dias_mora
	pr.diascapital,
	--cve_tipo_credito
	(case when t.tipoprestamoid in ('T1','T2','T3') then 3
	else
		(case p.renovado
			when 2 then 3
			when 1 then 2
			else 1
		end)
	end),
	--cve_situacion_credito
	(case pr.diascapital
		when 0 then 1
		else
			(case when pr.saldovencidomenoravencido<>0 then 2
			else 3
			end)
	end),
	--dat_capital
	pr.saldoprestamo,
	--dat_interes_ordinario
	pr.interesdevengadomenoravencido,
	--dat_interes_moratorio
	pr.interesdevmormenor,
	--dat_interes_ord_venc_fuera_bal
	pr.interesdevengadomayoravencido,
	--dat_interes_mora_fuera_bal
	pr.interesdevmormayor,
	--dat_interes_refin_o_capit
	0,
	--dat_saldo_insoluto
	pr.saldoprestamo+pr.interesdevengadomenoravencido+pr.interesdevmormenor,
	--cve_acreditado
	1,
	--cve_tipo_cartera_califica
	(case p.clavefinalidad
		when '001' then --comercial
			(case p.tipo_cartera_est
				when 2 then 4
				else 3
			end)
		when '002' then--consumo
			(case p.tipo_cartera_est
				when 2 then 2
				else 1
			end)
		when '003' then--vivienda
			(case p.tipo_cartera_est
				when 2 then 9
				else 8
			end)
		else 0
	end),
	--dat_calif_deudor
	0,
	--dat_calif_parte_cub
	0,
	--dat_calif__parte_exp
	0,
	--dat_estim_prev_parte_cub
	0,
	--dat_estim_prev_parte_exp
	0,
	--dat_estim_adicion_car_ven
	0,
	--dat_estim_prev_adic_ries_oper
	0,
	--dat_estim_adicion_cnbv
	0,
	--dat_fecha_consulta_sic
	(case when exists (select prestamoid from fechaconsultaburo where prestamoid=pr.prestamoid) then (select to_char(fechaconsulta,'YYYYMMDD') from fechaconsultaburo where prestamoid=pr.prestamoid) else (select to_char(ultimafechaburo,'YYYYMMDD') from ultimafechaburo(s.sujetoid)) end),
	--cve_prevencion
	(case 
	when pr.diascapital=0 then '10001'
	when pr.diascapital<0 	and pr.diascapital<=29 then '10002'
	when pr.diascapital<29 	and pr.diascapital<=59 then '10003'
	when pr.diascapital<59 	and pr.diascapital<=89 then '10004'
	when pr.diascapital<89 	and pr.diascapital<=119 then '10005'
	when pr.diascapital<119 and pr.diascapital<=149 then '10006'
	when pr.diascapital<149 and pr.diascapital<=360 then '10007'
	else '10008'
	end),
	--dat_valor_gtia_liquida
	(case when pr.tipoprestamoid in ('N8','N16') then (select aa from controlgarantialiquida where prestamoid=pr.prestamoid) else 0 end),
	--dat_valor_gtia_hipotecaria
	coalesce((SELECT monto FROM garantiahipotecaria where prestamoid=p.prestamoid),0),
	s.socioid
	from 
		precorte pr,prestamos p,tipoprestamo t,cat_cuentas_tipoprestamo ct, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where 
		pr.fechacierre=pfecha
		and p.prestamoid = pr.prestamoid
		and t.tipoprestamoid = p.tipoprestamoid
		and pr.tipoprestamoid<>'CAS' and pr.saldoprestamo>0 and
		s.socioid=p.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid and ct.cat_cuentasid=p.cat_cuentasid
loop 
	select estatustiposocio into ntiposocio from generalesconceatucliente where socioid=r.socioid;
	
	select gc.estatustiposocio into ntiposociorelacionado from  relacionados re,socio sx,generalesconceatucliente gc where sx.socioid=re.socioidem and  gc.socioid=sx.socioid  and  re.socioidem<>re.socioidre and socioidre<>0 and re.socioidre=r.socioid  limit 1;
	
	select e.puestoid into npuestoid from empleado e where e.puestoid in (1,2,3,4,5,6,11,12) and e.socioid=r.socioid;
	
	if ntiposocio=2 then 
		r.cve_acreditado=2; --Consejo de Administración
	elsif ntiposocio=3 then 
		r.cve_acreditado=3; --Consejo de Vigilancia
	elsif ntiposocio=4 then 
		if npuestoid = 11 then
			r.cve_acreditado=7; --Funcionario (Dir. Gen O cargos con la jerarquía inmediata inferior)
		else
			r.cve_acreditado=4; --Comité de Crédito o su equivalente
		end if;
	else 
		if ntiposociorelacionado in (2,3) then
			r.cve_acreditado=6; --relacionados con miembros del Consejo y Auditor Externo de la Sociedad.
		end if;
	end if;
	
	return next r;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;