drop table datosfiscales;
CREATE TABLE datosfiscales
( datofiscalid          serial,
  socioid               int4 REFERENCES socio,
  rfc_con_homoclave     char(15),
  clave_actividad       char(10),
  descripcion_actividad varchar(100),
  clave_regimen_fiscal  char(10),        
  descripcion_regimen_fiscal varchar(100),
  fecha_alta            date,
  observaciones         text
);


CREATE UNIQUE INDEX datosfiscales_socioid ON datosfiscales USING btree (socioid);

