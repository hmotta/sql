--tabla apoderado legal
DROP table apoderadolegal;
CREATE TABLE apoderadolegal
(
  apoderadoid serial NOT NULL,
  sujetoid integer NOT NULL references sujeto(sujetoid),
  socioid integer NOT NULL references socio(socioid),
  estadonacimiento text,
  paisnacimiento text,
  nacionalidad text,
  ocupacion text,
  profesion text,
  email text,
  fiel text,
  paisrfc text,
  CONSTRAINT apoderadolegal_pkey PRIMARY KEY (apoderadoid)
);