

create or replace function verificacobranzafecha(int4,date) RETURNS SETOF rcobranza as
$_$
declare
  pprestamoid alias for $1;
  pfecha alias for $2;
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

IF dfechaotorga<'2012-10-03' THEN
	for l in 
	select * from amortizaciones where prestamoid=pprestamoid and fechadepago<=pfecha-15 and importeamortizacion-abonopagado>0 and cobranzapagado=0
	loop
		r.cobranza:=r.cobranza+100;
		update amortizaciones ar set cobranza=100 where ar.amortizacionid=l.amortizacionid and ar.prestamoid=pprestamoid;
	end loop;

	if pbonifica > 0 then
		r.cobranza:=r.cobranza-pbonifica;
	end if;
	r.ivacobranza:=r.cobranza*giva;
ELSE
	for l in 
	select * from amortizaciones where prestamoid=pprestamoid and fechadepago<=pfecha-15 and importeamortizacion-abonopagado>0 and cobranzapagado=0
	loop
		r.cobranza:=r.cobranza+150;
		update amortizaciones ar set cobranza=150 where ar.amortizacionid=l.amortizacionid and ar.prestamoid=pprestamoid;
	end loop;

	if pbonifica > 0 then
		r.cobranza:=r.cobranza-pbonifica;
	end if;
	r.ivacobranza:=r.cobranza*giva;
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
