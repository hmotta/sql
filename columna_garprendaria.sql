alter table garantiaprendaria add column aceptada integer default 0;
alter table avales add column aceptada integer default 0;


alter table solicitudprestamo add column referenciaprestamoorigen character(18); 
alter table solicitudprestamo add column renovado  integer default 0; 

alter table dictaminacredito add column hipoteca  integer default 0; 



alter table prestamos add column renovado  integer default 0; 

