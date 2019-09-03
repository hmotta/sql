DROP TABLE ingresoegresoconceatucliente;
CREATE TABLE ingresoegresoconceatucliente
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  actividadgeneral integer,
  actividadprincipal character varying (200),
  salariomensual numeric,
  otrosingresos numeric,
  ingresosfamiliares numeric,
  ingresototal numeric,
  egresomensual numeric,
  ahorromensual numeric,
  UNIQUE (socioid),
  UNIQUE (solicitudingresoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE ingresoegresoconceatucliente
  OWNER TO postgres;
