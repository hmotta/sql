
drop TYPE rinversionpagadareinv cascade;
CREATE TYPE rinversionpagadareinv AS (
	inversionid integer,
	pagada character,
	socioid integer
);



CREATE or replace FUNCTION spsinversionpagadareinv(date) RETURNS SETOF rinversionpagadareinv
    AS $_$
declare

 
  pfecha alias for $1;
  r rinversionpagadareinv%rowtype;
  retirada numeric;
  
begin

 
  for r in
      select inversionid,'N',socioid  from inversion  where fechavencimiento=pfecha and depositoinversion<>retiroinversion and depositoinversion>0
  loop
    	select (depositoinversion-retiroinversion) into retirada  from inversion where inversionid=r.inversionid;
	IF  retirada=0 then
			r.pagada:='S';
			END IF;
    return next r;
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


