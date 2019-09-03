CREATE or replace FUNCTION dias_mora_linea(integer) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  
  ndias_mora integer;
  begin
	ndias_mora:=0;
	
  return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;