CREATE TABLE datosingresoconceatucliente
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  creditoservicios integer,
  ahorroinversion integer,
  remesa integer,
  montooperaciones numeric,
  intrumentomonetario integer,
  frecuenciaopera integer,
  recursos integer,
  zonageografica integer,
  tiemporesidencia integer,
  afiliacionpolitica integer,
  UNIQUE (socioid),
  UNIQUE (solicitudingresoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE datosingresoconceatucliente
  OWNER TO postgres;
  
