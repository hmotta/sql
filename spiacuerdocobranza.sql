CREATE or replace FUNCTION spiacuerdocobranza(text,text,date,character) RETURNS integer
    AS $_$
declare
  pacuerdo alias for $1;
  pmotivoatraso alias for $2;
  pfechacompromiso alias for $3;
  pacuerdocumplido alias for $4;
begin
   insert into acuerdocobranza (acuerdo,motivoatraso,fechacompromiso,acuerdocumplido) values(pacuerdo,pmotivoatraso,pfechacompromiso,pacuerdocumplido);

return currval('acuerdocobranza_acuerdocobranzaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;