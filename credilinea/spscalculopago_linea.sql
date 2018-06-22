CREATE or replace FUNCTION spscalculopago_linea(integer,date) RETURNS SETOF tcalculopago
    AS $_$
declare
  pprestamoid alias for $1;
  pfecha alias for $2;
  r tcalculopago%rowtype;
  
  rec record;
  xtasa_moratoria numeric;
  sformula text;
  
  ncorte_anterior_id integer;
  ndias_mora integer;
  dfecha_limite date;
  dfecha_corte date;
  dfecha_ortorga date;
  
  xcapital_corte numeric;
  xinteres_corte numeric;
  xmoratorio_corte numeric;
  
  xcapital_pagar numeric;
  xinteres_pagar numeric;
  xmoratorio_pagar numeric;
  
  xpago_minimo numeric;
  xiva numeric;
  xmoratorio_adicional numeric;
  
  xcapital_pagado_actual numeric;
  xinteres_pagado_actual numeric;
  xcapital_vencido numeric;
  xsaldo_linea numeric;
  
  xsaldo_promedio numeric;
  
  ndias_interes integer;
  dfecha_ultimo_pago_int date;

begin
	xcapital_corte:=0;
	xinteres_corte:=0;
	xmoratorio_corte:=0;
	xpago_minimo:=0;
    xiva:=0;
    xmoratorio_adicional:=0;
	xcapital_pagado_actual:=0;
    xinteres_pagado_actual:=0;
	xcapital_pagar:=0;
	xcapital_vencido:=0;
    xinteres_pagar:=0;
    xmoratorio_pagar:=0;
	
	select fecha_otorga into dfecha_ortorga from prestamos where prestamoid=pprestamoid;
	select spssaldoadeudolinea into xsaldo_linea from spssaldoadeudolinea(pprestamoid);
	--
	-- Verifica si hay un corte anterior 
	--
	select corteid into ncorte_anterior_id from corte_linea where lineaid=pprestamoid and fecha_corte<=pfecha order by fecha_corte desc limit 1;
	if NOT FOUND then
		--No hay corte anterior ( todo es nuevo )
		r.prestamoid   := pprestamoid;
		r.amortizacion := 0;
		r.capital      := round(xsaldo_linea,2);
		r.interes      := 0;
		r.moratorio    := 0;
		r.iva          := 0;
		r.total        := 0;
		return next r;
	else
		--Ya hay un corte anterior
		--El capital vencido lo meti en el corte para sumarlo al pago minimo y dejarlo estatico hasta el dia 10
		select 
			fecha_limite,
			fecha_corte,
			(capital+coalesce(capital_vencido,0)-coalesce(capital_pagado,0)),
			int_ordinario,
			int_moratorio 
			into 
			dfecha_limite,
			dfecha_corte,
			xcapital_corte,
			xinteres_corte,
			xmoratorio_corte 
		from corte_linea where corteid=ncorte_anterior_id;
		
		if pfecha>dfecha_limite then --Si el cálculo es mayor a la fecha limite ya le empieza a cobrar intereses
			--El cálculo de interes cambio a petición de la sociedad. ex por día
			select sum(interes_diario) into xinteres_pagar from calcula_int_ord_linea(pprestamoid,pfecha);
			xiva:=xiva+round(xinteres_pagar*0.16,2);
		end if;
		
		if xcapital_corte>0 then
			--Calculo del moratorio del periodo (si lo hay)
			xcapital_pagar:=xcapital_corte;
			select dias_mora_linea into ndias_mora from dias_mora_linea(pprestamoid,pfecha);
			select calcula_int_mor_linea into xmoratorio_pagar from calcula_int_mor_linea(pprestamoid,pfecha);
			xiva:= xiva+round(xmoratorio_pagar*0.16,2);
		else
			xcapital_pagar:=xsaldo_linea;
		end if;
		
		
		
		r.prestamoid   := pprestamoid;
		r.amortizacion := 0;
		r.capital      := round(xcapital_pagar,2);
		r.interes      := round(xinteres_pagar,2);
		r.moratorio    := round(xmoratorio_pagar,2);
		r.iva          := round(xiva,2);
		r.total        := round(xcapital_pagar,2)+round(xinteres_pagar,2)+round(xmoratorio_pagar,2)+round(xiva,2);
		return next r;
		
	end if;
	--ncorte_anterior_id:=coalesce(ncorte_anterior_id,0);

	
	return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
