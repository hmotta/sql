CREATE or replace FUNCTION cadena2alfanum(text) RETURNS text
    AS $_$
declare

  pcadena alias for $1;
  tlimpia text;
 
begin

 tlimpia:=upper(pcadena);
 tlimpia:=regexp_replace(tlimpia,E'[·¡]','A','g');
 tlimpia:=regexp_replace(tlimpia,E'[È…]','E','g');
 tlimpia:=regexp_replace(tlimpia,E'[ÌÕ]','I','g');
 tlimpia:=regexp_replace(tlimpia,E'[Û”]','O','g');
 tlimpia:=regexp_replace(tlimpia,E'[˙⁄]','U','g');
 tlimpia:=regexp_replace(tlimpia,E'[—Ò]','NI','g');
 tlimpia:=regexp_replace(tlimpia,E'[^A-Z0-9 ]','','g');
 tlimpia:=regexp_replace(tlimpia,E'[ ]{2,}',' ','g');
 tlimpia=trim(tlimpia);
 
return tlimpia;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
