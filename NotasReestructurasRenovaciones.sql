--REESTRUCTURAS - RENOVACIONES
--1 .- Realizar updates
select * from tipoprestamo where tipoprestamoid in ('I1','T1','T2','T3','R1','R2','R3');
select tipoprestamoid,tipoprestamores,desctipoprestamo,cuentaactivo from tipoprestamo where tipoprestamoid in ('I1','T1','T2','T3','R1','R2','R3');

select tipoprestamoid,tipoprestamores,desctipoprestamo,cuentaactivo,clavefinalidad from tipoprestamo ;
update tipoprestamo set tipoprestamores='T1' where clavefinalidad='001';
update tipoprestamo set tipoprestamores='T2' where clavefinalidad='002';
update tipoprestamo set tipoprestamores='T3' where clavefinalidad='003';
update tipoprestamo set estatus=1 where tipoprestamoid in ('I1','T1','T2','T3','R1','R2','R3');
select tipoprestamoid,tipoprestamores,desctipoprestamo,cuentaactivo,clavefinalidad from tipoprestamo order by clavefinalidad,tipoprestamoid;

--updatear la fecharegistro de la tabla prestamos 

update prestamos set fecharegistro = fecha_otorga where fecharegistro is null;

update prestamos set condicionid=3 where prestamoid=9457;

