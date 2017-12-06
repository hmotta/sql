alter table empleado add column puestoid integer references puesto (puestoid);
select setval('empleado_empleadoid_seq',max(empleadoid)) from empleado;

--correr en 001
--insert into empleado (sujetoid,socioid,sucursalpertenece,activo,usuarioid,puestoid) values(216,216,'015-','S','mtapia',1);

--correr en 003
--insert into empleado (sujetoid,socioid,sucursalpertenece,activo,usuarioid,puestoid) values(7848,3807,'015-','S','scervantes',6);
--update empleado set sujetoid=7401,socioid=3807,puestoid=2 where empleadoid=2;
--insert into empleado (sujetoid,socioid,sucursalpertenece,activo,usuarioid,puestoid) values(8490,3946,'015-','S','hmota',5);
--update empleado set puestoid=4 where empleadoid= 3;
--update empleado set socioid=3817 where empleadoid= 2;

