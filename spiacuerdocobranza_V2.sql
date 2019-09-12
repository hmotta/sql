CREATE or replace FUNCTION spiacuerdocobranza(text,text,date,character,numeric,integer,integer,integer) RETURNS integer
    AS $_$
declare
  pacuerdo alias for $1;
  pmotivoatraso alias for $2;
  pfechacompromiso alias for $3;
  pacuerdocumplido alias for $4;
  pmontocompromiso alias for $5;
  pnumcompromiso alias for $6;
  ptipoacuerdo alias for $7;
  psujetovisita alias for $8;
begin
   insert into acuerdocobranza (acuerdo,motivoatraso,fechacompromiso,acuerdocumplido,montocompromiso,numcompromiso,tipoacuerdo,sujetoidvisitado) values(pacuerdo,pmotivoatraso,pfechacompromiso,pacuerdocumplido,pmontocompromiso,pnumcompromiso,ptipoacuerdo,psujetovisita);

return currval('acuerdocobranza_acuerdocobranzaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;