
drop table chequesemitidos;
CREATE TABLE chequesemitidos
(
	chequeid serial NOT NULL,
	numerocheque integer not null,
	fechacheque date NOT NULL,
	montocheque numeric NOT NULL,
	movibancoid integer NOT NULL REFERENCES movibanco(movibancoid),
	movicajaid integer REFERENCES movicaja(movicajaid),
	socioid integer REFERENCES socio(socioid),
	PRIMARY KEY (chequeid)
);