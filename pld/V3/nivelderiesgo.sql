drop table tipoderiesgo;
drop table nivelderiesgo;
CREATE TABLE nivelderiesgo (
    nivelderiesgo integer NOT NULL,
	descripcion character varying(30),
    numcriterios integer,
	valor numeric,
	nivelriesgomin numeric,
	nivelriesgomax numeric,
	PRIMARY KEY  (nivelderiesgo)
);

insert into nivelderiesgo VALUES (1,'ALTO',30,-2,-60,0);
insert into nivelderiesgo VALUES (2,'MEDIO',30,2,1,44);
insert into nivelderiesgo VALUES (3,'BAJO',30,3,45,90);

alter table nivelderiesgosocio alter column promedio TYPE numeric;


