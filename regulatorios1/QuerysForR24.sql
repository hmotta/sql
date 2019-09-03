-----A la vista
--Depositos
select mc.socioid,coalesce(sum(debe),0),count(*) from movicaja mc, polizas p, movipolizas mp, tipomovimiento tm where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid not in ('PA','PB','P3','PP','IN') and p.seriepoliza<>'ZA' and tm.aplicasaldo='S' and p.fechapoliza between '2016-03-01' and '2016-03-31' and debe>0 group by mc.socioid;

--Retiros
select mc.socioid,coalesce(sum(haber),0),count(*) from movicaja mc, polizas p, movipolizas mp, tipomovimiento tm where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid not in ('PA','PB','P3','PP','IN') and p.seriepoliza<>'ZA' and tm.aplicasaldo='S' and p.fechapoliza between '2016-03-01' and '2016-03-31' and haber>0 group by mc.socioid;


-----A plazo
--Depositos
select mc.socioid,coalesce(sum(debe),0),count(*) from movicaja mc, polizas p, movipolizas mp, inversion i where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and i.inversionid=mc.inversionid and mc.tipomovimientoid in ('IN') and i.tipoinversionid not in ('PSO','PSV','PS2') and p.fechapoliza between '2016-03-01' and '2016-03-31' and debe>0 group by mc.socioid;

--Retiros
select mc.socioid,coalesce(sum(haber),0),count(*) from movicaja mc, polizas p, movipolizas mp, inversion i where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and i.inversionid=mc.inversionid and mc.tipomovimientoid in ('IN') and i.tipoinversionid not in ('PSO','PSV','PS2') and p.fechapoliza between '2016-03-01' and '2016-03-31' and haber>0 group by mc.socioid;


-------Query para reporte R24-D 2441 INFORMACIÓN GENERAL SOBRE USO DE SERVCIOS FINANCIEROS
-----A la vista
--DEPOSITO 
select sum(monto),sum(nooperaciones),count(*) from (select socioid,coalesce(sum(debe),0) as monto,count(*) as nooperaciones from movicaja mc, polizas p, movipolizas mp, tipomovimiento tm where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid not in ('PA','PB','P3','PP','IN') and p.seriepoliza<>'ZA' and tm.aplicasaldo='S' and p.fechapoliza between '2016-03-01' and '2016-03-31' and debe>0 group by mc.socioid) as depositos;

--RETIRO 
select sum(monto),sum(nooperaciones),count(*) from (select socioid,coalesce(sum(haber),0) as monto,count(*) as nooperaciones from movicaja mc, polizas p, movipolizas mp, tipomovimiento tm where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid not in ('PA','PB','P3','PP','IN') and p.seriepoliza<>'ZA' and tm.aplicasaldo='S' and p.fechapoliza between '2016-03-01' and '2016-03-31' and haber>0 group by mc.socioid) as depositos;

-----A plazo
--Depositos
select sum(monto),sum(nooperaciones),count(*) from (select mc.socioid,coalesce(sum(debe),0) as monto,count(*) as nooperaciones from movicaja mc, polizas p, movipolizas mp, inversion i where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and i.inversionid=mc.inversionid and mc.tipomovimientoid in ('IN') and i.tipoinversionid not in ('PSO','PSV','PS2') and p.fechapoliza between '2016-03-01' and '2016-03-31' and debe>0 group by mc.socioid) as inversiones;

--Retiros
select sum(monto),sum(nooperaciones),count(*) from (select mc.socioid,coalesce(sum(haber),0) as monto,count(*) as nooperaciones from movicaja mc, polizas p, movipolizas mp, inversion i where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and i.inversionid=mc.inversionid and mc.tipomovimientoid in ('IN') and i.tipoinversionid not in ('PSO','PSV','PS2') and p.fechapoliza between '2016-03-01' and '2016-03-31' and haber>0 group by mc.socioid) as inversiones;

--para el reporte de la auditoria que le pidieron a checan 2016-05-16
select s.clavesocioint,mc.tipomovimientoid,coalesce(sum(debe),0),count(*) from movicaja mc, polizas p, movipolizas mp, tipomovimiento tm, socio s,sujeto su where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and s.socioid=mc.socioid and s.sujetoid=su.sujetoid and mc.tipomovimientoid not in ('PA','PB','P3','PP') and p.seriepoliza<>'ZA' and tm.aplicasaldo='S' and p.fechapoliza between '2016-04-01' and '2016-04-30' and debe>0 group by s.clavesocioint,mc.tipomovimientoid;

select s.clavesocioint,pr.referenciaprestamo,mc.tipomovimientoid,coalesce(sum(debe),0),count(*) from movicaja mc, polizas p, movipolizas mp, tipomovimiento tm, socio s,prestamos pr where mc.polizaid=p.polizaid and mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and s.socioid=mc.socioid and pr.prestamoid=mc.prestamoid and mc.tipomovimientoid in ('00') and p.seriepoliza<>'ZA' and p.fechapoliza between '2016-04-01' and '2016-04-30' and debe>0 group by s.clavesocioint,pr.referenciaprestamo,mc.tipomovimientoid;