CREATE TABLE preguntasmatrizriesgo
(
  preguntaid integer ,
  descripcion  character varying(75),
  PRIMARY KEY  (preguntaid)
 )
WITH (
  OIDS=FALSE
);
ALTER TABLE preguntasmatrizriesgo
 OWNER TO postgres;

