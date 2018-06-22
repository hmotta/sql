CREATE or replace FUNCTION spscalculoliquidar_linea(integer) RETURNS SETOF tcalculopago
    AS $_$
declare
  pprestamoid alias for $1;
  
  r tcalculopago%rowtype;
  
  xinteres_pagar numeric;
  xmoratorio_pagar numeric;
  xiva numeric;
  xsaldo_linea numeric;
  

begin	
    xiva:=0;
    xinteres_pagar:=0;
    xmoratorio_pagar:=0;
	xsaldo_linea:=0;
	
	select spssaldoadeudolinea into xsaldo_linea from spssaldoadeudolinea(pprestamoid);
	
	select sum(interes_diario) into xinteres_pagar from calcula_int_ord_linea(pprestamoid,current_date);
	xiva:=xiva+round(xinteres_pagar*0.16,2);
	
	select calcula_int_mor_linea into xmoratorio_pagar from calcula_int_mor_linea(pprestamoid,current_date);
	xiva:= xiva+round(xmoratorio_pagar*0.16,2);
		
	r.prestamoid   := pprestamoid;
	r.amortizacion := 0;
	r.capital      := round(xsaldo_linea,2);
	r.interes      := round(xinteres_pagar,2);
	r.moratorio    := round(xmoratorio_pagar,2);
	r.iva          := round(xiva,2);
	r.total        := round(xsaldo_linea,2)+round(xinteres_pagar,2)+round(xmoratorio_pagar,2)+round(xiva,2);
	return next r;
		
	return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
