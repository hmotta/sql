insert into empleado (sujetoid, socioid, puesto, sucursalpertenece , activo) values ((select sujetoid from socio where clavesocioint='001-00021-02'),(select socioid from socio where clavesocioint='001-00021-02'),'GERENTE GENERAL','015-','S');

insert into empleado (sujetoid, socioid, puesto, sucursalpertenece , activo) values ((select sujetoid from socio where clavesocioint='001-00779-02'),(select socioid from socio where clavesocioint='001-00779-02'),'VICEPRESIDENTE CONSEJO ADMON','015-','S');

insert into empleado (sujetoid, socioid, puesto, sucursalpertenece , activo) values ((select sujetoid from socio where clavesocioint='001-01929-02'),(select socioid from socio where clavesocioint='001-01929-02'),'SECRETARIO CONSEJO VIGILANCIA','015-','S');

