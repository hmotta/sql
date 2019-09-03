
CREATE or replace FUNCTION movimientosseguros() RETURNS SETOF tipomovimientoscaja
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
		tipomovimientoid in ('SA')
 loop
 

       

    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
	
	
	
