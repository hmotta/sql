drop table ingresosactividad;
CREATE TABLE ingresosactividad
(
	ingresoid serial not null,
	actividad character varying(100),
	periodicidad character varying(100),
	antiguedad character varying(10),
	ventasmensual numeric,
	costosmensual numeric,
	remanentemensual numeric,
	domicilioid integer references domicilio(domicilioid),
	PRIMARY KEY (ingresoid)
);