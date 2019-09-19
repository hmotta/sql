CREATE OR REPLACE FUNCTION spabonointeres(int4, numeric, numeric)
  RETURNS pg_catalog.int4 AS $BODY$
declare
  pprestamoid alias for $1;
  pabono alias for $2;
  pmoratorio alias for $3;

  fAbono numeric;
  fAplicar numeric;
  amor record;
  finterescalculado numeric;
  

begin

  fAbono := round(pabono,2);
  select interes into finterescalculado from spscalculopago(pprestamoid);
--
-- Actualizar tabla de amortizaciones
--Sólo actualiza la columna de interes pagado, ya no actualiza la fecha

  if fAbono>0 then
    for amor in
        select *
          from amortizaciones
         where prestamoid=pprestamoid and interesnormal-interespagado>0
      order by fechadepago
    loop

      fAplicar := amor.interesnormal - amor.interespagado;

      raise notice ' Abonando interes %',fAplicar;
      if fAbono>=fAplicar then
        update amortizaciones
           set interespagado = interesnormal
         where amortizacionid=amor.amortizacionid;

         fAbono := fAbono - fAplicar;
      else
        if fAbono>0 then
           if finterescalculado = pabono then
              update amortizaciones set interesnormal = interespagado+fAbono where amortizacionid=amor.amortizacionid;
           end if;
           update amortizaciones set interespagado = interespagado+fAbono,moratoriopagado=pmoratorio 
           where amortizacionid=amor.amortizacionid;
           fAbono := 0;
        end if;
      end if;
    end loop;
  end if;

return 1;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;