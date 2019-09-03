
--funcion para reportear 
CREATE OR REPLACE FUNCTION spssumapagosgrupal(date,date,character) RETURNS numeric
AS $_$
declare
	r record;
	pfechai alias for $1;
	pfechaf alias for $2;
        pgrupo  alias for $3;
	xSuma numeric;
begin
	select sum(m.haber) into xSuma from prestamos p, tipoprestamo tp, movicaja mc, polizas l, movipolizas m, solicitudprestamo sp
 where p.solicitudprestamoid = sp.solicitudprestamoid and l.fechapoliza between pfechai and pfechaf and 
       tp.tipoprestamoid = p.tipoprestamoid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.polizaid=l.polizaid  and
       sp.grupo=pgrupo and 
       m.cuentaid in (tp.cuentaactivo,tp.cuentaactivoren,tp.cuentaintnormal,tp.cuentaintnormalren,tp.cuentaintmora,tp.cuentaintmoraren,tp.cuentaiva);
	
	xSuma := coalesce(xSuma,0);
return xSuma;
end
$_$
    LANGUAGE plpgsql;


