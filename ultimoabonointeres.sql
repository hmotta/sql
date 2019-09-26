
--Regresa el ultimo abono de interes realizado por el cliente.
CREATE or replace FUNCTION ultimoabonointeres(integer,date) RETURNS  date
    AS $_$
declare
 pprestamoid alias for $1;
 pfecha_calculo alias for $2;
 dfecha date;
 dfecha_otorga date;
 scuentaintnormal character varying (24);
 
begin
	
	select cta_int_vig_resultados,fecha_otorga into scuentaintnormal,dfecha_otorga from prestamos p inner join cat_cuentas_tipoprestamo ct on (ct.cat_cuentasid = p.cat_cuentasid) where p.prestamoid=pprestamoid;
	
	select max(fechapoliza) into dfecha from polizas p inner join movipolizas mp on (p.polizaid=mp.polizaid) inner join movicaja mc on (mp.polizaid=mc.polizaid) and mc.prestamoid=pprestamoid and (cuentaid=scuentaintnormal) and p.fechapoliza<=pfecha_calculo;
	
	dfecha:=coalesce(dfecha,dfecha_otorga);
	
	return dfecha;
	
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;				