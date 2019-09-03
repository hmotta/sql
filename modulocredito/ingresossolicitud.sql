CREATE TABLE ingresossolicitud
(
  ingresosolid serial not null,
  solicitudprestamoid integer  REFERENCES solicitudprestamo(solicitudprestamoid),
  ingresoid integer,
  tipoingreso integer,
  primary key (ingresosolid)
  --unique (ingresoid,tipoingreso)
);
