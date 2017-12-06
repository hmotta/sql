CREATE TABLE garantiaadicional
(
 garantiaid 	      serial,
 dictaminaid          integer REFERENCES dictaminacredito(dictaminaid),
 tipo                 character(10),
 cantidad1            integer,
 cantidad2            integer,
 descripcion          text,
  PRIMARY KEY (garantiaid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE garantiaadicional
  OWNER TO postgres;
  
  
