CREATE or replace FUNCTION sptablaamor(numeric, date, character, integer, integer, integer, integer, date, numeric, integer) RETURNS SETOF tablaamor
    AS $_$
declare
  pmonto          alias for $1;
  ppago1          alias for $2;
  ptipoprestamoid alias for $3;
  pnoamor         alias for $4;
  pperiododias    alias for $5;
  pmeses          alias for $6;
  pdiames         alias for $7;
  pfechaotorga    alias for $8;
  ptasanormal     alias for $9;
  psolicitudprestamoid  alias for $10;
  r tablaamor%rowtype;

begin

  for r in select * from sptablaamor(pmonto,ppago1,ptipoprestamoid,pnoamor,pperiododias,pmeses,pdiames,pfechaotorga,ptasanormal)
  loop
    return next r;
  end loop;

return;
end
 $_$
    LANGUAGE plpgsql SECURITY DEFINER;

