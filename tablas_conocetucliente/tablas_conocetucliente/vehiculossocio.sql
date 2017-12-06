drop TABLE vehiculossocio;
CREATE TABLE vehiculossocio
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  marca character varying(20),
  modelo character varying(25),
  valor numeric
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE vehiculossocio
 OWNER TO postgres;

