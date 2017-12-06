select 	so.clavesocioint,(ltrim(su.nombre)||' '||ltrim(su.paterno)||' '||ltrim(su.materno)) as nombre, s.saldo as saldop3,(select count(*) from prestamos where socioid=s.socioid and claveestadocredito='001') as creditosvigentes,(select * from spsfoliops(s.socioid,'P3')) as folios,(select min(p.fechapoliza) from movicaja mc, polizas p where  p.polizaid=mc.polizaid and mc.tipomovimientoid='P3' and mc.socioid=s.socioid) as primermovimiento from socio so, sujeto su,polizas p,movicaja mc,(select mc.socioid,sum(mp.debe)-sum(mp.haber) as saldo,max(mc.polizaid) as ultpolizaid from movicaja mc, movipolizas mp, tipomovimiento tm where  mp.movipolizaid=mc.movipolizaid and mc.tipomovimientoid='P3' and tm.tipomovimientoid=mc.tipomovimientoid and tm.aplicasaldo='S' group by mc.socioid) as s where so.socioid=mc.socioid and su.sujetoid=so.sujetoid and p.polizaid=s.ultpolizaid and mc.polizaid=p.polizaid and mc.tipomovimientoid='P3' and s.socioid=mc.socioid and s.saldo> 0 group by so.clavesocioint,folios,su.nombre,su.paterno,su.materno,s.saldo,s.socioid,p.polizaid order by p.polizaid;


select (select clavesocioint from socio where socioid=mc.socioid),(select su.nombre||' '||su.paterno||' '||su.materno from sujeto su where su.sujetoid = (select sujetoid from socio where socioid=mc.socioid)) as nombre,sum(debe),(select coalesce(saldomov,0) from saldomov(mc.socioid,'P3',p.fechapoliza)),(select * from spsfoliops(mc.socioid,'P3')) as folios from movicaja mc, movipolizas mp, polizas p where mc.polizaid=p.polizaid and mc.movipolizaid=mp.movipolizaid and mc.tipomovimientoid='P3' and p.fechapoliza between '2014-06-01' and '2014-06-30' and debe>0 group by socioid,p.fechapoliza;

--Correccion de folios
update foliops set vigente='N' where socioid=855 and vigente='S' and exists (select sucid from empresa where sucid='002-');
update foliops set vigente='N' where socioid=1456 and vigente='S' and folioid=11500 and exists (select sucid from empresa where sucid='002-');
update foliops set vigente='N' where socioid=5049 and vigente='S' and folioid=8099 and exists (select sucid from empresa where sucid='003-');
update foliops set vigente='N' where socioid=2911 and vigente='S' and exists (select sucid from empresa where sucid='005-');
update foliops set vigente='N' where socioid=434 and vigente='S' and folioid=8548 and exists (select sucid from empresa where sucid='005-');
update foliops set vigente='N' where socioid=5398 and vigente='S' and folioid=8605 and exists (select sucid from empresa where sucid='005-');
update foliops set vigente='N' where socioid=1186 and vigente='S' and exists (select sucid from empresa where sucid='006-');
update foliops set vigente='N' where socioid=1347 and vigente='S' and exists (select sucid from empresa where sucid='006-');
update foliops set vigente='N' where socioid=287 and vigente='S' and exists (select sucid from empresa where sucid='007-');
update foliops set vigente='N' where socioid=665 and vigente='S' and exists (select sucid from empresa where sucid='008-');


--Reporte para folios de P3
select so.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombre,fp.tipomovimientoid as movimiento,fechaemision,fp.folioini,fp.foliofin,(fp.foliofin-fp.folioini+1)*500 as monto from foliops fp,socio so,sujeto su where fp.socioid=so.socioid and su.sujetoid=so.sujetoid and vigente='S' and tipomovimientoid='P3' order by fp.folioini;

select so.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombre,fp.tipomovimientoid as movimiento,fechaemision,fp.folioini,fp.foliofin,(fp.foliofin-fp.folioini+1)*500 as monto from foliops fp,socio so,sujeto su where fp.socioid=so.socioid and su.sujetoid=so.sujetoid and vigente='S' and tipomovimientoid='PA' order by fp.folioini;

select so.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombre,fp.tipomovimientoid as movimiento,fechaemision,fp.folioini,fp.foliofin,(fp.foliofin-fp.folioini+1)*500 as monto,inversionid from foliops fp,socio so,sujeto su where fp.socioid=so.socioid and su.sujetoid=so.sujetoid and vigente='S' and tipomovimientoid='PSO' order by fp.folioini;

select so.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombre,fp.tipomovimientoid as movimiento,fechaemision,fp.folioini,fp.foliofin,(fp.foliofin-fp.folioini+1)*500 as monto,inversionid from foliops fp,socio so,sujeto su where fp.socioid=so.socioid and su.sujetoid=so.sujetoid and vigente='S' and tipomovimientoid='PSV' order by fp.folioini;