
drop table captaciontotal;
CREATE table captaciontotal (
        captaciontotalid serial,
        fechadegeneracion date,
	sucursal character(4),
	desctipoinversion character(30),
	clavesocioint character(18),
	nombresocio character varying(80),
	inversionid integer,
	fechainversion date,
	fechavencimiento date,
	tasainteresnormalinversion numeric,
	plazo integer,
	deposito numeric,
	diasvencimiento integer,
	formapagorendimiento integer,
	intdevmensual numeric,
	intdevacumulado numeric,
	saldototal numeric,
	saldopromedio numeric,
	fechapagoinversion date,
	tipomovimientoid character(2),
        cuentaid         char(24),
        localidad        integer      
);


--select tipomovimientoid,cuentaid,sum(deposito),sum(intdevacumulado),sum(saldototal),sum(saldopromedio) from captaciontotal where substring(cuentaid,1,2)='21' group by tipomovimientoid,cuentaid;


--select localidad,sum(deposito),count(captaciontotalid) from captaciontotal where substring(cuentaid,1,2)='21' group by localidad,cuentaid;
