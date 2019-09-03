--tabla apoderado legal
DROP table propietarioreal;
CREATE TABLE propietarioreal
(
  propietariorealid serial NOT NULL,
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
  CONSTRAINT propietarioreal_pkey PRIMARY KEY (propietariorealid)
);
