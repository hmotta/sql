
CREATE or replace FUNCTION movimientosapoyos() RETURNS SETOF tipomovimientoscaja
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
		tipomovimientoid in ('OP')
 loop
 

       

    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
	
	
	