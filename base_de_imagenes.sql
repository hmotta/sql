drop table catalogodocumentos cascade;
create table catalogodocumentos
(
	documentoid serial not null,
	descripcion character varying (200),
	formato character(3),
	calidadimagen integer,
	tipoimagen character varying (30),
	bitsxpixel integer,
	resolucion integer,
	contraste integer default 0, 
	brillo integer default 0, 
	doscaras boolean, 
	cargaautomatica boolean default true, 
	peso integer,
	primary key (documentoid),
	unique(descripcion)
);

--drop table opcionesdocumento cascade;
--create table opcionesdocumento
--(
--	opcionid serial not null,
--	documentoid integer references catalogodocumentos (documentoid),
--	descripcion character varying (200),
--	primary key (opcionid)
--);

drop table proceso cascade;
create table proceso
(
	procesoid serial not null,
	descripcion character varying (200),
	primary key (procesoid),
	unique(descripcion)
);

drop table documentorequerido cascade;
create table documentorequerido
(
	documentorequeridoid serial not null,
	procesoid integer references proceso (procesoid),
	documentoid integer references catalogodocumentos (documentoid),
	requerido char,
	grupo integer,
	primary key(documentorequeridoid)
);

drop table documentoproceso cascade;
create table documentoproceso
(
	documentoprocesoid serial not null,
	procesoid integer references proceso (procesoid),
	documentoid integer references catalogodocumentos (documentoid),
	rutaarchivo character varying (100),
	solicitudingresoid integer references catalogodocumentos (documentoid),
	socioid integer references catalogodocumentos (documentoid),
	sujetoid integer references catalogodocumentos (documentoid),
	solicitudprestamoid integer references catalogodocumentos (documentoid),
	avalid integer references catalogodocumentos (documentoid),
	generalesid integer references catalogodocumentos (documentoid),
	caracterid integer references catalogodocumentos (documentoid),
	prestamoid integer references catalogodocumentos (documentoid),
	primary key (documentoprocesoid),
	unique(procesoid,documentoid,rutaarchivo),
	unique(procesoid,documentoid,rutaarchivo,solicitudingresoid),
	unique(procesoid,documentoid,rutaarchivo,socioid),
	unique(procesoid,documentoid,rutaarchivo,sujetoid),
	unique(procesoid,documentoid,rutaarchivo,avalid),
	unique(procesoid,documentoid,rutaarchivo,generalesid),
	unique(procesoid,documentoid,rutaarchivo,caracterid),
	unique(procesoid,documentoid,rutaarchivo,prestamoid)
);
