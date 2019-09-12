CREATE TABLE mensajes
(
  mensajeid serial, 
  socioid  integer,
  mensaje text,  
  usuarioid character(20) not null,
  nombre text,
  vigencia date,
  modulo   integer,
  PRIMARY KEY (mensajeid)	
  
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE mensajes
  OWNER TO postgres;
