CREATE OR REPLACE FUNCTION spsmovimientosmenor(integer) RETURNS SETOF rtipomovimiento
    AS $$
declare	
	r rtipomovimiento%rowtype;
	socioid alias for $1;
begin
   for r in
      select  tipomovimientoid,desctipomovimiento from tipomovimiento where tipomovimientoid IN ('AM','AI') and aceptadeposito='S'
    loop
      return next r;
    end loop;
  return;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;