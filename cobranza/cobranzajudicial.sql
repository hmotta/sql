CREATE TABLE cobranzajudicial (
    cobranzajudicialid serial NOT NULL,
    proceso character varying(80),
    etapa character varying(80),
    noexpediente character varying(80),
    secretaria character varying(50),
    folio character varying(80),
    fecharecepcion date,
    descripcion text,
    resolucion text,
    vigente character(1),
    carteraabogadoid integer references carteraabogado(carteraabogadoid),
	PRIMARY KEY (cobranzajudicialid)
);
