drop table generalesconceatucliente;
CREATE TABLE generalesconceatucliente
(
  solicitudingresoid integer  REFERENCES solicitudingreso(solicitudingresoid),
  socioid integer REFERENCES socio(socioid),
  personajuridicaid integer,
  docindentificacion integer,
  numidentificacion  character(15),
  estatustiposocio   integer,
  nacionalidad  integer,
  familiarenempresa integer,
  nombrefamiliarenempresa character varying(50),
  parentescofamiliar character varying(21), 
  puestofamiliar character varying(50),
  descomprobantedom character varying(150),
  refubicadom text,
  poblacionindigena integer,
  localidadresidencia character varying(200),
  UNIQUE (socioid),
  UNIQUE (solicitudingresoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE generalesconceatucliente
  OWNER TO postgres;
  
