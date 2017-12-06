CREATE OR REPLACE FUNCTION spssujetoduplicadoc(character, character, character, date) RETURNS SETOF rsujetoduplicado
    AS $_$
declare
  pnombre          alias for $1;
  ppaterno         alias for $2;
  pmaterno         alias for $3;
   pfechanacimiento alias for $4;
  r rsujetoduplicado%rowtype;
  
  --f record;

  dblink1 text;
  dblink2 text;
  
begin

--for f in
 --select * from sucursales where vigente='S'
 
  --loop

        --raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

    --    dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
      --  dblink2:='set search_path to public,'||f.esquema||';select * from  spssujetoduplicado('||''''||pnombre||''''||','||''''||ppaterno||''''||','||''''||pmaterno||''''||','||''''||pfechanacimiento||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      --for r in
        --SELECT * FROM
          --dblink(dblink1,dblink2) as
          --t2(
	--suc character(4),
	--clave character varying(18),
	--nombre character varying(40),
	--paterno character varying(40),
	--materno character varying(40),
	--fecha_nacimiento character(10),
	--status character(12)
	--)
	
      --  loop
      
          return next r;
        --end loop;
  
  --end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;