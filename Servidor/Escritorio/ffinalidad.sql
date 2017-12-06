CREATE FUNCTION ffinalidad(text, text, text) RETURNS text
    AS $_$
declare
  pfinalidad  alias for $1;
  psubfinalida1 alias for $2;
  psubfinalidad2 alias for $3;

  stext text;

begin

  stext:=pfinalidad||' '||psubfinalida1||' '||psubfinalidad2;

return stext;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.ffinalidad(text, text, text) OWNER TO sistema;
