CREATE FUNCTION sptablaamor(numeric, date, character, integer, integer, integer, integer, date, numeric, integer) RETURNS SETOF tablaamor
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
  psolicitudprestamoid alias fro $10;
--  panio     alias for $10;

  r tablaamor%rowtype;
  icalcunorid integer;
--  daytab numeric[2][12]:=array[[31,28,31,30,31,30,31,31,30,31,30,31],
--                              [31,29,31,30,31,30,31,31,30,31,30,31]];

 ibiciesto integer;
begin

--if ((panio%4=0 and panio%100<>0) or panio%400=0) then 
--  ibiciesto:=2;
--else
--  ibiciesto:=1;
--end if;
--raise notice 'anio:%, fin febrero: %',panio,daytab[ibiciesto][2];

  if ptipoprestamoid not in ('N5 ','N17','N18','N53','N54') then
    icalcunorid:=1;
  else
    icalcunorid:=4;
  end if;

  for r in select * from sptablaamorcalculo(pmonto,ppago1,ptipoprestamoid,pnoamor,pperiododias,pmeses,pdiames,pfechaotorga,ptasanormal,icalcunorid)
  loop
    return next r;
  end loop;

return;
end
 $_$
    LANGUAGE plpgsql SECURITY DEFINER;