alter table datosingresoconceatucliente add column operaciones character varying (3);
alter table datosingresoconceatucliente add column servicios character varying (13);
alter table datosingresoconceatucliente add column periodicidad integer;
alter table datosingresoconceatucliente drop column zonageografica

alter table trabajoconceatucliente add column comprobacioningresos character varying (20);

alter table ingresoegresoconceatucliente add column sectoreconomico integer;
alter table ingresoegresoconceatucliente add column estadosactividad character varying (32);
alter table ingresoegresoconceatucliente add column coberturageografica integer; 
alter table ingresoegresoconceatucliente add column origenrecursos character varying (8); 
alter table ingresoegresoconceatucliente add column ventaactivo integer; 
alter table ingresoegresoconceatucliente add column destinorecursos character varying (6); 
alter table ingresoegresoconceatucliente add column otrodestino text; 

alter table deppromedioconoceatucliente add column antiguedad integer; 

alter table nivelderiesgo rename to nivelderiesgosocio;
alter table nivelderiesgosocio add constraint socioid_unique unique(socioid);


insert into estadosmex values (33,33,'EXTRANJERO','EXT');

