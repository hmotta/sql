CREATE or replace FUNCTION cortelinea(integer,date) RETURNS SETOF integer
AS $_$
declare
  pprestamoid alias for $1;
  pfecha alias for $2;
  
  pfecha_anterior date;
  ncorteid integer;
  ndias integer;
  xsaldo_inicial numeric;
  xsaldo_final numeric;
  xsaldo_promedio numeric;
  ndisposiciones integer;
  xmonto_disposiciones numeric;
  xcapital numeric;
  xordinario numeric;
  xmoratorio numeric;
  xpago_minimo numeric;
  
  xdisposiciones numeric;
  begin
	
	if exists (select corteid into ncorteid from corte_linea where lineaid=pprestamoid and fecha_corte<pfecha) then
		--Ya hay un corte anterior
		
		
	else
		--No hay corte anterior ( todo es nuevo )
		select fecha_otorga into pfecha_anterior from prestamos where prestamoid=pprestamoid;
		ndias:= pfecha - pfecha_anterior;
		xsaldo_inicial:=0;
		xsaldo_final := xsaldo_inicial;
		--(+Disposiciones)
		select sum(debe) into xdisposiciones from movslinead(pprestamoid,pfecha_anterior,pfecha);
		--(-Pagos)
		select sum(haber) into xpagos from movslinead(pprestamoid,pfecha_anterior,pfecha);
		--(+intereses generados)
		
		--(+iva por int generados)
		
	end if;
  return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

