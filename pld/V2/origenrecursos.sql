--tabla origen de los recursos
DROP table origenrecursos;
CREATE TABLE origenrecursos
(
  origenrecursosid serial NOT NULL,
  socioid integer NOT NULL references socio(socioid),
  sueldo integer,
  actividadprofesional integer,
  actividadcomercial integer,
  pensionporjubilacion integer,
  remesasfamiliares integer,
  rentas integer,
  ingresosdetercero integer,
  ventaactivo integer,
  activovendido text,
  CONSTRAINT origenrecursos_pkey PRIMARY KEY (origenrecursosid)
);
