drop table matrizfactores;
create table matrizfactores (id serial, friesgoid integer not null, valor numeric, descripcion text);

--Tipo operacion
insert into matrizfactores (friesgoid,valor,descripcion) values 
(1,2.5,'PRESTAMO'),
(1,5.5,'AHORRAR'),
(1,8.5,'INVERTIR');

--Estado Zona Geo
insert into matrizfactores (friesgoid,valor,descripcion) values 
(2,2.5,'SUR/ESTE/OESTE'),
(2,5.5,'CENTRO'),
(2,8.5,'NORTE/ESTE/OESTE/EXTRANJERA');

--Nacionalidad
insert into matrizfactores (friesgoid,valor,descripcion) values 
(3,2.5,'MEXICANA'),
(3,0,'N/A'),
(3,8.5,'EXTRANJERA');

--Edad
insert into matrizfactores (friesgoid,valor,descripcion) values 
(4,2.5,'31 A 50'),
(4,5.5,'MAS DE 50'),
(4,8.5,'18 A 30');

--Estado Civil
insert into matrizfactores (friesgoid,valor,descripcion) values 
(5,2.5,'CASADO'),
(5,5.5,'UNION LIBRE'),
(5,8.5,'SOLTERO, VIUDO, DIVORCIADO');

--Actividad
insert into matrizfactores (friesgoid,valor,descripcion) values 
(6,2.5,'PROPIETARIO'),
(6,5.5,'EMPLEADO'),
(6,8.5,'DESEMPLEADO');

--Ingresos Al Mes Por Actividad
insert into matrizfactores (friesgoid,valor,descripcion) values 
(7,2.5,'MAS DE 50,000.00'),
(7,5.5,'10,000.00 A 50,000.00'),
(7,8.5,'MENOS DE 10,000.00');

--Estabilidad Laboral
insert into matrizfactores (friesgoid,valor,descripcion) values 
(8,2.5,'MAS DE 5 AÑOS'),
(8,5.5,'2 A 5 AÑOS'),
(8,8.5,'MENOS DE 2 AÑOS');

--Monto Mes Por Operaciones
insert into matrizfactores (friesgoid,valor,descripcion) values 
(9,2.5,'MENOS DE 30,000.00'),
(9,5.5,'30,000.00 A 50,000.00'),
(9,8.5,'MAS DE 50,000.00');

--Instrumento Monetario
insert into matrizfactores (friesgoid,valor,descripcion) values 
(10,2.5,'CHEQUE'),
(10,5.5,'TRANSFERENCIA'),
(10,8.5,'EFECTIVO');

--Frecuencia Operaciones
insert into matrizfactores (friesgoid,valor,descripcion) values 
(11,2.5,'1 A 4'),
(11,5.5,'5 O 6'),
(11,8.5,'MAS DE 6');

--Propiedad De Los Recursos
insert into matrizfactores (friesgoid,valor,descripcion) values 
(12,2.5,'PROPIOS'),
(12,5.5,'FAMILIA'),
(12,8.5,'OTROS');

--Tipo Residencia
insert into matrizfactores (friesgoid,valor,descripcion) values 
(13,2.5,'CASA'),
(13,5.5,'DEPARTAMENTO'),
(13,8.5,'UNIDAD HABITACIONAL/ VECINDAD');

--Residencia
insert into matrizfactores (friesgoid,valor,descripcion) values 
(14,2.5,'PROPIA'),
(14,5.5,'FAMILIAR'),
(14,8.5,'RENTA');

--Otros Ingresos Mes
insert into matrizfactores (friesgoid,valor,descripcion) values 
(15,2.5,'MAS DE 50,000.00'),
(15,5.5,'20,000.00 A 50,000.00'),
(15,8.5,'MENOS DE 20,000.00');

--Creditos Activos
insert into matrizfactores (friesgoid,valor,descripcion) values 
(16,2.5,'0'),
(16,5.5,'1'),
(16,8.5,'MAS DE 1');

--Estado Creditos
insert into matrizfactores (friesgoid,valor,descripcion) values 
(17,2.5,'LIQUIDADO'),
(17,5.5,'VIGENTE AL CORRIENTE'),
(17,8.5,'VIGENTE EN MORA');

--PEPS
insert into matrizfactores (friesgoid,valor,descripcion) values 
(18,2.5,'NO'),
(18,0,'N/A'),
(18,8.5,'SI');

--OFAC
insert into matrizfactores (friesgoid,valor,descripcion) values 
(19,2.5,'NO EXISTE'),
(19,5.5,'PARECIDOS O SIMILARES'),
(19,8.5,'IDENTICOS');

--Tipo Persona
insert into matrizfactores (friesgoid,valor,descripcion) values 
(20,2.5,'MORAL'),
(20,5.5,'PEFAE'),
(20,8.5,'FISICA');

