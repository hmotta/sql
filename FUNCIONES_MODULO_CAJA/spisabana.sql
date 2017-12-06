CREATE OR REPLACE FUNCTION spisabana(integer, integer, character, integer, date, numeric, integer, integer, character varying, character varying, character varying) RETURNS integer
    AS $_$
declare
   pdenominacionid  alias for $1;
   psocioid         alias for $2;
   pseriecaja       alias for $3;
   preferenciacaja  alias for $4;
   pfecha           alias for $5;
   pvalor           alias for $6;
   pcantidad        alias for $7;
   pentradasalida   alias for $8;
   pnumcheque       alias for $9;
   pbanco           alias for $10;
   pnocta           alias for $11;

   iefectivo integer;
   ifilas integer;

begin

	raise notice 'Estoy spisabana';
	--select count(*) INTO ifilas from sabana where seriecaja=pseriecaja and referenciacaja=preferenciacaja;
	--if ifilas = 0 then
		--raise exception 'Mesaje de Alerta';
	--end if;
   insert into sabana(denominacionid,socioid,seriecaja,referenciacaja,fecha,valor,cantidad,entradasalida,numcheque,banco,nocta)
    values(pdenominacionid,psocioid,pseriecaja,preferenciacaja,pfecha,pvalor,pcantidad,pentradasalida,pnumcheque,pbanco,pnocta);


   --select efectivo into iefectivo from denominacion where denominacionid=pdenominacionid;
   --update movicaja set efectivo=iefectivo where referenciacaja=preferenciacaja and seriecaja=pseriecaja;


return currval('sabana_sabanaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;