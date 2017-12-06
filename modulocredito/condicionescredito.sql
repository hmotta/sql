drop table condicionescredito;
CREATE TABLE condicionescredito
(
	calificacion character varying(3) NOT NULL,
	minimo numeric,
	maximo numeric,
	minreciprocidad numeric,
	maxreciprocidad numeric,
	numavalt1 integer,
	numavalt2 integer,
	numavalt3 integer,
	condicion character(1),
	gprendaria character(1),
	ghipotecaria character(1),
	aporcentaje numeric,
	atipomovimientoid character(2) references tipomovimiento(tipomovimientoid),
	anoamortpagadas integer,
	aseguro character(2) references tipomovimiento(tipomovimientoid),
	amontoseguro numeric,
	incremento numeric,
	tprestamodefault character(3) references tipoprestamo(tipoprestamoid),
	PRIMARY KEY (calificacion,minimo,maximo)
	--UNIQUE (calificacion,minimo,maximo)
);