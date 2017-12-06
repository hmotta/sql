
select cd.localidadcnbv,(select localidad from localidadessiti where clave=cd.localidadcnbv) as localidad,count(*) as contratos,(case when cp.tipomovimientoid='IN' then round(sum(deposito+intdevacumulado)) else round(sum(deposito+intdevmensual)) end) from captaciontotal cp, socio s, sujeto su, domicilio d, ciudadesmex cd where fechadegeneracion ='2013-12-31' and cp.socioid=s.socioid and s.sujetoid=su.sujetoid and d.sujetoid=su.sujetoid and cd.ciudadmexid=d.ciudadmexid and cp.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT','PARTE SOCIAL P3') group by cd.localidadcnbv,cp.tipomovimientoid;

select cd.localidadcnbv,(select localidad from localidadessiti where clave=cd.localidadcnbv) as localidad,count(*) as contratos,(case when cp.tipomovimientoid='IN' then sum(deposito+intdevacumulado) else sum(deposito+intdevmensual) end) from captaciontotal cp, socio s, sujeto su, domicilio d, ciudadesmex cd where fechadegeneracion ='2013-12-31' and cp.socioid=s.socioid and s.sujetoid=su.sujetoid and d.sujetoid=su.sujetoid and cd.ciudadmexid=d.ciudadmexid and cp.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT','PARTE SOCIAL P3') group by cp.socioid,cd.localidadcnbv,cp.tipomovimientoid;


select a.localidadcnbv,a.localidad,count(*),sum(saldo) from  (select cd.localidadcnbv,(select localidad from localidadessiti where clave=cd.localidadcnbv) as localidad,(case when cp.tipomovimientoid='IN' then round(deposito+intdevacumulado) else round(deposito+intdevmensual) end) as saldo,cp.tipomovimientoid from captaciontotal cp, socio s, sujeto su, domicilio d, ciudadesmex cd where fechadegeneracion ='2013-12-31' and cp.socioid=s.socioid and s.sujetoid=su.sujetoid and d.sujetoid=su.sujetoid and cd.ciudadmexid=d.ciudadmexid and cp.desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT','PARTE SOCIAL P3','PARTE SOCIAL')) as a group by a.localidadcnbv,a.localidad;

---Consulta definitiva
select a.clasificacion,a.localidadcnbv,a.localidad,count(*),sum(saldo) from captacionxlocalidadc('2013-12-31') as a group by a.clasificacion,a.localidadcnbv,a.localidad;

select a.clasificacion,a.localidadcnbv,a.localidad,count(*),sum(saldo) from captacionxlocalidadc('2014-03-31') as a group by a.clasificacion,a.localidadcnbv,a.localidad;

select a.clasificacion,a.localidadcnbv,a.localidad,count(*),sum(saldo) from captacionxlocalidadc('2014-06-30') as a group by a.clasificacion,a.localidadcnbv,a.localidad;

select a.clasificacion,a.localidadcnbv,a.localidad,count(*),sum(saldo) from captacionxlocalidadc('2014-09-30') as a group by a.clasificacion,a.localidadcnbv,a.localidad;

select a.clasificacion,a.localidadcnbv,a.localidad,count(*),sum(saldo) from captacionxlocalidadc('2014-12-31') as a group by a.clasificacion,a.localidadcnbv,a.localidad;

select a.clasificacion,a.localidadcnbv,a.localidad,count(*),sum(saldo) from captacionxlocalidadc('2015-03-31') as a group by a.clasificacion,a.localidadcnbv,a.localidad;