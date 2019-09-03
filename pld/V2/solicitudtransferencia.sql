--tabla solicitud transferencia
DROP table solicitudtransferencia;
CREATE TABLE solicitudtransferencia
(
  solicitudtransferenciaid serial NOT NULL,
  socioid integer NOT NULL references socio(socioid),
  fecha date,
  tipomovimientoid text NOT NULL references tipomovimiento(tipomovimientoid),
  banco text,
  cuenta text,
  tipoidentificacion text,
  numidentificacion text,
  titular text,
  bancobenef text,
  cuentabancobenef text,
  clabe text,
  monto numeric,
  CONSTRAINT solicitudtransferencia_pkey PRIMARY KEY (solicitudtransferenciaid)
);