drop table extensiontipomovimiento;
CREATE TABLE extensiontipomovimiento
(
	tipomovimientoid character(2) not null REFERENCES tipomovimiento(tipomovimientoid),
	montominimo numeric,
	montomaximo numeric,
	PRIMARY KEY (tipomovimientoid)
);