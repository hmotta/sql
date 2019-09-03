CREATE or replace FUNCTION spsamortizaciones(integer) RETURNS SETOF amortizaciones
    AS $_$
declare
  r amortizaciones%rowtype;
  pclave alias for $1;
begin

   for r in
      select amortizacionid , prestamoid ,  numamortizacion , fechadepago , importeamortizacion , interesnormal , saldo_absoluto , interespagado,abonopagado , ultimoabono ,iva, totalpago,0,0, 0,0,cobranza,cobranzapagado, moratoriopagado from amortizaciones where prestamoid=pclave order by numamortizacion
    loop
      return next r;
    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;