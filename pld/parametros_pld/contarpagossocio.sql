
--funcion para reportear 
CREATE OR REPLACE FUNCTION spscontarpagossocio(integer,date,date) RETURNS numeric
AS $_$
declare
	r record;
	lsocioid alias for $1;
	pfechai alias for $2;
	pfechaf alias for $3;
	xSuma numeric;
begin
	select count(m.haber) into xSuma from prestamos p, tipoprestamo tp, movicaja mc, polizas l, movipolizas m,socio s
 where s.socioid = lsocioid and p.socioid=s.socioid and l.fechapoliza between pfechai and pfechaf and 
       tp.tipoprestamoid = p.tipoprestamoid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.polizaid=l.polizaid  and
       (m.cuentaid = tp.cuentaactivo or m.cuentaid = tp.cuentaactivoren);
	
	xSuma := coalesce(xSuma,0);
return xSuma;
end
$_$
    LANGUAGE plpgsql;


