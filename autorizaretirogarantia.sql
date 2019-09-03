CREATE TABLE autorizaretirogarantia
(
  autorizacionid serial not null,
  fecha date,
  montoaa numeric,
  montop3 numeric,
  movicajaid integer references movicaja(movicajaid),
  aplicado integer,
  usuarioid  character(20),
  referenciaprestamo character(18) references prestamos(referenciaprestamo) ,
  PRIMARY KEY (autorizacionid) 
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE autorizaretirogarantia
  OWNER TO postgres;
  
