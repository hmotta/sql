drop type rcorteslinea cascade;
create type rcorteslinea as (
	num integer,
	fecha_corte date,
	fecha_limite date,
	capital numeric,
	capital_pagado numeric,
	estatus character varying(20), 
	dias int,
	fecha_pago date,
	interes_ordinario numeric,
	interes_moratorio numeric,
	iva numeric,
	pago_minimo numeric
);
CREATE or replace FUNCTION reporte_cortes_linea(integer) RETURNS SETOF rcorteslinea
    AS $_$
declare
  r rcorteslinea%rowtype;
  pprestamoid alias for $1;
  l record;
 fcargo numeric;
 fabono numeric;
 fsaldo numeric;
 fcapital_disp numeric;
 fcapital_pag numeric;
 fseguro numeric;
 fiva_seguro numeric;
 dfecha_corte date;
 fnormal numeric;
 fmoratorio numeric;
 fiva numeric;
 fpago_total numeric;
 fsaldo_inicial numeric;
 ncorteid integer;
 nnum integer;
begin
	fsaldo := 0;
	nnum := 1;
	
	
    for r in
      select 0,fecha_corte,fecha_limite,capital,capital_pagado,'',0,fecha_pago_capital,int_ordinario,int_moratorio,iva,pago_minimo
        from corte_linea
       where lineaid = pprestamoid 
	  order by fecha_corte
    loop
		r.num:=nnum;
		if (r.capital-r.capital_pagado)>0 then  --No esta pagada
			if current_date>r.fecha_limite then
				r.estatus:='VENCIDA';
				r.fecha_pago:=null;
			else
				r.estatus:='NO PAGADA';
				r.fecha_pago:=null;
			end if;
			r.dias:=current_date - r.fecha_limite;
		else
			r.estatus:='PAGADA';
			r.dias:=r.fecha_pago - r.fecha_limite;
		end if;
		return next r;
		nnum:=nnum+1;
    end loop;

	 

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;