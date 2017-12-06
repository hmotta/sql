
drop TYPE rinversionpagada cascade;
CREATE TYPE rinversionpagada AS (
	inversionid integer,
	pagada character
);



CREATE or replace FUNCTION spsinversionpagada(integer,date) RETURNS SETOF rinversionpagada
    AS $_$
declare

  psocioid alias for $1;
  pfecha alias for $2;
  r rinversionpagada%rowtype;
  nummovicaja int;
  
begin

 
  for r in
      select inversionid,'N'  from inversion  where fechavencimiento=pfecha and socioid=psocioid 
  loop
    	select count(*) into nummovicaja  from movicaja where inversionid=r.inversionid;
	IF  nummovicaja=2 then
			r.pagada:='S';
			END IF;
    return next r;
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


