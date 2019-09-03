drop table solicitudreestructura;
CREATE TABLE solicitudreestructura (
	solicitudprestamoid integer references solicitudprestamo(solicitudprestamoid),
	prestamoid integer references prestamos(prestamoid),
	primary key (solicitudprestamoid),
	unique (solicitudprestamoid,prestamoid)
);