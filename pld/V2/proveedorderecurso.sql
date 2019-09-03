--tabla apoderado legal
DROP table proveedorderecurso;
CREATE TABLE proveedorderecurso
(
  proveedorderecursoid serial NOT NULL,
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
  razonsocial text,
  CONSTRAINT proveedorderecurso_pkey PRIMARY KEY (proveedorderecursoid)
);