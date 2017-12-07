CREATE TABLE carteraclaveburo (
	prestamoid integer REFERENCES prestamos(prestamoid),
	clave character(2) NOT NULL,
	PRIMARY KEY (prestamoid)
);