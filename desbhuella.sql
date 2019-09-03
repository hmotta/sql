drop table desbhuella;
CREATE TABLE desbhuella
(
	desbhuellaid serial not null,
	referenciacaja integer,
	seriecaja character(2),
	movibancoid integer references movibanco(movibancoid),
	motivo character varying(80),
	descripcion character varying(80),
	usuariodesbloquea character varying(15) references usuarios(usuarioid),	
	unique(referenciacaja)
);