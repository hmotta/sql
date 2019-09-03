drop type tregulatorioC451 cascade;
create type tregulatorioC451 as (
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
	ultimafechaburo date
);
CREATE or replace FUNCTION regulatorioC451(date) RETURNS SETOF tregulatorioC451
    AS $_$
declare
  pfecha alias for $1;
  r tregulatorioC451%rowtype;
begin
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
	(select substring(sucid,1,3) from empresa where empresaid=1)||substring(p.referenciaprestamo,1,6)||substring(p.referenciaprestamo,8,10),
	(select nombresucursal from empresa) as nombresucursal,
	(select desctipoprestamo from tipoprestamo where tipoprestamoid=pr.tipoprestamoid),
	pr.fecha_otorga,
	pr.fecha_vencimiento,
	p.numero_de_amor,
	pr.frecuencia,
	(select count(*) from amortizaciones where prestamoid=pr.prestamoid and importeamortizacion<>0),
	pr.montoprestamo,
	pr.tasanormal,
	pr.ultimoabono,
	pr.pagocapitalenperiodo,
	pr.ultimoabonointeres,
	pr.pagointeresenperiodo,
	pr.primerincumplimiento,
	pr.diascapital,
	pr.diasvencidos,
	pr.tipoprestamoid,
	pr.saldoprestamo,
	pr.saldovencidomenoravencido,
	pr.saldovencidomayoravencido,
	pr.interesdevengadomenoravencido,
	pr.interesdevengadomayoravencido,
	(SELECT moratorio FROM spscalculopago(pr.prestamoid)),
	(case when exists (select prestamoid from fechaconsultaburo where prestamoid=pr.prestamoid) then (select fechaconsulta from fechaconsultaburo where prestamoid=pr.prestamoid) else (select ultimafechaburo from ultimafechaburo(s.sujetoid)) end)
	from precorte pr,prestamos p, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where pr.fechacierre=pfecha
	and p.prestamoid = pr.prestamoid
	and pr.tipoprestamoid<>'CAS' and pr.saldoprestamo>0 and
	s.socioid=p.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid
	
loop 
  return next r;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;