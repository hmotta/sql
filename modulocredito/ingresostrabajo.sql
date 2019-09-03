drop table ingresostrabajo;
CREATE TABLE ingresostrabajo
(
	ingresoid serial not null,
	empresatrabajo character varying(100),
	nombrejefe character varying(100),
	sueldonetomensual numeric,
	observaciones text,
	domicilioid integer references domicilio(domicilioid),
	PRIMARY KEY (ingresoid)
);