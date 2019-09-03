CREATE TABLE guardavalores
(
 guardavalorid 	      serial,
 prestamoid  integer REFERENCES prestamos(prestamoid),
 garantiaid integer,
 tipogarantia integer,
 estatus    integer,
  PRIMARY KEY (guardavalorid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE guardavalores
  OWNER TO postgres;
  
  
