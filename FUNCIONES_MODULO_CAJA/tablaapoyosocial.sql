drop table apoyosocial;
CREATE   TABLE apoyosocial
(
  apoyosocialid serial not null,
  socioid integer NOT NULL REFERENCES socio(socioid),
  tipoapoyo character varying(30),
  nombre character varying(40),
  identificacion character varying(20),
  numeroidentificacion character varying(15),
  monto  numeric,
  fecha date
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE apoyosocial                                     
  OWNER TO postgres;
