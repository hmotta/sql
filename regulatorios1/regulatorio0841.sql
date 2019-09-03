drop type tregulatorio0841 cascade;
create type tregulatorio0841 as (
	socioid integer,
	clavesocioint character(15),
	tiposocioid character(2),
	nombre character varying(40),
	paterno character varying(20),
	materno character varying(20),
	rfc character(16),
	curp character(20),
	sexo integer,
	fecha_nacimiento date, 
	cp integer,
	nombreciudad character(50),
	claveconapo character(10),
	nombreestadomex character varying(20),
	claveestadomex character(3),
	psordinario numeric,
	psexcedente numeric,
	tipomovimientoid character(2),
	tipoinversionid character(3),
	desctipoinversion character(30),
	inversionid integer,
	nombresucursal character(50),
	fechaalta date,
	fechainversion date,
	tasainteresnormalinversion numeric,
	plazo integer,
	saldoinicialinv numeric, 
	saldoinicial numeric,
	depositos numeric,
	retiros numeric,
	intdevnopag numeric,
	saldofinal numeric,
	fechaultimomov date,
	fechavencimiento date
);
CREATE or replace FUNCTION regulatorio0841(date,date,date,date) RETURNS SETOF tregulatorio0841
    AS $_$
declare
  pfechaant alias for $1;
  pfechaini alias for $2;
  pfechamid alias for $3;
  pfechafin alias for $4;
  r tregulatorio0841%rowtype;
begin
--El codigo se divide en 3 partes
--Primeramente se toman los distintos cierres en base a las fechas ejemplo: para el tercer periodo del 2015 se toma
/*	30/06/2015 pfechaant
	31/07/2015 pfechaini
	31/08/2015 pfechamid
	30/09/2015 pfechafin
	Parte 1 - Solo Partes Sociales
		1 Partes sociales de los socios los socios que esten en el desagregado de pfechaini y no esten en el de pfechamid
		2 Partes sociales de los socios que esten en el desagregado de pfechamid y no esten en el de pfechaini y no esten en el de pfechafin (si los hay)
		3 Partes sociales de los socios que esten en el desagregado de pfechafin
	Parte 2 - saldos de Ahorros e inversiones
		1 Todos los socios que esten en el desagregado de pfechaini y no esten en el de pfechamid
			(inician con saldo>0 y terminan con saldo 0, ya que se dieron de baja durante el periodo)
		2 Todos los socios que esten en el desagregado de pfechamid y no esten en el de pfechaini y no esten en el de pfechafin (si los hay)
			(inician con saldo 0 y terminan con saldo 0, ya que se dieron de alta y baja durante el periodo)
		3 Todos los socios que esten en el desagregado de pfechafin
			(son lo que tenian saldo al cierre)

*/
--3 Partes sociales de los socios que esten en el desagregado de pfechafin

