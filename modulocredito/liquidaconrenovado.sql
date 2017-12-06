CREATE TABLE liquidaconrenovado
(
 dictaminaid            integer REFERENCES dictaminacredito(dictaminaid),
 prestamoid             integer REFERENCES prestamos(prestamoid),
 nuevoprestamoid        integer REFERENCES prestamos(prestamoid) default null
 
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE liquidaconrenovado
  OWNER TO postgres;
  
  
