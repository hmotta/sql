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
  total numeric,
  tipoprestamoid character(3)
);

CREATE OR REPLACE FUNCTION calculo_liquida_renovado(integer)
  RETURNS SETOF rliquida_renovado AS 
$BODY$
  --Calcula el monto de capital, interes y demas accesorios que debe pagar, si se liquida con un renovado uno o mas creditos
declare
  pprestamoid alias for $1;
  r rliquida_renovado;
begin
	for r in --se sacan todos los prestamos que tiene marcados por pagar
		SELECT lr.prestamoid,t.revolvente,0 as capital,0 as interesnormal,0 as interesmoratorio,0 as iva,0 as cobranza, 0 as iva_cobranza,0 as total,t.tipoprestamoid  from liquidaconrenovado lr inner join prestamos p on (lr.prestamoid=p.prestamoid) inner join tipoprestamo t on (t.tipoprestamoid=p.tipoprestamoid) where lr.nuevoprestamoid=pprestamoid
	loop
		if r.revolvente=0 then --Si es un credito ordinario
			SELECT interes,moratorio,iva into r.interesnormal,r.interesmoratorio,r.iva FROM spscalculopago(r.prestamoid);
			SELECT saldoprestamo into r.capital FROM prestamos where prestamoid=r.prestamoid;
			select coalesce(cobranza,0),coalesce(ivacobranza,0) into r.cobranza, r.iva_cobranza from verificacobranza(r.prestamoid,0);
			r.total = r.interesnormal+r.interesmoratorio+r.iva+r.capital+r.cobranza+r.iva_cobranza;
			return next r;
		else --Si es una linea revolvente
			SELECT interes,moratorio,iva into r.interesnormal,r.interesmoratorio,r.iva from spscalculopago_linea(r.prestamoid,current_date);
			select spssaldoadeudolinea into r.capital from spssaldoadeudolinea(r.prestamoid);
			r.total = r.interesnormal+r.interesmoratorio+r.iva+r.capital;
			return next r;
		end if;
	end loop;
return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;