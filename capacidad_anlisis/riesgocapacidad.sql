CREATE TABLE riesgocapacidad
(
  riesgoid serial not null,
  minimo numeric,
  maximo numeric,
  riesgo character(10),
  PRIMARY KEY (riesgoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE riesgocapacidad
  OWNER TO postgres;
  
  
