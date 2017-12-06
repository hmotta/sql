CREATE OR REPLACE FUNCTION diasmorainteres(integer, date, date, integer)
RETURNS integer AS
$BODY$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
	pfechaultimapagada alias for $3;
	pfrecuencia alias for $4;
	dultimoabonointeres date;
	
	ndias integer;
begin
	select MAX(case when m.cuentaid=tp.cuentaintnormal and po.fechapoliza<=pfecha then po.fechapoliza else (case when m.cuentaid=tp.cuentaactivo and po.fechapoliza<=pfecha then po.fechapoliza else pr.fecha_otorga end) end) into dultimoabonointeres from movicaja mc, movipolizas m, polizas po, prestamos pr,  tipoprestamo tp where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and tp.tipoprestamoid = pr.tipoprestamoid and m.polizaid = mc.polizaid and m.polizaid=po.polizaid;
	--raise notice 'pfechaultimapagada %',pfechaultimapagada;
	--raise notice 'dultimoabonointeres %',dultimoabonointeres;
	--raise notice 'pfrecuencia %',pfrecuencia;
	
	if ((pfechaultimapagada-dultimoabonointeres)-pfrecuencia) > 0 then
		ndias:=(pfechaultimapagada-dultimoabonointeres)-pfrecuencia;
	else
		return 0;
	end if;
	
	return ndias;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;