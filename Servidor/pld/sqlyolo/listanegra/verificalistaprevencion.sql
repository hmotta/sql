CREATE or replace FUNCTION verificalistaprevencion(character, character, character, character, character) RETURNS text
    AS $_$
declare
  ppaterno alias for $1;
  pmaterno alias for $2;
  pnombre alias for $3;
  prfc alias for $4;
  pcurp alias for $5;
  filtro text;
    
begin

  filtro := 'NORMAL';
  
  if exists (select * from listanegra where cadena like '%'||ppaterno||' '||pmaterno||', '||pnombre||'%') then 
     filtro := 'ENCONTRADO';
  end if;
  if exists (select * from listanegra where cadena like '%'||prfc||'%' and prfc <> '') then 
     filtro := 'ENCONTRADO';
  end if;
  if exists (select * from listanegra where cadena like '%'||pcurp||'%' and pcurp <> '' ) then 
     filtro := 'ENCONTRADO';
  end if;
       
return filtro;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
