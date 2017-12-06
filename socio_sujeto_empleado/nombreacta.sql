drop table nombreacta;
CREATE TABLE nombreacta
(
	nombreactaid serial NOT NULL,
	sujetoid integer REFERENCES sujeto(sujetoid),
	paterno character varying(20) not null,
	materno character varying(20),
	nombre character varying(40) not null,
	PRIMARY KEY (nombreactaid),
	UNIQUE (sujetoid)
);