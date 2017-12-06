--select count(*) from conoceatucliente where salariomensual=0 or salariomensual is null;

--select count(*) from conoceatucliente co,solicitudprestamo sp where (co.salariomensual=0 or co.salariomensual is null) and co.socioid=sp.socioid and sp.sueldo>0;

update conoceatucliente set salariomensual = (select sueldo from solicitudprestamo where solicitudprestamoid = (select max(solicitudprestamoid) from solicitudprestamo where socioid=conoceatucliente.socioid and sueldo>0)),otrosingresos = (select otrosingresos from solicitudprestamo where solicitudprestamoid = (select max(solicitudprestamoid) from solicitudprestamo where socioid=conoceatucliente.socioid and sueldo>0)),egresosmensuales = (select gastosordinarios from solicitudprestamo where solicitudprestamoid = (select max(solicitudprestamoid) from solicitudprestamo where socioid=conoceatucliente.socioid and sueldo>0)) where (salariomensual is null or salariomensual=0);

--select count(*) from conoceatucliente where salariomensual=0 or salariomensual is null;

update conoceatucliente set salariomensual =5000.000000 where (salariomensual is null or salariomensual=0);