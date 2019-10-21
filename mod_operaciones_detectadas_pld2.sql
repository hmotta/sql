alter table operaciones_detectadas_pld add column fecha_deteccion date;
alter table operaciones_detectadas_pld add column foliocaja varchar(20);
alter table operaciones_detectadas_pld add column parametroid varchar(3) references parametros_pld(parametroid);