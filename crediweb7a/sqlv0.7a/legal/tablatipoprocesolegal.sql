--Crear clase de datos y catalogo
drop table tipoprocesolegal;
CREATE TABLE tipoprocesolegal (
    tipoprocesolegalid serial PRIMARY KEY,
    descripcion character(200)
);

insert into tipoprocesolegal (descripcion) values ('Tipo Procesal 1');
insert into tipoprocesolegal (descripcion) values ('Tipo Procesal 2');
insert into tipoprocesolegal (descripcion) values ('Tipo Procesal 3');
insert into tipoprocesolegal (descripcion) values ('Tipo Procesal 4');
insert into tipoprocesolegal (descripcion) values ('Tipo Procesal 5');
insert into tipoprocesolegal (descripcion) values ('Tipo Procesal 6');
