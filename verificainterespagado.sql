CREATE or replace FUNCTION verificainterespagado(character,character) RETURNS integer
    AS $_$
declare
  preferenciaprestamo alias for $1;
  preferenciaprestamoantes alias for $2;

  fAbono numeric;
  fAplicar numeric;
  amor record;
  pprestamoid int4;
  pprestamoantesid int4;
  
  lsaldoprestamo numeric;

  finteres numeric;
  fintpag numeric;
  
begin

select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo;
select prestamoid into pprestamoantesid from prestamos where referenciaprestamo=preferenciaprestamoantes;

-- Actualizar interes pagado

  select sum(case when m.cuentaid=ct.cuentaintnormal then m.haber else 0 end) as interes into finteres from movicaja mc, movipolizas m, prestamos pr,  cat_cuentas_tipoprestamo ct where mc.prestamoid=pprestamoantesid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and (ct.tipoprestamoid = pr.tipoprestamoid and ct.clavefinalidad = pr.clavefinalidad and ct.renovado = pr.renovado) and m.polizaid = mc.polizaid;

  update amortizaciones set interespagado=0 where prestamoid=pprestamoid;

  raise notice ' Interes % prestamoid %',finteres,pprestamoid;

  if finteres > 0 then
    for amor in 
        select *
          from amortizaciones
         where prestamoid=pprestamoid 
      order by fechadepago
    loop

      if finteres > amor.interesnormal then
         update amortizaciones set interespagado=amor.interesnormal 
         where amortizacionid=amor.amortizacionid;
         finteres:=finteres-amor.interesnormal ;
      else
        if finteres > 0 then
          if amor.abonopagado = amor.importeamortizacion then 
          --    update amortizaciones set interesnormal=finteres 
          --   where amortizacionid=amor.amortizacionid;
          end if;
          update amortizaciones set interespagado=finteres 
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