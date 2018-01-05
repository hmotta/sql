drop table operaciones_detectadas_pld;
CREATE TABLE operaciones_detectadas_pld (
    operacionid serial NOT NULL,
	autorizada int,
	socioid integer references socio(socioid),
	sucursal character (8),
	fecha date,
	monto numeric,
	motivo character varying (200),
	riesgo character varying (10),
	PRIMARY KEY  (operacionid)
);