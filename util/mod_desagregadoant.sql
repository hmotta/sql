alter table precorte add column prestamodescontado character(2);
alter table prestamos add column prestamodescontado character(2);
alter table prestamos add column fechavaluaciongarantia date;
alter table prestamos add column sujetoid integer;

--alter table precorte drop column prestamodescontado;
--alter table prestamos drop column prestamodescontado;
--alter table prestamos drop column fechavaluaciongarantia;
--alter table prestamos drop column sujetoid;