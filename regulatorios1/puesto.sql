drop table puesto;
create table puesto
(
	puestoid serial not null,
	descripcion character varying (50),
	primary key (puestoid),
	unique (descripcion)
);

insert into puesto (descripcion) values('APODERADO LEGAL');
insert into puesto (descripcion) values('GERENTE GENERAL');
insert into puesto (descripcion) values('GERENTE COMERCIAL');
insert into puesto (descripcion) values('GERENTE DE ADMINISTRACION');
insert into puesto (descripcion) values('GERENTE DE SISTEMAS');
insert into puesto (descripcion) values('CONTRALOR');
insert into puesto (descripcion) values('ING. DE SOPORTE Y DESARROLLO');
insert into puesto (descripcion) values('JEFE DE CAPTACION');
insert into puesto (descripcion) values('JEFE DE COBRANZA');
insert into puesto (descripcion) values('JEFE DE CREDITO');
insert into puesto (descripcion) values('ANALISTA DE CREDITO');
insert into puesto (descripcion) values('AUDITOR INTERNO');
insert into puesto (descripcion) values('RECURSOS  MAT Y FINANCIEROS');
insert into puesto (descripcion) values('SECRETARIA DE DIRECCION');
insert into puesto (descripcion) values('GERENTE DE SUCURSAL');
insert into puesto (descripcion) values('SUBGERENTE DE SUCURSAL');
insert into puesto (descripcion) values('EJECUTIVO CONTABLE-ADMVO');
insert into puesto (descripcion) values('EJECUTIVO DE CREDITO GRUPAL');
insert into puesto (descripcion) values('EJECUTIVO DE CUENTA');
insert into puesto (descripcion) values('GESTOR DE COBRANZA');
insert into puesto (descripcion) values('PROMOTOR DE CREDITO');
insert into puesto (descripcion) values('AUXILIAR DE MESA DE CONTROL');
insert into puesto (descripcion) values('CAJERO DE SUCURSAL');
insert into puesto (descripcion) values('ASISTENTE DE NOMINAS');
insert into puesto (descripcion) values('SERVICIOS GENERALES');

