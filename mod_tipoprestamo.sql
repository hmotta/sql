alter table tipoprestamo alter column tipoprestamoid type varchar(3);
alter table condicionescredito alter column tprestamodefault type varchar(3);
alter table dictaminacredito alter column tipoprestamoid type varchar(3);
alter table solicitudprestamo alter column tipoprestamoid type varchar(3);
alter table tasastipoprestamo alter column tipoprestamoid type varchar(3);
alter table tipocreditofinalidad alter column tipoprestamoid type varchar(3);
alter table prestamos alter column tipoprestamoid type varchar(3);
--drop table procampo CASCADE;