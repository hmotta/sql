drop table ingresosinvestigacion;
CREATE TABLE ingresosinvestigacion
(
  ingresoinvid serial not null,
  solicitudprestamoid integer  REFERENCES solicitudprestamo(solicitudprestamoid),
  sujetoid integer references sujeto(sujetoid),
  ingresoid integer,
  tipoingreso integer,
  primary key (ingresoinvid),
  unique (ingresoid,tipoingreso)
);
