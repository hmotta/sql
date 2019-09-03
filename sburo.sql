CREATE FUNCTION sburo(text) RETURNS text
    AS $_$
declare
  scampo alias for $1;
  stmp text;
begin

  stmp:=ltrim(rtrim(upper(scampo)));
  stmp:=replace(stmp,'�','A');
  stmp:=replace(stmp,'�','E');
  stmp:=replace(stmp,'�','I');
  stmp:=replace(stmp,'�','O');
  stmp:=replace(stmp,'�','U');
  stmp:=replace(stmp,'�','N');
  stmp := regexp_replace(stmp, '[^a-z A-Z0-9]*' ,'', 'g');
  stmp := regexp_replace(stmp, '[ ]*' ,' ');
  
return stmp;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
