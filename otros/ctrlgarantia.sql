CREATE TABLE controlgarantialiquida
(
  prestamoid integer  REFERENCES prestamos(prestamoid),
  socioid integer REFERENCES socio(socioid),
  p3 numeric,
  aa numeric, 
  ultimomov date
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE controlgarantialiquida
  OWNER TO postgres;
  
