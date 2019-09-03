drop table socioidtipomov;
CREATE  TABLE socioidtipomov
(
  tipomovimientoid character varying(2) references tipomovimiento (tipomovimientoid),
  socioid integer references socio (socioid),
  primary key (tipomovimientoid),
  unique(tipomovimientoid,socioid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE socioidtipomov                                     
  OWNER TO postgres;
