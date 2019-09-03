
CREATE OR REPLACE FUNCTION spsconsultaburoc(date,date) RETURNS SETOF rconsultaburo
    AS $_$
declare
  r rconsultaburo%rowtype;
  pfecha1 alias for $1;
  pfecha2 alias for $2;
  
  dblink1 text;
  dblink2 text;
  f record;
begin

for f in
 select * from sucursales where vigente='S'
 
  loop

        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from  spsconsultaburo('||''''||pfecha1||''''||','||''''||pfecha2||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as (
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
		)
	
        loop
      
          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
