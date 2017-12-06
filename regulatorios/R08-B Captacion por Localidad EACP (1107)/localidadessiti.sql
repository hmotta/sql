drop table localidadessiti;
CREATE TABLE localidadessiti (
	clave character(7) NOT NULL,
	localidad character varying(50),
	estado character varying(20),
	PRIMARY KEY (clave)
);