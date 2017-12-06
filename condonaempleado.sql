CREATE TABLE condonacionempleado
(
  empleadoid integer  REFERENCES empleado(empleadoid),
  porcentajeinteres integer,
  porcentajemoratorio integer,
  porcentajegastocobranza integer
    )
WITH (
  OIDS=FALSE
);
ALTER TABLE condonacionempleado
  OWNER TO postgres;
