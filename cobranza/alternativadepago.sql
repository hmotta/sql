CREATE TABLE alternativadepago (
    alternativaid serial NOT NULL,
    prestamoid integer NOT NULL references prestamos(prestamoid),
    alternativa character varying(80),
    observaciones text,
    resolucion text,
    vigente boolean,
	PRIMARY KEY (alternativaid)
);
