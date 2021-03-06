alter table empleado add usuarioid character(20) references usuarios (usuarioid);
ALTER TABLE empleado ADD unique(usuarioid);
drop table huellaempleado;
CREATE TABLE huellaempleado
(
  empleadoid integer not null references empleado(empleadoid),
  cadhuella text not null ,
  PRIMARY KEY (empleadoid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE huellaempleado                                     
  OWNER TO postgres;