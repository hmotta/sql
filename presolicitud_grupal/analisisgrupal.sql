drop table analisisgrupal;
CREATE TABLE analisisgrupal
(
 analisisgrupalid  serial,
 dictamen          text,
 grupo             character(25),
 observacion	   text,
 estatus           integer,
 fecha			   date,
 viable            integer,
 PRIMARY KEY (analisisgrupalid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE analisisgrupal
  OWNER TO postgres;
  

