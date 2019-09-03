CREATE OR REPLACE FUNCTION generalavadoacumulado(date, date) RETURNS integer
    AS $_$
declare

  pfechai alias for $1;
  pfechaf alias for $2;

  r record;
  iopergen integer;
  cfiltro text;
  inumgenerados integer;    

begin
	inumgenerados:=0;

	for r in 
	--Quitamos los cheques, remesas (dotaciones), pagos de servicios, recargas y seguros.
	select socioid from movicaja mc, polizas po where po.polizaid=mc.polizaid and fechapoliza between pfechai and pfechaf and tipomovimientoid not in ('CH','RE','AG','LE','BU','SM','SI','SQ','SB','ST','TC','MV','IU','OP','MC','CM','SK','CF','TU','ET') and seriepoliza not in ('ZA','WW','Z') group by socioid order by socioid
	loop
		--raise notice 'Verificando %,%',r.referenciacaja,r.seriecaja;
		for r in 
		--Quitamos los cheques, remesas (dotaciones), pagos de servicios, recargas y seguros.
			select socioid from movicaja mc, polizas po where po.polizaid=mc.polizaid and fechapoliza between pfechai and pfechaf and tipomovimientoid not in ('CH','RE','AG','LE','BU','SM','SI','SQ','SB','ST','TC','MV','IU','OP','MC','CM','SK','CF','TU','ET') and seriepoliza not in ('ZA','WW','Z') 
		loop
			--raise notice 'Verificando %,%',r.referenciacaja,r.seriecaja;
			
			--raise notice 'Resultado %',cfiltro;
			inumgenerados:=inumgenerados+1;
		end loop;
		--raise notice 'Resultado %',cfiltro;
		inumgenerados:=inumgenerados+1;
	end loop;  
return inumgenerados;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;