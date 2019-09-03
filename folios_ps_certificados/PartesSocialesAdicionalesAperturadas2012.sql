
-- movimientos
select s.clavesocioint,( select sum(haber) from movipolizas where polizaid=p.polizaid and cuentaid=t.cuentadeposito) as saldoP3,mc.tipomovimientoid,p.fechapoliza from socio s,movicaja mc,polizas p,tipomovimiento t where s.socioid=mc.socioid and t.tipomovimientoid=mc.tipomovimientoid and p.polizaid=mc.polizaid and mc.tipomovimientoid in('P3') and p.fechapoliza between '2012-01-01' and '2012-12-31' and p.seriepoliza not in ('WW','Z','ZA') group by s.clavesocioint,mc.tipomovimientoid,p.fechapoliza,p.polizaid,t.cuentadeposito order by s.clavesocioint;


select s.clavesocioint,( select sum(haber) from movipolizas where polizaid=p.polizaid and cuentaid=t.cuentadeposito) as saldoP3,mc.tipomovimientoid,p.fechapoliza from socio s,movicaja mc,polizas p,tipomovimiento t where s.socioid=mc.socioid and t.tipomovimientoid=mc.tipomovimientoid and p.polizaid=mc.polizaid and mc.tipomovimientoid in('PB') and p.fechapoliza between '2012-01-01' and '2012-12-31' and p.seriepoliza not in ('WW','Z','ZA') group by s.clavesocioint,mc.tipomovimientoid,p.fechapoliza,p.polizaid,t.cuentadeposito order by s.clavesocioint;

--Inversiones

select ca.clavesocioint,ca.inversionid, ca.fechainversion, ca.fechavencimiento, ca.deposito,ca.desctipoinversion from captaciontotal ca, inversion i where ca.inversionid=i.inversionid and ca.tipomovimientoid='IN' and ca.fechainversion>='2012-01-01' and ca.fechainversion <='2012-12-31' and ca.desctipoinversion in ('PARTE SOCIAL ADICIONAL OBLIGAT','PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL 360 DIA') and i.inversionanteriorid is null group by ca.clavesocioint, ca.inversionid, ca.fechainversion,ca.deposito,ca.desctipoinversion, ca.fechavencimiento;