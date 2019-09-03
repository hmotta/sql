drop TYPE rliquida_renovado cascade;
CREATE TYPE rliquida_renovado AS (
  prestamoid int4,
  revolvente integer,
  capital numeric,
  interesnormal numeric,
  interesmoratorio numeric,
  iva numeric,
  cobranza numeric,
  iva_cobranza numeric,
  total numeric
);

CREATE OR REPLACE FUNCTION calculo_liquida_renovado(integer)
  RETURNS SET OF rliquida_renovado AS $BODY$
declare
  pprestamoid alias for $1;
  nrevolvente integer;
  r rliquida_renovado;
begin
	for l in 
		SELECT prestamoid,tipoprestamoid  from liquidaconrenovado where nuevoprestamoid=pprestamoid
	loop
		select revolvente into nrevolvente from tipoprestamo where tipoprestamoid=l.tipoprestamoid;
		r.revolvente = nrevolvente;
		if nrevolvente=0 then
			SELECT interes,moratorio,iva into r.interesnormal,r.interesmoratorio,r.iva FROM spscalculopago(l.prestamoid);
			SELECT saldoprestamo into r.capital FROM prestamos where prestamoid=l.prestamoid;
			select cobranza,ivacobranza into r.cobranza, r.iva_cobranza from verificacobranza(l.prestamoid,0);
			return next r;
		else
			SELECT select interes,moratorio,iva into r.interesnormal,r.interesmoratorio,r.iva from spscalculopago_linea(l.prestamoid,current_date);
			select spssaldoadeudolinea into r.capital from spssaldoadeudolinea(l.prestamoid);
			return next r;
		end if;
	end loop;
return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;