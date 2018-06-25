drop table creditos_lineas_bloqueo;
CREATE TABLE creditos_lineas_bloqueo
(
  bloqueoid serial not null,
  lineaid integer NOT NULL,
  fecha date,
  motivo varchar(200),
  automatico char(1) not null,
  usuario varchar(20),
  estatus char(1),
  vigente char(1),
  PRIMARY KEY (bloqueoid)
)
WITH (
  OIDS=FALSE
);
