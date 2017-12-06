drop table cajerosuc;
CREATE   TABLE cajerosuc
(
  serie character varying(2) references parametros (serie_user),
  usuarioid character varying(15) references usuarios(usuarioid),
  suc character varying(4),
  primary key (serie),
  unique (usuarioid),
  unique (serie,usuarioid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE cajerosuc                                     
  OWNER TO postgres;
