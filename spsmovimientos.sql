drop TYPE rtipomovimiento;
CREATE TYPE rtipomovimiento AS (
	tipomovimientoid character(2),
	desctipomovimiento character(30)
);
CREATE OR REPLACE FUNCTION spsmovimientosmayor(integer) RETURNS SETOF rtipomovimiento
    AS $$
declare	
	r rtipomovimiento%rowtype;
	socioid alias for $1;
begin
   for r in
      select  tipomovimientoid,desctipomovimiento from tipomovimiento where tipomovimientoid NOT IN ('AI','AM') and (desctipomovimiento LIKE '%AHORRO%' OR desctipomovimiento LIKE '%CUENT%' OR desctipomovimiento LIKE '%P3%' OR desctipomovimiento LIKE '%PROMOCION%') and aceptadeposito='S'
    loop
      return next r;
    end loop;
  return;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;
