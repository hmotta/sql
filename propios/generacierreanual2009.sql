
-- Ejercicio 2010
select setval('periodo_periodoid_seq',max(periodoid)) from periodo;
insert into periodo(ejercicio,periodo,estatus) values(2010,01,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,02,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,03,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,04,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,05,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,06,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,07,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,08,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,09,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,10,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,11,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,12,'A');
insert into periodo(ejercicio,periodo,estatus) values(2010,13,'A');

-- Cuenta de resultado 42020108, Cambiarla para cada entidad.

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('42020108','420201',2,'RESULTADO EJERCCIO 2009','A',' ','2009-01-01','2009-01-01','A',0,0,0,0);

select * from cierreanual('42020108','Z','2009-12-31');



