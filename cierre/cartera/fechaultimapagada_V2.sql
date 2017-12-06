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
 
begin

  select fecha_otorga
      into dfecha
      from prestamos
  where prestamoid=pprestamoid;

  select sum(case when (m.cuentaid=t.cuentaactivo or m.cuentaid=t.cuentaactivoren) then m.haber else 0 end) as capital into fcapital from movicaja mc, movipolizas m, polizas p, prestamos pr,  tipoprestamo t where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and t.tipoprestamoid = pr.tipoprestamoid and m.polizaid = mc.polizaid and m.polizaid=p.polizaid and p.fechapoliza <= pfechacorte;

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
  
return dfecha;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;