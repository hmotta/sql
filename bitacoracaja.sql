select referencia,serie,s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as Nombre,fecha,deposito,retiro,(select desctipomovimiento from tipomovimiento where tipomovimientoid=co.tipomovimientoid) from cortecaja('','2012-08-21',0) co,sujeto su,socio s where s.socioid=co.socioid and su.sujetoid=s.sujetoid and tipomovimientoid not in ('RE','RM','CH','00');