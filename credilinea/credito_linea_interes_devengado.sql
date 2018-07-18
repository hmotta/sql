drop table credito_linea_interes_devengado
;
CREATE TABLE credito_linea_interes_devengado
(
  devengamientoid serial NOT NULL,
  lineaid integer NOT NULL,
  fecha date,
  saldo numeric,
  interes_diario numeric,
  --interes_acumulado numeric,
  fecha_pago date,
  interes_pagado numeric default 0,
  CONSTRAINT devengamientoid_pk PRIMARY KEY (devengamientoid),
  CONSTRAINT lineaid FOREIGN KEY (lineaid)
      REFERENCES prestamos (prestamoid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
