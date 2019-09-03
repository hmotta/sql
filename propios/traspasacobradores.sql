

drop function traspasa_cobradores(char(30),char(30),char(30));
create or replace function traspasa_cobradores(char(30),char(30),char(30)) returns int4 as
'
declare
  
  phost alias for $1;
  pdb alias for $2;
  psucursal alias for $3;

  r record;
  psujetoid integer;
begin
 raise notice ''Inicio Traspaso de cobradores''; 

 for r in
      select * from
 dblink(''host=''||''''''''||phost||''''''''||'' dbname=''||''''''''||pdb||''''''''||'' user=sistema  password=1sc4pslu2'',
        ''set search_path to public,''||''''''''||psucursal||''''''''||'';
                   select cobradorid,paterno,materno,nombre,razonsocial from cobradores NATURAL JOIN sujeto;'')
            as t(cobradorid integer,  paterno character varying(20), materno character varying(20), nombre  character varying(40), razonsocial   character varying(60))

  loop
          raise notice ''Insertando sujeto '';
          insert into sujeto (paterno,materno,nombre,razonsocial) values(r.paterno,r.materno,r.nombre,r.razonsocial);
		
	  raise notice ''Insertando cobradorid % '',r.cobradorid;
	  select max(sujetoid) into psujetoid from sujeto;
          insert into cobradores (cobradorid,sujetoid) values(r.cobradorid,psujetoid);
  end loop;

  raise notice ''Termine Cobradores'';


return 1;
end
'
language 'plpgsql' security definer;

--Modo de uso
--select * from traspasa_cobradores('oficinas.yolomecatl.com','cajayolo15','sucursal15');
