CREATE TABLE preanalisis
(
 preanalisisid  serial,
 sujetoid             integer   REFERENCES sujeto(sujetoid) not null,
 caracter             text,
 capital              text,
 capacidad            text,
 condicones			  text,
 colateral            text,
 dictamen             text,
 estatus              numeric,
 grupo                character(25),
 PRIMARY KEY (preanalisisid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE preanalisis
  OWNER TO postgres;
  

