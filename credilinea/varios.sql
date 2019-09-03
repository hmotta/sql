alter table tipoprestamo add column revolvente integer not null default 0;
alter table tipoprestamo add column disp_minima integer not null default 0;
alter table solicitudprestamo add column diacorte int;
alter table calculo add column saldopromdiario numeric;
insert into calculo values (6,'Pago Minimo Cap',0,0,0,0,'saldoinsoluto*0.05',0,0,0);
insert into calculo values (7,'Pago Minimo Int',0,0,0,0,'saldopromdiario*dias*((tasaintnormal/100)/360)',0,0,0);
insert into calculo values (8,'Pago Minimo',0,0,0,0,'(saldoinsoluto*0.05)+(saldopromdiario*dias*((tasaintnormal/100)/360))',0,0,0);
alter table dictaminacredito add column diacorte int;
alter table prestamos add column bloqueado numeric not null default 0;

insert into cargoprestamo (tipoprestamoid,cuentaid,descripcioncargo,tipocargo,poramortizacion,apertura,rangoinicial,rangofinal,porcentaje,montocargo,aplicaiva,calculoporfuncion,cuentaiva) values ('LN','6101080601','LN CREDILINEA',0,0,1,0.000000,99999999999.000000,0.5172422111,0.000000,0,0,'2305090401');

alter table prestamos add column pagominimo numeric not null default 0;
alter table prestamos add column fechacorte date;
alter table prestamos add column tipo_cartera_est varchar (20);

