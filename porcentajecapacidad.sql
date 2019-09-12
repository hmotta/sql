CREATE TABLE porcentajecapacidad
(
  porcentajeid serial not null,
  minimo numeric,
  maximo numeric,
  capacidad numeric,
  PRIMARY KEY (porcentajeid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE porcentajecapacidad
  OWNER TO postgres;
  
  
