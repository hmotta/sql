CREATE OR REPLACE FUNCTION num_disposicion_linea(integer) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  
  nnum_disp integer;
begin
	
	select count(*) from (select count(po.polizaid) into nnum_disp from polizas po,movipolizas mp,prestamos p,tipoprestamo tp  where po.polizaid=mp.polizaid and mp.prestamoid=p.prestamoid and p.tipoprestamoid=tp.tipoprestamoid and mp.debe>0 and p.prestamoid=pprestamoid and (mp.cuentaid = tp.cuentaactivo or mp.cuentaid = tp.cuentaactivoren) and po.polizaid not in (select polizaid from polizas po1 natural join movipolizas mp1 where mp1.cuentaid ='6101080601' and mp1.prestamoid=pprestamoid) group by po.polizaid) as A;
	
	nnum_disp:=coalesce(nnum_disp,1);
	
	return nnum_disp+1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;