CREATE TABLE matrizriesgo
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  preguntaid integer REFERENCES preguntasmatrizriesgo(preguntaid),
  respuesta character varying(100),
  riesgo character varying(20),
  valor integer
   )
WITH (
  OIDS=FALSE
);
ALTER TABLE matrizriesgo
 OWNER TO postgres;

