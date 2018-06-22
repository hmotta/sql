
CREATE or replace FUNCTION movimientospagoremesas() RETURNS SETOF tipomovimientoscaja
    AS $_$
declare

r tipomovimientoscaja%rowtype;

begin
  for r in
       select
	tipomovimientoid,
	desctipomovimiento
	from
	  tipomovimiento
	where
		tipomovimientoid in ('EI','RG','EN','WU')
 loop
 

       

    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
	
	
	
