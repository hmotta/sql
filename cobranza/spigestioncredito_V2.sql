--drop FUNCTION spigestioncredito(integer,integer,integer,character,character,date,time);
CREATE or replace FUNCTION spigestioncredito(integer,integer,character,character,date,time,numeric,integer) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  --pnumerodeatraso alias for $2;
  presultadocobranzaid alias for $2;
  petapa alias for $3;
  pusuariogestiona alias for $4;
  pfechagestion alias for $5;
  phoragestion alias for $6;
  psaldo alias for $7;
  pdiasmora alias for $8;
  nnumeroatraso integer;
begin
	select coalesce(max(numerodeatraso),1) into nnumeroatraso from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=pprestamoid;
	
	if exists (select * from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and ac.acuerdocumplido='S' and  gc.prestamoid=pprestamoid and numerodeatraso=1) then
		nnumeroatraso:=nnumeroatraso+1;
	end if;
	
	insert into gestioncredito (prestamoid,numerodeatraso,resultadocobranzaid,etapa,usuariogestiona,fechagestion,horagestion,saldo,diasmora) values(pprestamoid,nnumeroatraso,presultadocobranzaid,petapa,pusuariogestiona,pfechagestion,phoragestion,psaldo,pdiasmora);
  
	return currval('gestioncredito_gestioncreditoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;