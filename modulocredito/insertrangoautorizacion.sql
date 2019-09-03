insert into rangoautorizacion(rangoid,nivel,montominimo,montomaximo,integrantes) values (1,'ANALISTA',1,15000,1);
insert into rangoautorizacion(rangoid,nivel,montominimo,montomaximo,integrantes) values (2,'SUBCOMITE',15001,30000,1);
insert into rangoautorizacion(rangoid,nivel,montominimo,montomaximo,integrantes) values (3,'COMITE',30000,3000000,1);
insert into rangoautorizacion(rangoid,nivel,montominimo,montomaximo,integrantes) values (4,'GRUPAL1',2000,5000,5);
insert into rangoautorizacion(rangoid,nivel,montominimo,montomaximo,integrantes) values (5,'GRUPAL2',5001,10000,6);
insert into rangoautorizacion(rangoid,nivel,montominimo,montomaximo,integrantes) values (6,'GRUPAL2',10001,15000,7);
insert into rangoautorizacion(rangoid,nivel,montominimo,montomaximo,integrantes) values (7,'GRUPAL3',15001,30000,8);

alter table rangoautorizacion add column integrantes integer;

update productosreca set tipogarantia='01' where tipogarantia='LI';
update productosreca set tipogarantia='02' where tipogarantia='PE';
update productosreca set tipogarantia='03' where tipogarantia='PR';
update productosreca set tipogarantia='04' where tipogarantia='HI';

