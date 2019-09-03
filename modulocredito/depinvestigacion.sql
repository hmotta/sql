CREATE TABLE depinvestigacion
(
  dependienteid serial not null, 
  solicitudprestamoid integer  REFERENCES solicitudprestamo(solicitudprestamoid),
  sujetoid integer REFERENCES sujeto(sujetoid),
  nombre text,
  parentesco character varying(50),
  fechanacimiento date,
  UNIQUE (dependienteid)
    )
WITH (
  OIDS=FALSE
);
ALTER TABLE depinvestigacion
  OWNER TO postgres;