for r in
select
	ct.socioid,
	trim(s.clavesocioint) as clavesocioint,
	s.tiposocioid,
	su.nombre,
	su.paterno,
	su.materno,
	su.rfc,
	su.curp,
	(select sexo from solicitudingreso where socioid=s.socioid) as sexo,
	su.fecha_nacimiento,
	c.cp,
	'',--cd.nombreciudadmex,
	cd.claveconapo,
	'',--ed.nombreestadomex,
	ed.claveestadomex,
	ct.deposito,
	(select sum(deposito) from captaciontotal where (tipomovimientoid='P3' or desctipoinversion in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT')) and fechadegeneracion=pfechafin and socioid=ct.socioid ),
	ct.tipomovimientoid,
	'' as tipoinversionid,
	'',--ct.desctipoinversion,
	0,
	'',--(select nombresucursal from empresa) as nombresucursal,
	'19000101',
	'19000101',
	0,
	0,
	0 as saldoinicialinv,
	0,
	0,
	0,
	0,
	0,
	'19000101',
	'19000101'
	
	from captaciontotal ct, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where ct.fechadegeneracion=pfechafin 
	and tipomovimientoid='PA' and
	s.socioid=ct.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid
loop 
  
  return next r;

end loop;

--1 Todos los movimientos que esten en el desagregado de pfechaant y no esten en los demas desagregados que quiere decir que tenian saldo y al final del periodo quedaron en 0

for r in
select
	ct.socioid,
	trim(s.clavesocioint) as clavesocioint,
	s.tiposocioid,
	su.nombre,
	su.paterno,
	su.materno,
	su.rfc,
	su.curp,
	(select sexo from solicitudingreso where socioid=s.socioid) as sexo,
	su.fecha_nacimiento,
	c.cp,
	'',--cd.nombreciudadmex,
	cd.claveconapo,
	'',--ed.nombreestadomex,
	ed.claveestadomex,
	0,
	0,
	ct.tipomovimientoid,
	(case when tipomovimientoid='IN' then (select tipoinversionid from inversion where inversionid=ct.inversionid) else '' end) as tipoinversionid,
	'',--ct.desctipoinversion,
	ct.inversionid,
	'',--(select nombresucursal from empresa) as nombresucursal,
	s.fechaalta,
	ct.fechainversion,
	ct.tasainteresnormalinversion,
	ct.plazo,
	(case when ct.fechainversion>=pfechaant+1 then 0 else (select depositoinversion from inversion where inversionid=ct.inversionid) end) as saldoinicialinv,
	(select deposito from captaciontotal where tipomovimientoid=ct.tipomovimientoid and socioid=ct.socioid and fechadegeneracion=pfechaant and inversionid=ct.inversionid),
	(case when tipomovimientoid='IN' then (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end ),
	(case when tipomovimientoid='IN' then (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end),
	0,
	0,
	(case when tipomovimientoid<>'IN' then (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) else (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.inversionid=ct.inversionid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) end),
	(select fechavencimiento from inversion where inversionid=ct.inversionid) as fechavencimiento
	
	from captaciontotal ct, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where ct.fechadegeneracion=pfechaant 
	and tipomovimientoid not in ('IP','ID','PP','PA','P3') and
	s.socioid=ct.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid and ct.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT') and (ct.socioid||ct.tipomovimientoid not in (select socioid||tipomovimientoid from captaciontotal where fechadegeneracion in (pfechaini,pfechamid,pfechafin)) OR cast(ct.socioid as character)||ct.inversionid not in (select cast(socioid as character)||inversionid from captaciontotal where fechadegeneracion in (pfechaini)))
loop 
  
  return next r;

end loop;

--2 Todos los movimientos que esten en el desagregado de pfechaini y no esten en el de pfechamid
for r in
select
	ct.socioid,
	trim(s.clavesocioint) as clavesocioint,
	s.tiposocioid,
	su.nombre,
	su.paterno,
	su.materno,
	su.rfc,
	su.curp,
	(select sexo from solicitudingreso where socioid=s.socioid) as sexo,
	su.fecha_nacimiento,
	c.cp,
	'',--cd.nombreciudadmex,
	cd.claveconapo,
	'',--ed.nombreestadomex,
	ed.claveestadomex,
	0,
	0,
	ct.tipomovimientoid,
	(case when tipomovimientoid='IN' then (select tipoinversionid from inversion where inversionid=ct.inversionid) else '' end) as tipoinversionid,
	'',--ct.desctipoinversion,
	ct.inversionid,
	'',--(select nombresucursal from empresa) as nombresucursal,
	s.fechaalta,
	ct.fechainversion,
	ct.tasainteresnormalinversion,
	ct.plazo,
	(case when ct.fechainversion>=pfechaant+1 then 0 else (select depositoinversion from inversion where inversionid=ct.inversionid) end) as saldoinicialinv,
	(select deposito from captaciontotal where tipomovimientoid=ct.tipomovimientoid and socioid=ct.socioid and fechadegeneracion=pfechaant and inversionid=ct.inversionid),
	(case when tipomovimientoid='IN' then (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end ),
	(case when tipomovimientoid='IN' then (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end),
	0,
	0,
	(case when tipomovimientoid<>'IN' then (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) else (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.inversionid=ct.inversionid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) end),
	(select fechavencimiento from inversion where inversionid=ct.inversionid) as fechavencimiento
	
	from captaciontotal ct, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where ct.fechadegeneracion=pfechaini 
	and tipomovimientoid not in ('IP','ID','PP','PA','P3') and
	s.socioid=ct.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid and ct.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT') and (ct.socioid||ct.tipomovimientoid not in (select socioid||tipomovimientoid from captaciontotal where fechadegeneracion in (pfechamid,pfechafin)) OR cast(ct.socioid as character)||ct.inversionid not in (select cast(socioid as character)||inversionid from captaciontotal where fechadegeneracion in (pfechamid,pfechafin)))
loop 
  
  return next r;

end loop;

--3 Todos los socios que esten en el desagregado de pfechamid y no esten en el de pfechaini y no esten en el de pfechafin

for r in
select
	ct.socioid,
	trim(s.clavesocioint) as clavesocioint,
	s.tiposocioid,
	su.nombre,
	su.paterno,
	su.materno,
	su.rfc,
	su.curp,
	(select sexo from solicitudingreso where socioid=s.socioid) as sexo,
	su.fecha_nacimiento,
	c.cp,
	'',--cd.nombreciudadmex,
	cd.claveconapo,
	'',--ed.nombreestadomex,
	ed.claveestadomex,
	0,
	0,
	ct.tipomovimientoid,
	(case when tipomovimientoid='IN' then (select tipoinversionid from inversion where inversionid=ct.inversionid) else '' end) as tipoinversionid,
	'',--ct.desctipoinversion,
	ct.inversionid,
	'',--(select nombresucursal from empresa) as nombresucursal,
	s.fechaalta,
	ct.fechainversion,
	ct.tasainteresnormalinversion,
	ct.plazo,
	(case when ct.fechainversion>=pfechaant+1 then 0 else (select depositoinversion from inversion where inversionid=ct.inversionid) end) as saldoinicialinv,
	(select deposito from captaciontotal where tipomovimientoid=ct.tipomovimientoid and socioid=ct.socioid and fechadegeneracion=pfechaant and inversionid=ct.inversionid),
	(case when tipomovimientoid='IN' then (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end ),
	(case when tipomovimientoid='IN' then (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end),
	0,
	0,
	(case when tipomovimientoid<>'IN' then (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) else (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.inversionid=ct.inversionid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) end),
	(select fechavencimiento from inversion where inversionid=ct.inversionid) as fechavencimiento
	
	from captaciontotal ct, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where ct.fechadegeneracion=pfechamid 
	and tipomovimientoid not in ('IP','ID','PP','PA','P3') and
	s.socioid=ct.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid and ct.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT') and (ct.socioid||ct.tipomovimientoid not in (select socioid||tipomovimientoid from captaciontotal where fechadegeneracion in (pfechaini,pfechafin)) or ct.socioid||ct.tipomovimientoid not in (select socioid||tipomovimientoid from captaciontotal where fechadegeneracion in (pfechafin)) OR cast(ct.socioid as character)||ct.inversionid not in (select cast(socioid as character)||inversionid from captaciontotal where fechadegeneracion in (pfechafin)))
loop 
  
  return next r;

end loop;

--4 Todos los socios que esten en el desagregado de pfechafin
for r in
select
	ct.socioid,
	trim(s.clavesocioint) as clavesocioint,
	s.tiposocioid,
	su.nombre,
	su.paterno,
	su.materno,
	su.rfc,
	su.curp,
	(select sexo from solicitudingreso where socioid=s.socioid) as sexo,
	su.fecha_nacimiento,
	c.cp,
	'',--cd.nombreciudadmex,
	cd.claveconapo,
	'',--ed.nombreestadomex,
	ed.claveestadomex,
	0,
	0,
	ct.tipomovimientoid,
	(case when tipomovimientoid='IN' then (select tipoinversionid from inversion where inversionid=ct.inversionid) else '' end) as tipoinversionid,
	'',--ct.desctipoinversion,
	ct.inversionid,
	'',--(select nombresucursal from empresa) as nombresucursal,
	s.fechaalta,
	ct.fechainversion,
	ct.tasainteresnormalinversion,
	ct.plazo,
	(case when ct.fechainversion>=pfechaant+1 then 0 else (select depositoinversion from inversion where inversionid=ct.inversionid) end) as saldoinicialinv,
	(select deposito from captaciontotal where tipomovimientoid=ct.tipomovimientoid and socioid=ct.socioid and fechadegeneracion=pfechaant and inversionid=ct.inversionid),
	(case when tipomovimientoid='IN' then (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(debe),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end ),
	(case when tipomovimientoid='IN' then (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.inversionid=ct.inversionid and p.fechapoliza between pfechaant+1 and pfechafin) else (select coalesce(sum(haber),0) from movicaja mc, polizas p, movipolizas mp where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and mc.socioid=ct.socioid and mc.tipomovimientoid=ct.tipomovimientoid and mc.tipomovimientoid<>'IN' and p.fechapoliza between pfechaant+1 and pfechafin) end),
	( case when tipomovimientoid='IN' then (select sum(intdevacumulado) from captaciontotal where tipomovimientoid=ct.tipomovimientoid and socioid=ct.socioid and fechadegeneracion in (pfechafin) and inversionid=ct.inversionid) else (select sum(intdevmensual) from captaciontotal where tipomovimientoid=ct.tipomovimientoid and socioid=ct.socioid and fechadegeneracion in (pfechafin)) end),
	ct.deposito+(case when tipomovimientoid='IN' then (intdevacumulado) else (intdevmensual) end),
	(case when tipomovimientoid<>'IN' then (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) else (select max(fechapoliza) from movicaja  mc, polizas p, socio s  where p.polizaid=mc.polizaid and s.socioid=mc.socioid and mc.tipomovimientoid=ct.tipomovimientoid and s.socioid=ct.socioid and mc.inversionid=ct.inversionid and mc.seriecaja not in ('ZA') and p.fechapoliza<=pfechafin) end),
	(case when tipomovimientoid='IN' then (select fechavencimiento from inversion where inversionid=ct.inversionid) else null end )as fechavencimiento
	
	from captaciontotal ct, socio s, sujeto su,domicilio d, colonia c, ciudadesmex cd, estadosmex ed
	where ct.fechadegeneracion=pfechafin 
	and tipomovimientoid not in ('IP','ID','PP','PA','P3') and
	s.socioid=ct.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid and cd.ciudadmexid=d.ciudadmexid and ed.estadomexid=cd.estadomexid and ct.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT')
loop 
  
  return next r;

end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;