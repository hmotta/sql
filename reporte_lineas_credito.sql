--drop type rlineascredito cascade;
/*create type rlineascredito as (
	sucursal varchar(4),
	nombre varchar(60),
	clavesocioint varchar(20),
	referencia varchar(10),
	rfc varchar(13),
	fecha_autorizacion date, 
	fecha_otorga date,
	monto_original numeric,
	fecha_vencimiento date,
	tasa_normal numeric,
	tasa_moratoria numeric,
	dias_mora integer,
	saldo_disponible numeric,
	saldo_adeudado numeric,
	capital_vencido numeric,
	fecha_ult_abono_cap date,
	fecha_primer_bloq date,
	fecha_ultimo_bloq date,
	estatus varchar(15),
	ejecutivo varchar(60),
	num_pagos_vencidos integer,
	fecha_ultimo_mov date,
	monto_ultimo_mov numeric,
	desc_ultimo_mov varchar(20),
	prestamoid integer,
	claveestadocredito varchar(3)
);*/
CREATE or replace FUNCTION reporte_lineas_credito(date) RETURNS SETOF rlineascredito
    AS $_$
declare
	r rlineascredito%rowtype;
	pfecha alias for $1;
	ndiastraspasovencida integer;
	xdebe numeric;
	xhaber numeric;
	dultimo_movimiento date;
begin
	
	select diastraspasoavencida into ndiastraspasovencida from tipoprestamo where tipoprestamoid='LN';
	for r in
      select 
		'',
		( select (su.nombre||' '||su.paterno||' '||su.materno) from sujeto su inner join socio s on(su.sujetoid=s.sujetoid) and s.socioid=p.socioid),
		( select s.clavesocioint from socio s where s.socioid=p.socioid),
		p.referenciaprestamo,
		( select su.rfc from sujeto su inner join socio s on(su.sujetoid=s.sujetoid) and s.socioid=p.socioid),
		null,
		p.fecha_otorga,
		p.montoprestamo,
		p.fecha_vencimiento,
		p.tasanormal,
		p.tasa_moratoria,
		(select dias_mora_linea from dias_mora_linea(p.prestamoid,pfecha)),
		0,
		(select spssaldoadeudolinea from spssaldoadeudolinea(p.prestamoid)),
		(select coalesce(sum(capital-capital_pagado),0) from corte_linea where lineaid=p.prestamoid and fecha_limite<pfecha and (capital-capital_pagado)>0),
		(select max(po.fechapoliza) from polizas po,movipolizas mp,prestamos p1,cat_cuentas_tipoprestamo ct  where po.polizaid=mp.polizaid and mp.prestamoid=p1.prestamoid and (ct.cat_cuentasid = p1.cat_cuentasid) and mp.haber>0 and p1.prestamoid=p.prestamoid and (mp.cuentaid = ct.cuentaactivo) and po.fechapoliza<=pfecha),
		(select min(fecha) from creditos_lineas_bloqueo where estatus='B' and lineaid=p.prestamoid),
		(select max(fecha) from creditos_lineas_bloqueo where estatus='B' and lineaid=p.prestamoid),
		'',
		'',
		(select count(*) from corte_linea where lineaid=p.prestamoid and fecha_limite<pfecha and (capital-capital_pagado)>0),
		null,
		0,
		'',
		p.prestamoid,
		p.claveestadocredito
      from 
		prestamos p 
		inner join tipoprestamo tp on (p.tipoprestamoid=tp.tipoprestamoid)
		where tp.revolvente=1
	  order by p.fecha_otorga
    loop
		if (r.capital_vencido)>0 then  --No esta pagada
			if r.dias_mora>ndiastraspasovencida then
				r.estatus:='VENCIDA';
			else
				r.estatus:='VIGENTE';
			end if;
		else
			if r.claveestadocredito='002' then
				r.estatus:='PAGADA';
			else
				r.estatus:='VIGENTE';
			end if;
			
		end if;
		
		select fecha,debe,haber,upper(concepto) into r.fecha_ultimo_mov,xdebe,xhaber,r.desc_ultimo_mov from movslinead(r.prestamoid,r.fecha_otorga,current_date,0) where tipomov in (1,7) order by fecha desc limit 1;
		 
		xdebe:=coalesce(xdebe,0);
		xhaber:=coalesce(xhaber,0);
		if xdebe>0 then
			r.monto_ultimo_mov:=xdebe;
		else
			r.monto_ultimo_mov:=xhaber;
		end if;
		
		r.saldo_disponible:=r.monto_original-r.saldo_adeudado;
		
		return next r;
	end loop;
	
    
		
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;