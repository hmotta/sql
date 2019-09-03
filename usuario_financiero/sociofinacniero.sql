CREATE TABLE usuariofinanciero
(
  usuarioid serial   ,
  sujetoid integer REFERENCES sujeto(sujetoid) not null,
  solicitudingresoid integer,
  docindentificacion integer,
  numidentificacion character(15),
  actividadprincipal character varying(200),
  nacionalidad integer,
  edonacimiento integer,
  PRIMARY KEY (usuarioid)	
  
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE usuariofinanciero
  OWNER TO postgres;
