select substring((s.clavesocioint),1,4) as suc, s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio,p.fechapoliza as fechamvto, t.tipomovimientoid as t_mvto, t.desctipomovimiento, m.debe as deposito, m.haber as retiro,p.seriepoliza as s_pol, pa.usuarioid, so.grupo,(select tipoinversionid from inversion where inversionid=mc.inversionid) as tipoinversion,mc.inversionid as inversionid from parametros pa, movicaja mc, polizas p, movipolizas m,tipomovimiento t,socio s, sujeto su, solicitudingreso so where pa.serie_user=mc.seriecaja and su.sujetoid=s.sujetoid and s.clavesocioint = s.clavesocioint and mc.socioid = s.socioid and p.polizaid = mc.polizaid and m.movipolizaid = mc.movipolizaid and s.socioid=so.socioid and t.tipomovimientoid =mc.tipomovimientoid and t.tipomovimientoid in ('PA','IN','AO','AC','AA','AF','CC','AM','AI','AP','P3','TA','AH','PR') and p.seriepoliza !='ZA' and p.seriepoliza !='Z'  and p.seriepoliza !='WW' and p.fechapoliza between '2015-07-01' and '2015-09-30' order by s.clavesocioint, p.fechapoliza;


select 
	mc.movicajaid,
	substring((s.clavesocioint),1,4) as suc, 
	s.clavesocioint,
	su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
	p.fechapoliza as fechamvto, 
	mc.tipomovimientoid as t_mvto, 
	(select desctipomovimiento from tipomovimiento where tipomovimientoid=mc.tipomovimientoid), 
	m.debe as deposito, 
	m.haber as retiro,
	p.seriepoliza as s_pol, 
	(select usuarioid from parametros where serie_user=mc.seriecaja), 
	(select grupo from solicitudingreso where socioid=s.socioid),
	(select tipoinversionid from inversion where inversionid=mc.inversionid) as tipoinversion,
	mc.inversionid as inversionid ,
	mc.efectivo
from 
	movicaja mc, 
	movipolizas m,
	polizas p, 
	socio s, 
	sujeto su
where 
	mc.movipolizaid=m.movipolizaid and
	p.polizaid=m.polizaid and
	s.socioid=mc.socioid and
	su.sujetoid=s.sujetoid and
	mc.tipomovimientoid in ('PA','IN','AO','AC','AA','AF','AM','AI','AP','P3','TA','AH','PR') and 
	p.seriepoliza !='ZA' and 
	p.seriepoliza !='Z'  and 
	p.seriepoliza !='WW' and 
	p.fechapoliza between '2015-10-26' and '2015-10-26' order by s.clavesocioint, p.fechapoliza;
