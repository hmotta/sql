drop table foliops;
CREATE TABLE foliops
(
	folioid serial NOT NULL,
	socioid integer REFERENCES socio(socioid),
	movicajaid integer not null,-- REFERENCES movicaja(movicajaid), 
	tipomovimientoid character(3),
	ejercicio integer not null,
	periodo integer not null,
	folioini integer not null,
	foliofin integer not null,
	vigente char not null,
	PRIMARY KEY (folioid),
	UNIQUE (movicajaid,tipomovimientoid),
	UNIQUE (tipomovimientoid,ejercicio,periodo,folioini)
);