CREATE TABLE generalesinvestigacion
(
  generalesid serial not null,
  solicitudprestamoid integer  REFERENCES solicitudprestamo(solicitudprestamoid),
  sujetoid integer REFERENCES sujeto(sujetoid),
  calle text,
  colonia text,
  nivelestudios integer,
  nombreestudios text,
  edocivil integer,
  tipodebienes integer,
  nombreconyugue text,
  fechanacconyugue date,
  empresaconyugue text,
  dirempresaconyugue text,
  puestoconyugue character varying(50),
  teltrabajoconyugue character varying(20),
  ingresoconyugue numeric,
  antitrabconyugue  character varying(20),
  tipovivienda integer,
  nombrepropietario text,
  parentesco character varying(50),
  caracter character varying(20),
  docpresentado text,
  clavecatrastal character varying(20),
  tiemporesidencia integer,
  primary key (generalesid),
  unique (solicitudprestamoid,sujetoid)
  )
WITH (
  OIDS=FALSE
);

  
