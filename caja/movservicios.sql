drop TYPE tipomovimientoscaja cascade;
CREATE TYPE tipomovimientoscaja AS (
 tipomovimientoid character(2),
 desctipomovimiento character varying(30)

);
CREATE or replace FUNCTION movimientosservicios() RETURNS SETOF tipomovimientoscaja
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
		tipomovimientoid in ('CM','CF','MC','SK','TE','DH')
 loop
 

       

    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
	
	
	
