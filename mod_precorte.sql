update precorte set tipo_cartera_est='1' where tipo_cartera_est='tipo 1';
update precorte set tipo_cartera_est='2' where tipo_cartera_est='tipo 2';
update precorte set tipo_cartera_est='1' where tipo_cartera_est is null;
alter table precorte alter column tipo_cartera_est type integer USING tipo_cartera_est::integer;
ALTER TABLE precorte ALTER COLUMN tipo_cartera_est SET DEFAULT 1;