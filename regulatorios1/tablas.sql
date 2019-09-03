DROP table saldoscatmin;
CREATE TABLE saldoscatmin
(
  saldoscatminid serial NOT NULL,
  cuentasiti character(12) NOT NULL references catalogositi(cuentasiti),
  saldoini numeric,
  cargo numeric,
  abono numeric,
  saldofin numeric, 
  ejercicio integer,
  periodo integer,
  CONSTRAINT saldoscatmin_pkey PRIMARY KEY (saldoscatminid),
  unique(ejercicio,periodo,cuentasiti)
);

DROP table relacionsiti;
CREATE TABLE relacionsiti
(
  relacionsitiid serial NOT NULL,
  cuentaid character(24) NOT NULL references catalogo_ctas(cuentaid),
  cuentasiti character(12) NOT NULL references catalogositi(cuentasiti),
  signo integer,
  CONSTRAINT relacionsiti_pkey PRIMARY KEY (relacionsitiid)
);