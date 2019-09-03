drop table ingresosterceros;
CREATE TABLE ingresosterceros
(
	ingresoid serial not null,
	motivo character varying(30),
	actividadotorgante character varying(100),
	antiguedad character varying(10),
	nombreotorgante character varying(100),
	relacion character varying(25),
	ingresomensual numeric,
	ubicacion character varying(50),
	tipodebien character varying(50),
	contratovigente character (2),
	fechatermino date,
	edadmenor integer,
	edadmayor integer,
	PRIMARY KEY (ingresoid)
);