CREATE TABLE deppromedioconoceatucliente
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  deppromedio numeric,
  pagospromedio  numeric,
  puestopublico integer,
  descrippuesto character varying(150),
  tiempopuesto integer,
  familiarpuestoublico integer,
  descrippuestofam character varying(150),
  tiempopuestofam integer,
  listaofac integer,
  fechaexpediente date,
  UNIQUE (socioid),
  UNIQUE (solicitudingresoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE deppromedioconoceatucliente
  OWNER TO postgres;
