drop table propiedadinvestigacion;
CREATE TABLE propiedadinvestigacion
(
  propiedadid serial not null, 
  solicitudprestamoid integer  REFERENCES solicitudprestamo(solicitudprestamoid),
  sujetoid integer REFERENCES sujeto(sujetoid),
  tipo character varying(20),
  caracteristicas text,
  valor numeric,
  UNIQUE (propiedadid)
    )
WITH (
  OIDS=FALSE
);
ALTER TABLE propiedadinvestigacion
  OWNER TO postgres;
