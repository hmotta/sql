CREATE OR REPLACE FUNCTION spsdolarvalor(date) RETURNS numeric
AS $_$
declare
  	pfecha alias for $1;
	xValor numeric;
begin
	select valor into xValor from dolarvalor where fecha<=pfecha and valor<>0 order by fecha desc limit 1;
return xValor;
end
$_$
    LANGUAGE plpgsql;


