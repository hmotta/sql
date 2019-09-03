drop table garantiainversion;
CREATE TABLE garantiainversion
(
	garantiainversionid serial not null,
	solicitudprestamoid integer references solicitudprestamo(solicitudprestamoid),
	prestamoid integer references prestamos(prestamoid),
	inversionid integer references inversion(inversionid),
	montocomprometido numeric,
	vigente boolean,
	primary key (garantiainversionid)
);