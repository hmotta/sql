drop table cuentasbloqueadas;
CREATE TABLE cuentasbloqueadas
(
	socioid integer references socio(socioid),
	tipomovimientoid character(2) references tipomovimiento(tipomovimientoid),
	bloqueatodo character(1) not null,
	bloqueovigente character(1) not null,
	motivo character varying(80),
	fechadesbloqueo date,
	usuariodesbloquea character(20),
	PRIMARY KEY (socioid,bloqueovigente),
	UNIQUE (socioid,bloqueovigente)
);