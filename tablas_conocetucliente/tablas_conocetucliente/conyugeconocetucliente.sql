CREATE TABLE conyugeconceatucliente
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  lugarnacimiento character varying(100),
  ocupacion  character varying(50),
  empresatrabajo character varying(50),
  domiciliotrabajo character varying(200),
  telefono character (10),
  tiempotrabajo character varying(10),
  ingresomensual numeric,
  UNIQUE (socioid),
  UNIQUE (solicitudingresoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE conyugeconceatucliente
  OWNER TO postgres;
