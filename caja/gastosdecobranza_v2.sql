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
  l record;
  r rcobranza%rowtype;
 
  fdias integer;
  famortvencidas integer;
  fiva numeric;
  fcobranza numeric;
  ufechaamortpago date;
  giva numeric;
  
begin

select iva into giva from empresa;

r.cobranza:=0;
r.ivacobranza:=0;
famortvencidas:=0;
  
select coalesce(count(*),0) into famortvencidas from amortizaciones where prestamoid=pprestamoid and fechadepago<=CURRENT_DATE-15 and importeamortizacion-abonopagado>0;

  r.cobranza:=0;
  r.ivacobranza:=r.cobranza*giva;
  
return next r;

end
'
language 'plpgsql' security definer;
