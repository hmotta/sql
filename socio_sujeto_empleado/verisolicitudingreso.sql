CREATE or replace FUNCTION verisolicitudingreso(integer, character, character, character, character, character, character, character) RETURNS SETOF rverificainsert
    AS $_$
declare
  ppersonajuridica alias for $1;
  pocupacion alias for $2;
  pnombre alias for $3;
  ppaterno alias for $4;
  pmaterno alias for $5;
  prfc alias for $6;
  pcurp alias for $7;
  ptelefono alias for $8;
  
  r rverificainsert%rowtype;
  iacepta integer;
  stextoacepta character(100);
  
begin

  iacepta:=0;
  stextoacepta:='';
  
  if ppersonajuridica <> 1 and pocupacion in ('ABOGADO','GESTOR DE COBRANZA','LICENCIADO','LITIGANTE')  then
     iacepta:= 1;
     stextoacepta:='No se permite dar préstamos a este tipo de ocupaciones';
  end if;

  if char_length(prfc) < 9 then
     iacepta:= 1;
     stextoacepta:='El RFC esta incompleto';
  end if;
  
  --if char_length(pcurp) < 18 then
    -- iacepta:= 1;
     --stextoacepta:='El CURP esta incompleto';
  --end if;

  if char_length(ptelefono) >= 1 and char_length(ptelefono) < 10 then
     iacepta:= 1;
     stextoacepta:='El Telefono esta incompleto';
  end if;
  
  r.verifica:=iacepta;
  r.textoverifica:=stextoacepta;  
  return next r;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
	