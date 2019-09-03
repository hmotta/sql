CREATE OR REPLACE FUNCTION sigfechaexigibleint(integer, date)
  RETURNS date AS
$BODY$
declare
  pprestamoid alias for $1;
  pfechacorte alias for $2;
 
  r record;
  dfecha date;
  nnumamortizacion integer;
  faplicado numeric;
  finteres numeric;
  --fcapital numeric;
 
begin
	--Fecha de la primera amortizacion ordenadas por fecha
    select fechadepago into dfecha from amortizaciones where prestamoid=pprestamoid and finteres>0 order by fechadepago limit 1;
  --suma lo pagado en interes
  select sum(case when m.cuentaid=t.cuentaintnormal then m.haber else 0 end) as interes into finteres from movicaja mc, movipolizas m, polizas p, prestamos pr,  tipoprestamo t where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and t.tipoprestamoid = pr.tipoprestamoid and m.polizaid = mc.polizaid and m.polizaid=p.polizaid and p.fechapoliza <= pfechacorte;

  finteres:=coalesce(finteres,0);
  --raise notice 'interes pagado = %',finteres;
	if finteres > 0 then
	  faplicado := finteres;
	  for r in
			select numamortizacion,fechadepago,interesnormal
			  from amortizaciones
			 where prestamoid=pprestamoid
			order by fechadepago
		  loop
		--	raise notice 'faplicado= % , r.interesnormal = %',faplicado,r.interesnormal;
			if faplicado>=r.interesnormal then
			  faplicado := faplicado - r.interesnormal;
			  if r.fechadepago<pfechacorte then
				dfecha := r.fechadepago;
				nnumamortizacion := r.numamortizacion;
			--	raise notice 'nnumamortizacion= %',nnumamortizacion;
			  else
				return pfechacorte;
			  end if;
			 else
				exit;
			 end if;
	  end loop;
	end if;
	
	if exists (select fechadepago from amortizaciones where prestamoid=pprestamoid and numamortizacion>nnumamortizacion order by fechadepago limit 1) then
		select fechadepago into dfecha from amortizaciones where prestamoid=pprestamoid and numamortizacion>nnumamortizacion order by fechadepago limit 1;
	end if;
  
return dfecha;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;