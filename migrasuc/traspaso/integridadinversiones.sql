select i.inversionid,s.clavesocioint,i.fechainversion, sum(i.depositoinversion-i.retiroinversion) as saldoinversion, sum(haber)-sum(debe) as saldomovs, sum(i.depositoinversion-i.retiroinversion)-(sum(haber)-sum(debe)) as diferencia
  from movicaja m, movipolizas mp, inversion i, tipoinversion t, socio s
 where m.tipomovimientoid='IN' and
       m.estatusmovicaja='A' and 
       i.inversionid = m.inversionid and
       t.tipoinversionid = i.tipoinversionid and
       mp.polizaid = m.polizaid and
       mp.cuentaid = t.cuentapasivo and
       i.socioid = s.socioid
group by i.inversionid,s.clavesocioint,m.inversionid,i.fechainversion
having round(sum(i.depositoinversion-i.retiroinversion),2)<> round(sum(haber)-sum(debe),2);
--order by s.clavesocioint       


select * from inversion where fechainversion > (select min(p.fechapoliza) from polizas p, movicaja mc where inversion.inversionid=mc.inversionid and p.polizaid=mc.polizaid);

