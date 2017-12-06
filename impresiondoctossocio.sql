CREATE TABLE impresiondoctossocio
(
	impresionid serial not null,
	socioid integer references socio(socioid) NOT NULL,
	documentoid integer NOT NULL,
	impreso character (2) NOT NULL,
	fechahoraimpresion timestamp without time zone default now(),
	usuarioimprime character(20) references usuarios(usuarioid),
	PRIMARY KEY (impresionid) 
);
