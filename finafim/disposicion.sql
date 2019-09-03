drop table disposicion cascade;
CREATE TABLE disposicion (
	disposicionid character (18) NOT NULL,
	fondeadora character varying(30),
	no_disposicion integer,
	monto_original numeric,
	monto_restante numeric,
	PRIMARY KEY (disposicionid)
);