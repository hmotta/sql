DROP table analisiscaracter;
CREATE TABLE analisiscaracter
(
  caracterid serial NOT NULL,
  solicitudprestamoid integer NOT NULL references solicitudprestamo(solicitudprestamoid),
  calificacion numeric,
  comentario1 text,
  comentario2 text,
  comentario3 text,
  comentario4 text,
  comentario5 text,
  comentario6 text,
  CONSTRAINT analisiscaracter_pkey PRIMARY KEY (caracterid)
);

DROP table analisiscapital;
CREATE TABLE analisiscapital
(
  capitalid serial NOT NULL,
  solicitudprestamoid integer NOT NULL references solicitudprestamo(solicitudprestamoid),
  calificacion numeric,
  soleconimica1 text,
  soleconimica2 text,
  soleconimica3 text,
  razon1 text,
  razon2 text,
  razon3 text,
  razon4 text,
  cantidad1 numeric,
  cantidad2 numeric,
  cantidad3 numeric,
  cantidad4 numeric,
  CONSTRAINT analisiscapital_pkey PRIMARY KEY (capitalid)
);

DROP table analisiscapacidad;
CREATE TABLE analisiscapacidad
(
  capacidadid serial NOT NULL,
  solicitudprestamoid integer NOT NULL references solicitudprestamo(solicitudprestamoid),
  calificacion numeric,
  comentario1 text,
  comentario2 text,
  comentario3 text,
  comentario4 text,
  comentario5 text,
  cantidad1 numeric,
  cantidad2 numeric,
  cantidad3 numeric,
  cantidad4 numeric,
  cantidad5 numeric,
  CONSTRAINT analisiscapacidad_pkey PRIMARY KEY (capacidadid)
);

DROP table analisiscondiciones;
CREATE TABLE analisiscondiciones
(
  condicionesid serial NOT NULL,
  solicitudprestamoid integer NOT NULL references solicitudprestamo(solicitudprestamoid),
  calificacion numeric,
  comentario1 text,
  comentario2 text,
  comentario3 text,
  comentario4 text,
  finalidad text,
  CONSTRAINT analisiscondiciones_pkey PRIMARY KEY (condicionesid)
);

DROP table analisiscolateral;
CREATE TABLE analisiscolateral
(
  colateralid serial NOT NULL,
  solicitudprestamoid integer NOT NULL references solicitudprestamo(solicitudprestamoid),
  calificacion numeric,
  comentario1 text,
  comentario2 text,
  comentario3 text,
  CONSTRAINT analisiscolateral_pkey PRIMARY KEY (colateralid)
);

DROP table analisisdictamen;
CREATE TABLE analisisdictamen
(
  dictamenid serial NOT NULL,
  solicitudprestamoid integer NOT NULL references solicitudprestamo(solicitudprestamoid),
  mensajedictamen text,
  CONSTRAINT analisisdictamen_pkey PRIMARY KEY (dictamenid)
);