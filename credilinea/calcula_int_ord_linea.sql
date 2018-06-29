--drop type rinteresdiario cascade;
--create type rinteresdiario as (
	--num integer,
	--fecha date,
	--concepto varchar(80),
	--cargo numeric,
	--abono numeric,
	--saldo numeric,
	---interes_diario numeric,
	--interes_acumulado numeric
	--total_pago numeric
--);

CREATE or replace FUNCTION calcula_int_ord_linea(integer,date) RETURNS integer
    AS $_$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;

	dfecha_inicial date;
	ndias_interes integer;
	
	xtasa_ordinaria numeric;
	dfecha_otorga date;
	dfecha date;
	xsaldo numeric;
	xinteres_diario numeric;
	xinteres_acumulado numeric;
	
begin
	select fecha_otorga,tasanormal into dfecha_otorga,xtasa_ordinaria from prestamos  where prestamoid = pprestamoid;
	raise notice 'fecha_otorga=%',dfecha_otorga;
	--se verifica cual fue la ultima fecha del calculo de interes y apartir de ahí se calculan los dias transcurridos
	select max(fecha) into dfecha_inicial from credito_linea_interes_devengado where lineaid=pprestamoid;
	if dfecha_inicial is null then
		--En ves de lo anterior se toma como fecha inicial la fecha del ultimo corte efectivamente pagado
		select fecha_corte into dfecha_inicial from corte_linea where lineaid=pprestamoid and fecha_corte<=pfecha and (capital-capital_pagado)=0 order by fecha_corte desc limit 1;
	
		if dfecha_inicial is null then --No hay cortes pagados entonces se toma entonces se toma la fecha de la primera disposicion que tuvo y apartir de ahi se empieza a calcular el interes
			select min(fecha) into dfecha_inicial from movslinead(pprestamoid,dfecha_otorga,pfecha,0) where tipomov in (1,2);
		end if;
		dfecha_inicial:=coalesce(dfecha_inicial,pfecha);
	end if;
	raise notice 'Fecha inicial=%',dfecha_inicial;
	ndias_interes:=pfecha - dfecha_inicial;
	raise notice 'Dias de interes: %',ndias_interes;
	-- Empieza el algoritmo de calculo a partir de la fecha inicial
	xsaldo:=0;
	xinteres_diario:=0;
	xinteres_acumulado:=0;
	dfecha:=dfecha_inicial;
	for i in 1..ndias_interes loop
		--r.num := i;
		--r.fecha:=dfecha_inicial+i;
		--select spssaldoadeudolineafecha into r.saldo from spssaldoadeudolineafecha(pprestamoid,r.fecha);
		--raise notice 'Saldo=%',r.saldo;
		--r.interes_diario:=round(r.saldo*(xtasa_ordinaria/100/360),6);
		--r.interes_acumulado:=r.interes_acumulado+r.interes_diario;
		--return next r;
		dfecha:=dfecha+1;
		xsaldo:=spssaldoadeudolineafecha(pprestamoid,dfecha);
		xinteres_diario:=round(xsaldo*(xtasa_ordinaria/100/360),6);
		xinteres_acumulado:=xinteres_acumulado+xinteres_diario;
		insert into credito_linea_interes_devengado (lineaid,fecha,saldo,interes_diario,interes_acumulado) values (pprestamoid,dfecha,xsaldo,xinteres_diario,xinteres_acumulado);
	end loop;
	return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;