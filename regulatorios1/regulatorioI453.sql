drop type tregulatorioI453 cascade;
create type tregulatorioI453 as (
	cp integer,
	nombreciudad character(50),
	claveconapo character(10),
	nombreestadomex character varying(20),
	claveestadomex character(3),
	socioid integer,
	clavesocioint character(15),
	tiposocioid character(2),
	nombre character varying(40),
	paterno character varying(20),
	materno character varying(20),
	rfc character(16),
	curp character(20),
	sexo integer,
	cuenta character varying(25),
	nombresucursal character(50),
	desctipoprestamo character varying(30),
	fecha_otorga date,
	fecha_vencimiento date,
	numero_de_amor integer,
	frecuencia integer,
	nopagoscapital integer,
	montoprestamo numeric,
	tasanormal numeric,
	ultimoabono date,
	pagocapitalenperiodo numeric,
	ultimoabonointeres date,
	pagointeresenperiodo numeric,
	primerincumplimiento date,
	diascapital integer,
	diasvencidos integer,
	tipoprestamoid character(3),
	saldoprestamo numeric,
	saldovencidomenoravencido numeric,
	saldovencidomayoravencido numeric,
	interesdevengadomenoravencido numeric,
	interesdevengadomayoravencido numeric,
	moratorioalcierre numeric,
	ultimafechaburo date,
	fechacastigo date
);

CREATE or replace FUNCTION regulatorioI453(date) RETURNS SETOF tregulatorioI453
    AS $_$
declare
  pfecha alias for $1;
  r tregulatorioI453%rowtype;
  pfechainicio date;
begin
	if date_part('month',pfecha)<10 then
		pfechainicio:= date_part('year',pfecha)||'0'||date_part('month',pfecha)||'01';
	else
		pfechainicio:= date_part('year',pfecha)||date_part('month',pfecha)||'01';
	end if;
	raise notice '%',pfechainicio;
	for r in
select
	c.cp,
	cd.nombreciudadmex,
	cd.claveconapo,
	ed.nombreestadomex,
	ed.claveestadomex,
	p.socioid,
	trim(s.clavesocioint) as clavesocioint,
	s.tiposocioid,
	su.nombre,
	su.paterno,
	su.materno,
	su.rfc,
	su.curp,
	(select sexo from solicitudingreso where socioid=s.socioid) as sexo,
	(select substring(sucid,1,3) from empresa where empresaid=1)||substring(p.referenciaprestamo,1,6)||(case when substring(p.referenciaprestamo,8,10)='S' then 'S' else '' end),
	(select nombresucursal from empresa) as nombresucursal,
	(select desctipoprestamo from tipoprestamo where tipoprestamoid=(select tipoprestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-')),
	pr.fecha_otorga,
	pr.fecha_vencimiento,
	p.numero_de_amor,
	pr.frecuencia,
	(select count(*) from amortizaciones where prestamoid=pr.prestamoid and importeamortizacion<>0),
	pr.montoprestamo,
	pr.tasanormal,
	(select ultimoabono from precorte where prestamoid=(select prestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-') and fechacierre=pfecha),
	(select pagocapitalenperiodo from precorte where prestamoid=(select prestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-') and fechacierre=pfecha),
	pr.ultimoabonointeres,
	pr.pagointeresenperiodo,
	(select primerincumplimiento from precorte where prestamoid=(select prestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-') and fechacierre=pfecha),
	pr.diascapital,
	pr.diasvencidos,
	(select tipoprestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-'),
	pr.saldoprestamo,
	pr.saldovencidomenoravencido,
	pr.saldovencidomayoravencido,
	pr.interesdevengadomenoravencido,
	pr.interesdevengadomayoravencido,
	(SELECT moratorio FROM spscalculopago(pr.prestamoid)),
	(case when exists (select fechaconsulta from fechaconsultaburo where prestamoid=(select prestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-')) then (select fechaconsulta from fechaconsultaburo where prestamoid=(select prestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-')) else (select ultimafechaburo from ultimafechaburo(s.sujetoid)) end ),
	(select max(fechapoliza) from movicaja mc,polizas po where mc.polizaid=po.polizaid and mc.seriecaja = 'CC' and mc.tipomovimientoid='00' and mc.prestamoid=(select prestamoid from prestamos where referenciaprestamo=substring(p.referenciaprestamo,1,6)||'-'))
	from precorte pr,prestamos p, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where pr.fechacierre=pfecha 
	and p.prestamoid = pr.prestamoid
	and pr.tipoprestamoid='CAS' and
	s.socioid=p.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid 
	
loop
	if r.fechacastigo>=pfechainicio then
		return next r;
	end if;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
