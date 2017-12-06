--Crear clase de datos y catalogo
drop table abogados;
CREATE TABLE abogados (
    abogadoid serial PRIMARY KEY,
    nombre character(60),
    direccion character(90),
    telefono character(20),
    correoelectronico character(40)
);

insert into abogados (nombre,direccion,telefono,correoelectronico) values ('LIC. ABOGADO 1','COL. CENTRO, VALLE DE SANTIAGO GTO','TEL','correo@yahoo.com');

--Crear clase de datos y pantalla de captura
drop table cobrolegal;

CREATE TABLE cobrolegal (
    cobrolegalid serial PRIMARY KEY,
    prestamoid int,
    abogadoid int REFERENCES abogados(abogadoid),
    fechacobrolegal date, 
    tipocobrolegalid integer,    
    realiza   character(40),
    textocobrolegal text,
    textoresultado text,
    socioid integer,
    referenciaprestamo character(20)
);


ALTER TABLE ONLY cobrolegal
    ADD CONSTRAINT  cobrolegalsocioid FOREIGN KEY (socioid) REFERENCES socio(socioid);

    
ALTER TABLE ONLY cobrolegal
    ADD CONSTRAINT  legalprestamoid FOREIGN KEY (prestamoid) REFERENCES prestamos(prestamoid);

    
