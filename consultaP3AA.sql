select s.socioid, sum(mp.debe)-sum(mp.haber) as AA
from movicaja mc, movipolizas mp, socio s, tipomovimiento t
where t.tipomovimientoid=mc.tipomovimientoid and t.aplicasaldo='S' and mp.movipolizaid=mc.movipolizaid and s.socioid=mc.socioid and mc.tipomovimientoid in('AA') group by s.socioid,s.clavesocioint order by s.clavesocioint; 


select s.socioid, sum(mp.debe)-sum(mp.haber) as saldo
from movicaja mc, movipolizas mp, socio s, tipomovimiento t
where t.tipomovimientoid=mc.tipomovimientoid and t.aplicasaldo='S' and mp.movipolizaid=mc.movipolizaid and s.socioid=mc.socioid and mc.tipomovimientoid in('P3') group by s.socioid,s.clavesocioint order by s.clavesocioint; 

select substring((s.clavesocioint),1,4) as suc, s.clavesocioint, su.nombre||' '||su.paterno||' '||su.materno as nombresocio, aa.saldo as aa, p3.saldo as p3, p.referenciaprestamo, p.prestamoid, p.socioid, p.saldoprestamo,p.monto_garantia from socio s, sujeto su, prestamos p,(select s.socioid, sum(mp.debe)-sum(mp.haber) as saldo from movicaja mc, movipolizas mp, socio s, tipomovimiento t where t.tipomovimientoid=mc.tipomovimientoid and t.aplicasaldo='S' and mp.movipolizaid=mc.movipolizaid and s.socioid=mc.socioid and mc.tipomovimientoid in('AA') group by s.socioid,s.clavesocioint order by s.clavesocioint) aa, (select s.socioid, sum(mp.debe)-sum(mp.haber) as saldo from movicaja mc, movipolizas mp, socio s, tipomovimiento t where t.tipomovimientoid=mc.tipomovimientoid and t.aplicasaldo='S' and mp.movipolizaid=mc.movipolizaid and s.socioid=mc.socioid and mc.tipomovimientoid in('P3') group by s.socioid,s.clavesocioint order by s.clavesocioint) p3  where s.socioid=p.socioid and s.sujetoid=su.sujetoid and p.saldoprestamo >0 and aa.socioid=s.socioid and p3.socioid=s.socioid  order by s.clavesocioint; 