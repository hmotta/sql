CREATE or replace FUNCTION dias_mora_linea(integer) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  ndias_mora integer;
  dfecha_adeudo date;
  begin
	select fecha_limite into dfecha_adeudo from corte_linea where lineaid=pprestamoid and (capital-capital_pagado)>0 order by fecha_corte limit 1;
	dfecha_adeudo:=coalesce(dfecha_adeudo,current_date);
	ndias_mora:=current_date - dfecha_adeudo;
	if ndias_mora<0 then
		ndias_mora:=0;
	end if;
  return ndias_mora;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;