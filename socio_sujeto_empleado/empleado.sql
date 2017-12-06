CREATE TABLE empleado
(
	empleadoid serial not null,
	sujetoid integer REFERENCES sujeto(sujetoid),
	socioid integer REFERENCES socio(socioid),
	puesto character varying (50),
	sucursalpertenece character(4),
	activo character (1),
	PRIMARY KEY (empleadoid)
);