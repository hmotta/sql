drop table estudiosocioeconomico;
CREATE TABLE estudiosocioeconomico
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  aguapotable integer,
  electricidad integer,
  telefono integer,
  drenaje integer,
  pavimento integer,
  alumbrado integer,
  tiporesidencia  integer,
  zonaresidencia integer,
  numpersonas integer,
  tipocasa integer,
  tipopiso integer,
  otrotipocasa character varying(100),
  sala integer,
  cocina integer,
  comedor integer,
  cochera integer,
  banio     integer,
  numrecamaras integer,
  estereo integer,
  estufa integer,
  computadora integer,
  televisor integer,
  lavadora integer,
  refrigerador integer,
  antena integer,
  observaciones text,
  UNIQUE (socioid),
  UNIQUE (solicitudingresoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE estudiosocioeconomico
  OWNER TO postgres;
