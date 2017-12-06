CREATE FUNCTION sburo(text) RETURNS text
    AS $_$
declare
  scampo alias for $1;
  stmp text;
begin

  stmp:=ltrim(rtrim(upper(scampo)));
  stmp:=replace(stmp,'Á','A');
  stmp:=replace(stmp,'É','E');
  stmp:=replace(stmp,'Í','I');
  stmp:=replace(stmp,'Ó','O');
  stmp:=replace(stmp,'Ú','U');
  stmp:=replace(stmp,'Ñ','N');
  stmp := regexp_replace(stmp, '[^a-z A-Z0-9]*' ,'', 'g');
  stmp := regexp_replace(stmp, '[ ]*' ,' ');
  
return stmp;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	
	--aa--aa
	