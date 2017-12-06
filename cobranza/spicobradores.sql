CREATE FUNCTION spicobradores(character, character, character, character) RETURNS integer
    AS $_$
declare
 
  ppaterno alias for $1;
  pmaterno alias for $2;
  pnombre  alias for $3;
  prazonsoc alias for $4;

  pcobradorid integer;
  psujetoid integer;
begin

  insert into sujeto(paterno,materno,nombre,razonsocial) values(ppaterno,pmaterno,pnombre,prazonsoc);
  select max(sujetoid) into psujetoid from sujeto;
  select coalesce(max(cobradorid),0)+1 into pcobradorid from cobradores;

  insert into cobradores(cobradorid,sujetoid) values (pcobradorid,psujetoid);
return 1;
end
$_$
    LANGUAGE plpgsql;