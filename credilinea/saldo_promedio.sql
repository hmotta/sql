CREATE TABLE saldo_promedio
(
  saldoid serial not null,
  dia integer NOT NULL,
  fecha date,
  saldo_inicial numeric,
  cargo numeric,
  abono numeric,
  saldo_final numeric,
  CONSTRAINT saldo_promedio_pk PRIMARY KEY (saldoid)
)
WITH (
  OIDS=FALSE
);