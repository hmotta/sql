CREATE TABLE parametros_pld (
    parametroid character varying(3) NOT NULL,
	comparador1 character varying(2),
	comparador2 character varying(2),
    monto1 integer,
	monto2 integer,
	porcentaje numeric,
	instrumento character varying(2),
	operacion character varying(2),
	tipo_operacion character varying(2),
	alertar_correo_oc integer,
	solicitar_declaracion integer,
	PRIMARY KEY  (parametroid)
);