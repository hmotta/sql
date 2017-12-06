--tabla buzon
DROP table denunciaspersonal;
CREATE TABLE denunciaspersonal
(
  denunciaspersonalid serial NOT NULL,
  fechaalta date,
  reportante text,
  reportado text,
  empleado_reportado text,
  operacion_sospechosa text,
  comportamiento_sospechoso text,
  sucursal text,
  estatus text,
  horas24 numeric,
  bloqueada numeric,
  CONSTRAINT denunciaspersonal_pkey PRIMARY KEY (denunciaspersonalid)
);
