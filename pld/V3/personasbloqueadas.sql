drop table personasbloqueadas;
CREATE TABLE personasbloqueadas
(
	personaid serial not null,
	folio integer,
	fecha date,
	paterno character varying (40),
	materno character varying (40),
	nombre character varying (80),
	razonsocial character varying (100),
	rfc character varying (13),
	fechanacimiento date,
	curp character varying (18),
	observaciones text,
	bloqueo integer,
	estatus integer
);
