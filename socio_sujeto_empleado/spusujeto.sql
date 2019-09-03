CREATE OR REPLACE FUNCTION spusujeto(integer, character varying, character varying, character varying, character, character, integer, date, character varying) RETURNS integer
    AS $_$
declare
  psujetoid alias for $1;
  ppaterno alias for $2;
  pmaterno alias for $3;
  pnombre alias for $4;
  prfc alias for $5;
  pcurp alias for $6;
  pedad alias for $7;
  pfecha_nacimiento alias for $8;
  prazonsocial alias for $9;

begin

   --if pfecha_nacimiento='01-01-1900' then
--     raise exception 'La fecha de nacimiento es incorrecta, Verifique !!!';
   --end if;

   update sujeto
      set paterno = ppaterno,
          materno = pmaterno,
          nombre = pnombre,
          rfc = prfc,
          curp = pcurp,
          edad = pedad,
          fecha_nacimiento = pfecha_nacimiento,
          razonsocial = prazonsocial
    where sujetoid = psujetoid;

return psujetoid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;