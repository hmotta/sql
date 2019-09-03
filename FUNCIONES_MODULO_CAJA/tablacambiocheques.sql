drop table cambiocheques;
CREATE   TABLE cambiocheques
(
  cambioid serial NOT NULL,
  socioid integer not null REFERENCES socio(socioid),
  polizaid integer NOT NULL REFERENCES polizas(polizaid),
  tipocheque character varying(20),
  identificacion character varying(20),
  numeroidentificacion character varying(15),
  numerocheque integer,
  monto  numeric,
  banco character varying(20),
  fecha date,
  beneficiario character varying(100),
  PRIMARY KEY (cambioid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE cambiocheques                                     
  OWNER TO postgres;
