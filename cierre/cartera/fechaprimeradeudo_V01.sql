CREATE OR REPLACE FUNCTION fechaprimeradeudo(integer, date)
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
  fcapital numeric;
 
begin
	--Fecha de la primera amortizacion ordenadas por fecha
	--Parchesote para solventar la pendejada de los de nochix, primera amortizacion en negativo
	if pprestamoid=7883 then
		return current_date;
	end if;
    select fechadepago into dfecha from amortizaciones where prestamoid=pprestamoid order by fechadepago limit 1;
  --suma lo pagado en capital
  select sum(case when m.cuentaid=t.cuentaactivo then m.haber else 0 end) as capital into fcapital from movicaja mc, movipolizas m, polizas p, prestamos pr,  tipoprestamo t where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and t.tipoprestamoid = pr.tipoprestamoid and m.polizaid = mc.polizaid and m.polizaid=p.polizaid and p.fechapoliza <= pfechacorte;

  fcapital:=coalesce(fcapital,0);
  raise notice 'capital pagado = %',fcapital;
	if fcapital > 0 then
	  faplicado := fcapital;
	  for r in
			select numamortizacion,importeamortizacion,fechadepago,interesnormal
			  from amortizaciones
			 where prestamoid=pprestamoid
			order by fechadepago
		  loop
			raise notice 'faplicado= % , r.importeamortizacion = %',faplicado,r.importeamortizacion;
			if faplicado>=r.importeamortizacion then
			  faplicado := faplicado - r.importeamortizacion;
			  if r.fechadepago<=pfechacorte then
				dfecha := r.fechadepago;
				nnumamortizacion := r.numamortizacion;
				raise notice 'nnumamortizacion= %',nnumamortizacion;
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