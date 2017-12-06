CREATE or replace FUNCTION spiresultadocobranza(character,text,character,character,integer) RETURNS integer
    AS $_$
declare
  psociolocalizado alias for $1;
  pmotivonolocalizado alias for $2;
  pnombreatiende alias for $3;
  pcomportamiento alias for $4;
  pacuerdocobranzaid alias for $5;
begin
  insert into resultadocobranza (sociolocalizado,motivonolocalizado,nombreatiende,comportamiento,acuerdocobranzaid) values(psociolocalizado,pmotivonolocalizado,pnombreatiende,pcomportamiento,pacuerdocobranzaid);
  
return currval('resultadocobranza_resultadocobranzaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;