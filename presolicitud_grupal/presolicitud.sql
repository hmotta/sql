drop table presolicitud;
CREATE TABLE presolicitud
(
 presolicitudid  serial not null,
 socioid              integer REFERENCES socio(socioid) ,
 sujetoid             integer   REFERENCES sujeto(sujetoid) not null,
 fechasolicitud       date, 
 actividad            character varying(100),
 noprestamos          integer,
 ingresomensual       numeric,
 pagomesburo          numeric,
 montoanterior        numeric,
 montosolicitado      numeric,
 montoautorizado      numeric,
 dictamen			  integer,
 clasificacionint	  character varying(10),
 clasificacionext	  character varying(10),
 estatus              numeric,
 grupo                character(25),
 PRIMARY KEY (presolicitudid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE presolicitud
  OWNER TO postgres;
  

