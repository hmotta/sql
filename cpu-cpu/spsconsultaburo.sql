drop TYPE rconsultaburo cascade;
CREATE TYPE rconsultaburo AS (
    consultaid integer,
	numerodecontrol character(9),
	producto character(3),
	responsabilidad character(1),
	contrato character(2),
	paterno character varying(20),
	materno character varying(20),
	primer_nombre character varying(26),
	segundo_nombre character varying(26),
	fecha_nacimiento date,
	rfc character varying(13),
	edo_civil character(1),
	genero character(1),
	no_ife character varying(20),
	curp character(18),
	direccion1 character varying(40),
	direccion2 character varying(40),
	colonia character varying(40),
	ciudad character varying(40),
	estado character varying(4),
	cp character(5),
	fecha_residencia date,
	telefono character varying(10),
	tipo_domicilio character(1),
	fecha date,
	hora time without time zone,
	usuarioid character(20)
 );
 
CREATE or replace FUNCTION spsconsultaburo(date,date) RETURNS SETOF rconsultaburo
AS $_$
declare
  pfecha1 alias for $1;
  pfecha2 alias for $2;
  r rconsultaburo%rowtype;
begin
	for r in
		select
			cb.consultaid,
			numerodecontrol,
			producto,
			responsabilidad,
			contrato,
			paterno,
			materno,
			primer_nombre,
			segundo_nombre,
			fecha_nacimiento,
			rfc,
			edo_civil,
			genero,
			no_ife,
			curp,
			direccion1,
			direccion2,
			colonia,
			ciudad,
			estado,
			cp,
			fecha_residencia,
			telefono,
			tipo_domicilio,
			fecha,
			substr(hora,1,8),
			usuarioid
		from
			consultaburo cb,
			respuestaburo rb
		where
			cb.consultaid=rb.consultaid and
			fecha between pfecha1 and pfecha2
	loop
		return next r;
	end loop;
end		
$_$
LANGUAGE plpgsql SECURITY DEFINER;
