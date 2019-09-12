alter table remesa add column producto  character varying(25); 
alter table remesa add column agenciaid integer; 
alter table remesa add column agencia character varying(50); 
alter table remesa add column mtcn character(25);
alter table remesa add column cargos numeric;
alter table remesa add column impuesto numeric;
alter table remesa add column montototal numeric;
alter table remesa add column remitente character varying(50); 
alter table remesa add column descripcion character  varying(25); 
alter table remesa alter column folioenvrec type character  varying(100); 


