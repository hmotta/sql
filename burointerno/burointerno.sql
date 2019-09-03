drop table burointerno;
CREATE TABLE burointerno (
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
	ultimocred character(3),
	descultimocred character varying(30),
	PRIMARY KEY (burointernoid)
);