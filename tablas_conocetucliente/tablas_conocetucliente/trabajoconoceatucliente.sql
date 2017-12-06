CREATE TABLE trabajoconceatucliente
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  empresatrabajo character varying(100),
  nombrejefe character varying(100),
  fechaingresotrabajo date,
  tiempolaborando int,
  UNIQUE (socioid),
  UNIQUE (solicitudingresoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE trabajoconceatucliente
  OWNER TO postgres;
  
