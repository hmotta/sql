
CREATE TABLE gestion (
    gestionid serial,
    prestamoid integer NOT NULL,
    fechagestion date NOT NULL,
    tipogestionid integer NOT NULL,
    realiza character(40),
    textogestion text,
    textoresultado text,
    socioid integer,
    referenciaprestamo character(18)
);

ALTER TABLE ONLY gestion
    ADD CONSTRAINT  gestionsocioid FOREIGN KEY (socioid) REFERENCES socio(socioid);

ALTER TABLE ONLY gestion
    ADD CONSTRAINT  gestionprestamoid FOREIGN KEY (prestamoid) REFERENCES prestamos(socioid);
    

CREATE TABLE telefonosadicional (
    telefonoadicionalid serial,
    socioid integer NOT NULL,
    prioridad integer,
    telefono character varying(15),
    observacion text
);


ALTER TABLE ONLY telefonosadicional
    ADD CONSTRAINT telefonosadicionalsocioid FOREIGN KEY (socioid) REFERENCES socio(socioid);


CREATE TABLE domicilioadicional (
    domicilioadicionalid serial,
    socioid integer NOT NULL,
    prioridad integer,
    descripcion_corta character(20) NOT NULL,
    calle character varying(40) NOT NULL,
    numero_ext character varying(15),
    numero_int character varying(15),
    colonia character varying(40),
    codpostal integer,
    comunidad character varying(50),
    municipio character varying(50),
    observacion text
);


ALTER TABLE ONLY domicilioadicional
    ADD CONSTRAINT domicilioadicionalsocioid FOREIGN KEY (socioid) REFERENCES socio(socioid);

    


