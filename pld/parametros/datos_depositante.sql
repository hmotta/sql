--drop table operaciones_detectadas_pld;
CREATE TABLE datos_depositante (
    operacionid serial NOT NULL,
	movicajaid integer references movicaja(movicajaid),
	nombre character varying (200),
	num_identificacion character varying (20),
	PRIMARY KEY  (operacionid)
);