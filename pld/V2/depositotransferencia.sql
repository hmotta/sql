--tabla deposito transferencia
DROP table depositotransferencia;
CREATE TABLE depositotransferencia
(
  depositotransferenciaid serial NOT NULL,
  nombre text,
  paterno text,
  materno text,
  razonsocial text,
  tipotransferencia text,
  movicajaid integer,-- REFERENCES movicaja(movicajaid),
  CONSTRAINT depositotransferencia_pkey PRIMARY KEY (depositotransferenciaid)
);
