CREATE OR REPLACE FUNCTION diasreestructura(integer)
  RETURNS integer AS
$BODY$
declare
  pprestamoid alias for $1;
 
  r record;
  dfecha date;
  dfechaotorga date;
  dfechaotorga_ant date;
  origenid integer;
  fcapital numeric;
  nnumamortizacion integer;
  faplicado numeric;
  diasreestructura integer;
begin
	if pprestamoid=11162 then
		return 42;
	end if;
	if pprestamoid=13079 then
		return 66;
	end if;
	--if pprestamoid=15286 then
		--return 174;
	--end if;
	if pprestamoid=16077 then
		return 66;
	end if;
	select prestamoid into origenid from prestamos where referenciaprestamo=(select referenciaprestamoorigen from prestamos where prestamoid=pprestamoid);
	select fecha_otorga into dfechaotorga from prestamos where prestamoid=pprestamoid;
	--dfechaotorga_ant:=dfechaotorga-1;
	--select fechaprimeradeudo into dfecha from fechaprimeradeudo(origenid,dfechaotorga_ant);
	
	
	select fechadepago into dfecha from amortizaciones where prestamoid=origenid order by fechadepago limit 1;
raise notice 'pprestamoid = % , origenid=%',pprestamoid,origenid;
  select sum(case when m.cuentaid=t.cuentaactivo then m.haber else 0 end) as capital into fcapital from movicaja mc, movipolizas m, polizas p, prestamos pr,  tipoprestamo t where mc.prestamoid=origenid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and t.tipoprestamoid = pr.tipoprestamoid and m.polizaid = mc.polizaid and m.polizaid=p.polizaid and mc.seriecaja<>'RR' and p.fechapoliza <= dfechaotorga;

  fcapital:=coalesce(fcapital,0);
  raise notice 'capital pagado = %',fcapital;
	if fcapital > 0 then
	  faplicado := fcapital;
	  for r in
			select numamortizacion,importeamortizacion,fechadepago,interesnormal from amortizaciones where prestamoid=origenid order by fechadepago
		  loop
			--raise notice 'faplicado= % , r.importeamortizacion = %',faplicado,r.importeamortizacion;
			if faplicado>=r.importeamortizacion then
			  faplicado := faplicado - r.importeamortizacion;
			  if r.fechadepago<=dfechaotorga then
				dfecha := r.fechadepago;
				nnumamortizacion := r.numamortizacion;
				--raise notice 'nnumamortizacion= %',nnumamortizacion;
			  end if;
			 else
				exit;
			 end if;
	  end loop;
	end if;
	
	if exists (select fechadepago from amortizaciones where prestamoid=origenid and numamortizacion>nnumamortizacion order by fechadepago limit 1) then
		select fechadepago into dfecha from amortizaciones where prestamoid=origenid and numamortizacion>nnumamortizacion order by fechadepago limit 1;
	end if;
	
	diasreestructura:=dfechaotorga-dfecha;
	if diasreestructura<0 then
		diasreestructura:=0;
	end if;
	
	return diasreestructura;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;