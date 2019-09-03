drop table extensionsujeto;
CREATE TABLE extensionsujeto
(
	sujetoid integer REFERENCES sujeto(sujetoid),
	celular character(10) not null,
	PRIMARY KEY (sujetoid),
	UNIQUE (sujetoid,celular)
);