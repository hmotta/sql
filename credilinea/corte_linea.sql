drop table corte_linea;
CREATE TABLE corte_linea
(
  corteid serial NOT NULL,
  lineaid integer NOT NULL,
  fecha_corte date,
  dias_corte integer,
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
  fecha_limite date,
  dias_capital integer,
  dias_interes integer,
  fecha_pago_interes date,
  fecha_pago_capital date,
  capital_pagado numeric,
  capital_vencido numeric,
  int_ord_dev_balance numeric,
  int_ord_dev_cuent_orden numeric,
  int_mor_dev_balance numeric,
  int_mor_dev_cuent_orden numeric,
  estatus integer,  --1 no pagado, 2 pagado
  CONSTRAINT lineaid_pk PRIMARY KEY (corteid),
  CONSTRAINT lineaid FOREIGN KEY (lineaid)
      REFERENCES prestamos (prestamoid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
