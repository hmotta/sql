

drop TYPE rinversionporcaja cascade;
CREATE TYPE rinversionporcaja AS (
	inversionid integer,
	pasoporcaja character
);



CREATE or replace FUNCTION spsinversionporcaja(integer,date) RETURNS SETOF rinversionporcaja
    AS $_$
declare

  psocioid alias for $1;
  pfecha alias for $2;
  r rinversionporcaja%rowtype;
    
begin

 
  for r in
      select inversionid,'S'  from inversion  where fechainversion=pfecha and socioid=psocioid 
  loop
    	IF not exists (select inversionid from movicaja where inversionid=r.inversionid) then
			r.pasoporcaja:='N';
			END IF;
    return next r;
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


