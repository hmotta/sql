CREATE or replace FUNCTION spsgarantiaprestamo(integer) RETURNS character varying
    AS $_$
declare
  pprestamoid alias for $1;
  
begin

	if exists (select * from garantiahipotecaria where prestamoid=pprestamoid) then
		return 'HIPOTECARIA';
	elseif exists (select * from garantiaprendaria where prestamoid=pprestamoid) then 
		return 'PRENDARIA';
	elseif exists (select * from avales where prestamoid=pprestamoid and aceptada=1) then 
		return 'AVAL';
	elseif exists (SELECT * FROM controlgarantialiquida where prestamoid=pprestamoid) then 
		return 'LIQUIDA';
	else
		return 'SIN GARANTIA';
	end if;
    

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;