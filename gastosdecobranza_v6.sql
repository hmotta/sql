drop TYPE rcobranza cascade;
CREATE TYPE rcobranza AS (
cobranza numeric,
ivacobranza numeric);

drop function verificacobranza(int4);
drop function verificacobranza(int4,numeric);

create or replace function verificacobranza(int4,numeric) RETURNS SETOF rcobranza as
$_$
declare
  pprestamoid alias for $1;
  pbonifica alias for $2;
  l record;
  r rcobranza%rowtype;
 
  fdias integer;
  famortvencidas integer;
  fiva numeric;
  fcobranzaporamort numeric;
  ufechaamortpago date;
  dfechaotorga date;
  giva numeric;
  stipoprestamoid char(3);
  
begin

select iva into giva from empresa;

r.cobranza:=0;
r.ivacobranza:=0;

select fecha_otorga,tipoprestamoid into dfechaotorga,stipoprestamoid from prestamos where prestamoid=pprestamoid;

if stipoprestamoid <> 'CAS' then

IF dfechaotorga<'2015-09-21' THEN
	for l in 
	select * from amortizaciones where prestamoid=pprestamoid and fechadepago<=CURRENT_DATE-15 and importeamortizacion-abonopagado>0 and cobranzapagado=0
	loop
		r.cobranza:=r.cobranza+100;
		update amortizaciones ar set cobranza=100 where ar.amortizacionid=l.amortizacionid and ar.prestamoid=pprestamoid;
	end loop;

	if pbonifica > 0 then
		r.cobranza:=r.cobranza-pbonifica;
	end if;
	r.ivacobranza:=r.cobranza*giva;
ELSE
	--Los gastos de cobranza se eliminan a partir del dia 21/09/2015
	--for l in 
	--select * from amortizaciones where prestamoid=pprestamoid and fechadepago<=CURRENT_DATE-15 and importeamortizacion-abonopagado>0 and cobranzapagado=0
	--loop
		--r.cobranza:=r.cobranza+150;
		--update amortizaciones ar set cobranza=150 where ar.amortizacionid=l.amortizacionid and ar.prestamoid=pprestamoid;
	--end loop;

	--if pbonifica > 0 then
		--r.cobranza:=r.cobranza-pbonifica;
	--end if;
	--r.ivacobranza:=r.cobranza*giva;
	r.cobranza:=0;
	r.ivacobranza:=0;
END IF;
else
	raise notice 'Credito Castigado...';
	r.cobranza:=0;
	r.ivacobranza:=0;
end if;
return next r;

end
$_$
language 'plpgsql' security definer;