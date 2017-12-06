drop table comitecredito;
CREATE TABLE comitecredito
(
 comiteid 	      serial,
 puesto		      character varying(50),
 nombre		      character varying(120),
 PRIMARY KEY (comiteid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE comitecredito
  OWNER TO postgres;
  
  
