CREATE or replace FUNCTION fechaultimapagada(integer, date) RETURNS date
    AS $_$
declare
  pprestamoid alias for $1;
  pfechacorte alias for $2;
 
  r record;
  dfecha date;
  faplicado numeric;
  finteres numeric;
  fcapital numeric;
  nrevolvente integer;
 
begin

	select 
		fecha_otorga,tp.revolvente into dfecha,nrevolvente
	from prestamos p 
		inner join tipoprestamo tp on (p.tipoprestamoid=tp.tipoprestamoid) 
	where 
		prestamoid=pprestamoid;

	if nrevolvente=0 then --Es un credito ordinario con una tabla de amortizaciones
	  select sum(case when (m.cuentaid=ct.cta_cap_vig) then m.haber else 0 end) as capital into fcapital from movicaja mc, movipolizas m, polizas p, prestamos pr,  cat_cuentas_tipoprestamo ct where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and (ct.cat_cuentasid = pr.cat_cuentasid) and m.polizaid = mc.polizaid and m.polizaid=p.polizaid and p.fechapoliza <= pfechacorte;

	  fcapital:=coalesce(fcapital,0);

	  faplicado := fcapital;
	  for r in
			select numamortizacion,importeamortizacion,fechadepago,interesnormal
			  from amortizaciones
			 where prestamoid=pprestamoid
			order by fechadepago
		  loop
			if faplicado>=r.importeamortizacion then
			  faplicado := faplicado - r.importeamortizacion;
			  if r.fechadepago<=pfechacorte then
				dfecha := r.fechadepago;
			  end if;
		   end if;
	  end loop;
	else
		select fecha_corte into dfecha from corte_linea where lineaid=pprestamoid and (capital-capital_pagado)=0 order by fecha_corte desc limit 1;
	end if;
  
return dfecha;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;