drop table catalogositi CASCADE;
create table catalogositi
(
	catalogositiid serial not null,
	cuentasiti character(12) not null,
	descripcion character varying(150),
	subcuenta character(12),
	nivel integer,
	naturaleza char,
	primary key (catalogositiid),
	unique (cuentasiti)
);