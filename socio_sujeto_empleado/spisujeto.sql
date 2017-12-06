CREATE OR REPLACE FUNCTION spisujeto(character varying, character varying, character varying, character, character, integer, date, character varying) RETURNS integer
    AS $_$
declare
  ppaterno alias for $1;
  pmaterno alias for $2;
  pnombre alias for $3;
  prfc alias for $4;
  pcurp alias for $5;
  pedad alias for $6;
  pfecha_nacimiento alias for $7;
  prazonsocial alias for $8;

  psujetoid int4;
  
begin

   --if pfecha_nacimiento='01-01-1900' then
     --raise exception 'La fecha de nacimiento es incorrecta, Verifique !!!';
   --end if;
		
	-- Verificar si ya existe el sujeto

   select MIN(sujetoid) into psujetoid
    from sujeto
   where upper(rtrim(paterno))=upper(rtrim(ppaterno)) and
         upper(rtrim(materno))=upper(rtrim(pmaterno)) and
         upper(rtrim(nombre))=upper(rtrim(pnombre)) and
         upper(rtrim(rfc))=upper(rtrim(prfc));

   psujetoid := coalesce(psujetoid,0);

   if psujetoid>0 then
     -- Ya existe
     update sujeto  
        set paterno = ppaterno,
            materno = pmaterno,
            nombre = pnombre,
            rfc = prfc,
            curp = pcurp,
            edad = pedad,
            fecha_nacimiento = pfecha_nacimiento,
            razonsocial = prazonsocial
      where sujetoid = psujetoid;     
     return psujetoid;
   else
     -- El sujeto no existe
     insert into
            sujeto(paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial)
     values(ppaterno,
            pmaterno,
            pnombre,
            prfc,
            pcurp,
            pedad,
            pfecha_nacimiento,
            prazonsocial);
     return currval('sujeto_sujetoid_seq');
   end if;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;