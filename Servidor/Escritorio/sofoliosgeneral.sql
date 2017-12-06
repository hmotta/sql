
CREATE or replace FUNCTION spfolio(integer, character, integer) RETURNS text
    AS $_$
declare
  preferenciacaja alias for $1;
  pseriecaja alias for $2;
  pconsaldos alias for $3;

  pformato text;

begin

  select * into pformato from spfolionueva(preferenciacaja,pseriecaja,pconsaldos);

  return pformato;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
