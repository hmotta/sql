insert into empleado (sujetoid, socioid, puesto, sucursalpertenece , activo) values ((select sujetoid from socio where clavesocioint='003-02653-02'),(select socioid from socio where clavesocioint='003-02653-02'),'SECRETARIO CONSEJO ADMON','015-','S');

insert into empleado (sujetoid, socioid, puesto, sucursalpertenece , activo) values ((select sujetoid from socio where clavesocioint='003-04772-02'),(select socioid from socio where clavesocioint='003-04772-02'),'GERENTE COMERCIAL','015-','S');

insert into empleado (sujetoid, socioid, puesto, sucursalpertenece , activo) values ((select sujetoid from socio where clavesocioint='003-05810-02'),(select socioid from socio where clavesocioint='003-05810-02'),'GERENTE ADMINISTRATIVO','015-','S');
