drop function spssujetopld(character varying);
drop function spssujetopldc(character);
CREATE OR REPLACE FUNCTION spssujetopldc(character) RETURNS SETOF rsujetopld
    AS $_$
declare
  r rsujetopld%rowtype;
  pclave alias for $1;
  filtro text;

  dblink1 text;
  dblink2 text;
  f record;
begin

for f in
 select * from sucursales where vigente='S'
 
  loop

        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from  spssujetopld('||''''||pclave||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as (
		  sucursal character(3), 
sujetoid integer,
paterno character varying(20),
materno character varying(20),
nombre character varying(40),
rfc character(16),
curp character(20),
edad numeric,
fecha_nacimiento date,
razonsocial character varying(60)
		)
	
        loop
      
          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
