CREATE or replace FUNCTION cortelinea(integer,date) RETURNS SETOF integer
AS $_$
declare
  pprestamoid alias for $1;
  pfecha alias for $2;
  
  pfecha_anterior date;
  ncorteid integer;
  ndias integer;
  nnumdisp integer;
  xsaldo_insoluto numeric;
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
  xpagos numeric;
  xtasa_normal numeric;
  xiva numeric;
  sformula text;
  rec record;
  
  begin
	
	select corteid into ncorteid from corte_linea where lineaid=pprestamoid and fecha_corte<pfecha;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		select fecha_otorga into pfecha_anterior from prestamos where prestamoid=pprestamoid;
		ndias:= pfecha - pfecha_anterior;
		xsaldo_inicial:=0;		
	else
		--Ya hay un corte anterior
		select fecha_corte,saldo_final into pfecha_anterior,xsaldo_inicial from corte_linea where corteid=ncorteid;
		ndias:= pfecha - pfecha_anterior;
		
	end if;
	
	--(+Disposiciones)
	select sum(debe) into xdisposiciones from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov in (1,2);
	xdisposiciones:=coalesce(xdisposiciones,0);
	--(-Pagos)
	select sum(haber) into xpagos from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov=7;
	xpagos:=coalesce(xpagos,0);
	xsaldo_final := xsaldo_inicial + xdisposiciones - xpagos;
	
	select sum(saldo_final) into xsaldo_promedio from saldolineadias(pprestamoid,pfecha_anterior,pfecha);
	xsaldo_promedio:=coalesce(xsaldo_promedio,0);
	xsaldo_promedio:=xsaldo_promedio/ndias;
	
	select count(*) into nnumdisp from movslinead(pprestamoid,pfecha_anterior,pfecha,0) where tipomov in (1);
	
	select spssaldoadeudolinea into xsaldo_insoluto from spssaldoadeudolinea(pprestamoid);
	
	--xcapital := round(xsaldo_insoluto * 0.05,2);
	--xsaldo_promedio := round(xsaldo_promedio * 0.05,2);
	
	select tasanormal into xtasa_normal from prestamos where prestamoid=pprestamoid;
	
	update calculo set saldoinsoluto=xsaldo_insoluto where calculoid=6;
	
	SELECT formula into sformula from calculo where calculoid=6;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||6
	loop
	  xcapital := rec.monto;
	end loop;

	update calculo set saldopromdiario=xsaldo_promedio,dias=ndias,tasaintnormal=xtasa_normal where calculoid=7;
	SELECT formula into sformula from calculo where calculoid=7;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||7
	loop
	  xordinario := rec.monto;
	end loop;
	xiva:=xordinario*0.16;
	
	update calculo set saldoinsoluto=xsaldo_insoluto,saldopromdiario=xsaldo_promedio,dias=ndias,tasaintnormal=xtasa_normal where calculoid=8;
	SELECT formula into sformula from calculo where calculoid=8;
	for rec in execute
	  'SELECT round(' || sformula || ',2) as monto FROM calculo where calculoid='||8
	loop
	  xpago_minimo := rec.monto;
	end loop;
	
	xpago_minimo := xpago_minimo + xiva;
	insert into corte_linea (lineaid,fecha_corte,dias,saldo_inicial,saldo_final,saldo_promedio,num_disposiciones,monto_diposiciones,capital,int_ordinario,int_moratorio,iva,comisiones,pago_minimo) values (pprestamoid,pfecha,ndias,xsaldo_inicial,xsaldo_final,xsaldo_promedio,nnumdisp,xdisposiciones,xcapital,xordinario,0,xiva,0,xpago_minimo);
  return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

