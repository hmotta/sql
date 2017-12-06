CREATE OR REPLACE FUNCTION generalavado(date, date) RETURNS integer
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
  select referenciacaja,seriecaja,movicajaid,(select sum(debe)-sum(haber) from movipolizas where movipolizaid=mc.movipolizaid) as monto from movicaja mc, polizas po where po.polizaid=mc.polizaid and fechapoliza between pfechai and pfechaf and tipomovimientoid not in ('CH','RE','AG','LE','BU','SM','SI','SQ','SB','ST','TC','MV','IU','OP','MC','CM','SK','CF','TU','ET','ID') and seriepoliza not in ('ZA','WW','Z') and efectivo=1
  
  loop
    --raise notice 'Verificando %,%',r.referenciacaja,r.seriecaja;
	
	if r.monto>50000 then
		select * into cfiltro from verificarelevantes(r.referenciacaja,r.seriecaja,r.movicajaid);
		--raise notice 'Resultado %',cfiltro;
		inumgenerados:=inumgenerados+1;
	end if;
  end loop;
  
return inumgenerados;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;