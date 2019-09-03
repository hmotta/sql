CREATE FUNCTION spucobradores(integer, character, character, character, character) RETURNS integer
    AS $_$
declare
 
  pcobradorid alias for $1;
  ppaterno alias for $2;
  pmaterno alias for $3;
  pnombre  alias for $4;
  prazonsoc alias for $5;

  psujetoid integer;
begin

  select coalesce(sujetoid,0) into psujetoid from cobradores where cobradorid=pcobradorid;

  update sujeto set paterno=ppaterno,materno=pmaterno,nombre=pnombre,razonsocial=prazonsoc where sujetoid=psujetoid;
return 1;
end
$_$
    LANGUAGE plpgsql;