CREATE or replace FUNCTION generalavado(date, date) RETURNS integer
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
  select referenciacaja,seriecaja from movicaja mc, polizas po where po.polizaid=mc.polizaid and fechapoliza between pfechai and pfechaf group by referenciacaja,seriecaja
  loop
    raise notice 'Verificando %,%',r.referenciacaja,r.seriecaja;
    select * into cfiltro from verificaprevencion(r.referenciacaja,r.seriecaja);
    raise notice 'Resultado %',cfiltro;
    inumgenerados:=inumgenerados+1;
  end loop;
  
return inumgenerados;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;