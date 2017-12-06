
--select setval('motivobaja_motivobajaid_seq',max(motivobajaid)) from motivobaja;
delete from motivobaja where descripcionmotivo='Mal historial en el Buró de crédito';
delete from motivobaja where descripcionmotivo='Problemas Económicos';
delete from motivobaja where descripcionmotivo='Desintegración del Grupo';

delete from motivobaja where descripcionmotivo='Mal historial en el Buro de credito';
delete from motivobaja where descripcionmotivo='Mal historial crediticio o morosidad interna';
delete from motivobaja where descripcionmotivo='Les queda muy lejos la sucursal';
delete from motivobaja where descripcionmotivo='Enfermedad o compra de medicinas';


insert into motivobaja (descripcionmotivo) values ('Mal historial en el Buro');
insert into motivobaja (descripcionmotivo) values ('Mal historial interno');
--insert into motivobaja (descripcionmotivo) values ('Por ser adulto mayor');
insert into motivobaja (descripcionmotivo) values ('Les queda muy lejos la suc');
--insert into motivobaja (descripcionmotivo) values ('No cuentan con un trabajo fijo');
--insert into motivobaja (descripcionmotivo) values ('No da su capacidad de pago');
insert into motivobaja (descripcionmotivo) values ('Enfermedad o compra de medic');
--insert into motivobaja (descripcionmotivo) values ('Problemas Economicos');
--insert into motivobaja (descripcionmotivo) values ('Desintegracion del Grupo');
alter table motivobaja alter column descripcionmotivo type character(30);