CREATE or replace FUNCTION EsRemesa(character) RETURNS integer
    AS $_$
declare
  ptipomovimientoid alias for $1;
  
begin

	if ptipomovimientoid in ('RN','EI','EN','RG','WU') then
		return 1;
	else
		return 0;
	end if;
    
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;