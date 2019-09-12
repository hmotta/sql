create table cuentaanterior(
	prestamoid integer references prestamos(prestamoid),
	cuentaanterior character varying (15),
	primary key(prestamoid)
)