CREATE TABLE acuerdocobranza
(
	acuerdocobranzaid serial NOT NULL,
	acuerdo text not null,
	motivoatraso text,
	fechacompromiso date not null,
	acuerdocumplido character(1) not null,
	PRIMARY KEY (acuerdocobranzaid)
);

CREATE TABLE resultadocobranza
(
	resultadocobranzaid serial NOT NULL,
	sociolocalizado character (1) not null,
	motivonolocalizado text,
	nombreatiende character varying (50),
	comportamiento character varying (10), 
	acuerdocobranzaid integer REFERENCES acuerdocobranza(acuerdocobranzaid),
	PRIMARY KEY (resultadocobranzaid)
);


CREATE TABLE gestioncredito
(
	gestioncreditoid serial NOT NULL,
	prestamoid integer not null REFERENCES prestamos(prestamoid),
	numerodeatraso integer not null,
	resultadocobranzaid integer REFERENCES resultadocobranza(resultadocobranzaid),
	etapa character varying (30) not null,
	usuariogestiona character(20) not null,
	fechagestion date not null,
	horagestion time not null,
	PRIMARY KEY (gestioncreditoid)
);
