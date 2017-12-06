drop TYPE rcobranza cascade;
CREATE TYPE rcobranza AS (
cobranza numeric,
ivacobranza numeric);

drop function verificacobranza(int4);
drop function verificacobranza(int4,numeric);

create or replace function verificacobranza(int4,numeric) RETURNS SETOF rcobranza as
'
declare
  pprestamoid alias for $1;
  pbonifica alias for $2;
  
  r rcobranza%rowtype;
 
  fdias integer;
  fiva numeric;
  fcobranza numeric;
  ufechaamortpago date;
  giva numeric;
  
begin

select iva into giva from empresa;

select coalesce(min(fechadepago),current_date) into ufechaamortpago from amortizaciones where prestamoid=pprestamoid and fechadepago<CURRENT_DATE and importeamortizacion-abonopagado>0;


if ufechaamortpago < current_date-15 then 

  r.cobranza:=100;
  r.ivacobranza:=100*giva;

else
  r.cobranza:=0;
  r.ivacobranza:=0;

end if;

return next r;

end
'
language 'plpgsql' security definer;
