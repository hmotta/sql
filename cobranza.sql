select b.* from (select * from (select * from gestioncredito gc,resultadocobranza rc where gc.resultadocobranzaid=rc.resultadocobranzaid) a left join acuerdocobranza ac on(a.acuerdocobranzaid=ac.acuerdocobranzaid)) B;

select tipoprestamoid,s.clavesocioint,(select nombre||' '||paterno||' '||materno from sujeto where sujetoid=s.sujetoid),p.montoprestamo from prestamos p,socio s where p.socioid=s.socioid;


select tipoprestamoid,s.clavesocioint,(select nombre||' '||paterno||' '||materno from sujeto where sujetoid=s.sujetoid),p.montoprestamo,b.* from (select * from (select * from gestioncredito gc,resultadocobranza rc where gc.resultadocobranzaid=rc.resultadocobranzaid) a left join acuerdocobranza ac on(a.acuerdocobranzaid=ac.acuerdocobranzaid)) B,prestamos p,socio s where p.prestamoid = B.prestamoid and p.socioid=s.socioid;