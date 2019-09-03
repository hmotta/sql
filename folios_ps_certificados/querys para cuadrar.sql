select s.socioid, s.clavesocioint, ltrim(su.nombre)||' '||ltrim(su.paterno)||' '||ltrim(su.materno) as nombre,prestamoid,referenciaprestamo,montoprestamo,claveestadocredito,dias_de_cobro,numero_de_amor,fechaultimopago,trim(tipoprestamoid),saldoprestamo,fecha_otorga,dias_de_cobro,meses_de_cobro from socio s, sujeto su, prestamos p where su.sujetoid=s.sujetoid and p.socioid=s.socioid and (s.tiposocioid='02' or s.tiposocioid='05') and p.claveestadocredito<> '008' and fecha_1er_pago<=current_date order by socioid,referenciaprestamo;

select ps.socioid,ps.tipomovimientoid,sum((foliofin-folioini+1)*500) as saldofoliops,(select saldomov(ps.socioid,ps.tipomovimientoid,current_date)) as saldoreal from foliops ps where vigente='S' and ps.tipomovimientoid not in ('PSO','PSV') group by ps.socioid,ps.tipomovimientoid;

select clavesocioint,socioid,(select sum((foliofin-folioini+1)*500) as saldofoliops from foliops ps where vigente='S' and ps.tipomovimientoid='P3' and socioid=s.socioid group by ps.socioid) as saldofoliops,(select saldomov(s.socioid,'PA',current_date)) as saldoreal from socio s where estatussocio='02' group by clavesocioint,socioid having(select saldomov(s.socioid,'P3',current_date))>0;

select clavesocioint,socioid,(select sum((foliofin-folioini+1)*500) as saldofoliops from foliops ps where vigente='S' and ps.tipomovimientoid='P3' and socioid=s.socioid group by ps.socioid) as saldofoliops,(select saldomov(s.socioid,'P3',current_date)) as saldoreal from socio s where estatussocio<>'02';


select ps.socioid,ps.tipomovimientoid,sum((foliofin-folioini+1)*500) as saldofoliops,(select saldomov(ps.socioid,ps.tipomovimientoid,current_date)) as saldoreal from foliops ps where vigente='S' and ps.tipomovimientoid ='P3' and socioid=200 group by ps.socioid,ps.tipomovimientoid;

select ps.socioid,ps.tipomovimientoid,sum((foliofin-folioini+1)*500) as saldofoliops,(select saldomov(ps.socioid,ps.tipomovimientoid,current_date)) as saldoreal from foliops ps where vigente='S' group by ps.socioid,ps.tipomovimientoid;