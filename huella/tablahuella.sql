drop table huella;
CREATE TABLE huella
(
  socioid integer not null references socio(socioid),
  cadhuella text not null ,
  PRIMARY KEY (socioid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE huella                                     
  OWNER TO postgres;