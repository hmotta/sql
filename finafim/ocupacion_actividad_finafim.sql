drop table ocupacion_actividad_finafim cascade;
CREATE TABLE ocupacion_actividad_finafim (
	ocupacion character varying (40),
	cveActividad_finafim integer,
	Actividad_finafim character varying (90),
	PRIMARY KEY (ocupacion)
);