CREATE TABLE pagoburoanalisis
(
  pagoid serial not null,
  solicitudprestamoid integer  REFERENCES solicitudprestamo(solicitudprestamoid),	
  entidad character(18),
  cuenta character(25),
  pagomensual numeric,
  activa integer,
  observaciones text,
  PRIMARY KEY (pagoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE pagoburoanalisis
  OWNER TO postgres;
  
  
