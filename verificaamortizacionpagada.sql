CREATE or replace FUNCTION verificaamortizacionpagada(character) RETURNS integer
    AS $_$
declare
  preferenciaprestamo alias for $1;

  fAbono numeric;
  fAplicar numeric;
  amor record;
  pprestamoid int4;

  lsaldoprestamo numeric;

  finteres numeric;
  fintpag numeric;
  
begin

select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo;

-- Actualizar interes pagado

  select sum(case when m.cuentaid=ct.cuentaactivo then m.haber else 0 end) as interes into finteres from movicaja mc, movipolizas m, prestamos pr,  cat_cuentas_tipoprestamo ct where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and (ct.tipoprestamoid = pr.tipoprestamoid and ct.clavefinalidad = pr.clavefinalidad and ct.renovado = pr.renovado) and m.polizaid = mc.polizaid;

  update amortizaciones set abonopagado=0 where prestamoid=pprestamoid;

  raise notice ' Interes % prestamoid %',finteres,pprestamoid;

  if finteres > 0 then
    for amor in 
        select *
          from amortizaciones
         where prestamoid=pprestamoid 
      order by fechadepago
    loop

      if finteres > amor.importeamortizacion then
         update amortizaciones set abonopagado=amor.importeamortizacion 
         where amortizacionid=amor.amortizacionid;
         finteres:=finteres-amor.importeamortizacion ;
      else
        if finteres > 0 then
          if amor.abonopagado = amor.importeamortizacion then 
          --    update amortizaciones set importeamortizacion=finteres 
          --   where amortizacionid=amor.amortizacionid;
          end if;
          update amortizaciones set abonopagado=finteres 
          where amortizacionid=amor.amortizacionid;
          finteres:=0;
        end if;
      end if;
      --raise notice ' interes % ',finteres;
    end loop;
  end if;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

--select * from castigoprestamo(1501,'sopypc');