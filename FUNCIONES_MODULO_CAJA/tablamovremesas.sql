drop table movimientoremesas;
CREATE   TABLE movimientoremesas
(
  socioid integer NOT NULL REFERENCES socio(socioid),
  tiporemesa character varying(30),
  nombre character varying(40),
  identificacion character varying(20),
  numeroidentificacion character varying(15),
  folioenvrec integer,
  monto  numeric,
  beneficiario character varying(40),
  recibir_enviar character varying(7),
  fecha date
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE movimientoremesas                                     
  OWNER TO postgres;
