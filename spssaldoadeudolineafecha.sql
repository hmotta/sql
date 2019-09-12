CREATE or replace FUNCTION spssaldoadeudolineafecha(integer,date) RETURNS numeric
    AS $_$
declare
  lprestamoid alias for $1;
  pfecha alias for $2;
  fsaldocalculado numeric;
  fcargos numeric;
  fabonos numeric;
begin
	perform verifica_bloqueo_linea(pprestamoid);
	select sum(mp.debe),sum(mp.haber) into fcargos,fabonos from polizas po,movipolizas mp,prestamos p,cat_cuentas_tipoprestamo ct  where po.polizaid=mp.polizaid and mp.prestamoid=p.prestamoid and (ct.tipoprestamoid = p.tipoprestamoid and ct.clavefinalidad = p.clavefinalidad and ct.renovado = p.renovado) and p.prestamoid=lprestamoid and (mp.cuentaid = ct.cuentaactivo) and po.fechapoliza<=pfecha;

	fcargos:=coalesce(fcargos,0);
	fabonos:=coalesce(fabonos,0);
	fsaldocalculado:=fcargos-fabonos;
  
	return fsaldocalculado;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
