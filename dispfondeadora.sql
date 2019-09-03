drop table disposicion;
CREATE TABLE disposicion (
	burointernoid serial NOT NULL,
	fechageneracion date,
	socioid integer REFERENCES socio(socioid),
	pagospactados integer,
	pagosenmora integer,
	creditospagados integer,
	creditosvigentes integer,
	saldototal numeric,
	diasatrasomaximo integer,
	montoultimocred numeric,
	montomaximocred numeric,
	correccionxanios numeric,
	anios numeric,
	calificacion numeric,
	clasificacion character(3),
	PRIMARY KEY (burointernoid)
);