CREATE TABLE rangoautorizacion
(
 rangoid 	      integer,
 nivel                character(10),
 montominimo          numeric,
 montomaximo          numeric,
integrantes           integer,
 PRIMARY KEY (rangoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE rangoautorizacion
 OWNER TO postgres;

