drop table matrizclientes;
CREATE TABLE matrizclientes (
  id serial,
  socioid integer,
  friesgo1 numeric,
  friesgo2 numeric,
  friesgo3 numeric,
  friesgo4 numeric,
  friesgo5 numeric,
  friesgo6 numeric,
  friesgo7 numeric,
  friesgo8 numeric,
  friesgo9 numeric,
  friesgo10 numeric,
  friesgo11 numeric,
  friesgo12 numeric,
  friesgo13 numeric,
  friesgo14 numeric,
  friesgo15 numeric,
  friesgo16 numeric,
  friesgo17 numeric,
  friesgo18 numeric,
  friesgo19 numeric,
  friesgo20 numeric,
  matrizbase integer default 0,
  promedio numeric,
  last_update date default now()
);
