CREATE TABLE carteraabogado (
    carteraabogadoid serial NOT NULL,
    prestamoid integer NOT NULL references prestamos(prestamoid),
    observaciones text,
    expedienteentregado character varying(2),
    abogadoid integer NOT NULL references abogado(abogadoid),
	PRIMARY KEY (carteraabogadoid)
);
