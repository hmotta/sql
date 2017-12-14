drop table corte_linea;
CREATE TABLE corte_linea
(
  corteid serial NOT NULL,
  lineaid integer NOT NULL,
  fecha_corte date,
  dias integer,
  saldo_inicial numeric,
  saldo_final numeric,
  saldo_promedio numeric,
  num_disposiciones integer,
  monto_diposiciones numeric,
  capital numeric,
  int_ordinario numeric,
  int_moratorio numeric,
  iva numeric,
  comisiones numeric,
  pago_minimo numeric,
  CONSTRAINT domicilio_pk PRIMARY KEY (lineaid),
  CONSTRAINT lineaid FOREIGN KEY (lineaid)
      REFERENCES prestamos (prestamoid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
