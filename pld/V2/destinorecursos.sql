--tabla destino de los recursos
DROP table destinorecursos;
CREATE TABLE destinorecursos
(
  destinorecursosid serial NOT NULL,
  socioid integer NOT NULL references socio(socioid),
  gastospersonales integer,
  inversionenpropiedades integer,
  inversionenactivos integer,
  gastosfamiliares integer,
  inversionencapital integer,
  otros integer,
  otromotivo text,
  CONSTRAINT destinorecursos_pkey PRIMARY KEY (destinorecursosid)
);