select (select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-01-01' and '2013-01-31'and seriepoliza not in ('ZA') and inversionid is null) as Enero, (select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-02-01' and '2013-02-28'and seriepoliza not in ('ZA') and inversionid is null) as Febrero, (select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-03-01' and '2013-03-31'and seriepoliza not in ('ZA') and inversionid is null) as Marzo, (select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-04-01' and '2013-04-30'and seriepoliza not in ('ZA') and inversionid is null) as Abril,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-05-01' and '2013-05-31'and seriepoliza not in ('ZA') and inversionid is null) as Mayo,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-06-01' and '2013-06-30'and seriepoliza not in ('ZA') and inversionid is null) as Junio,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-07-01' and '2013-07-31'and seriepoliza not in ('ZA') and inversionid is null) as Julio,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-08-01' and '2013-08-30'and seriepoliza not in ('ZA') and inversionid is null) as Agosto,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-09-01' and '2013-09-30'and seriepoliza not in ('ZA') and inversionid is null) as Septiembre,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-10-01' and '2013-10-30'and seriepoliza not in ('ZA') and inversionid is null) as Octubre,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-11-01' and '2013-11-30'and seriepoliza not in ('ZA') and inversionid is null) as Noviembre,(select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('41010102') and p.fechapoliza between '2013-12-01' and '2013-12-31'and seriepoliza not in ('ZA') and inversionid is null) as Diciembre;


select sum(debe) from movipolizas mp, polizas p where mp.polizaid=p.polizaid and cuentaid in ('410101020') and p.fechapoliza between '2013-01-01' and '2013-01-31' ;
