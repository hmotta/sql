--agregar columnas para domicilio extrangero
ALTER TABLE generalesconceatucliente ADD COLUMN direccionextranjero text;
ALTER TABLE generalesconceatucliente ADD COLUMN otranacionalidad text;
Alter TABLE solicitudingreso ADD COLUMN paisrfc text;
Alter TABLE solicitudingreso ADD COLUMN email text;
Alter TABLE solicitudingreso ADD COLUMN fiel text;
Alter TABLE datosingresoconceatucliente ADD COLUMN procedencia numeric;
