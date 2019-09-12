-- ----------------------------
-- Function structure for num_disposicion_linea
-- ----------------------------
DROP FUNCTION IF EXISTS num_disposicion_linea(int4);
CREATE OR REPLACE FUNCTION num_disposicion_linea(int4)
  RETURNS pg_catalog.int4 AS $BODY$
declare
  pprestamoid alias for $1;
  
  nnum_disp integer;
  dispIni date;
begin
	
		select pz.fechapoliza into dispIni
		from prestamos p, tipoprestamo tp, movipolizas mp, polizas pz
		where p.prestamoid = pprestamoid
		and mp.prestamoid = pprestamoid
		and p.tipoprestamoid = tp.tipoprestamoid
		and mp.cuentaid in(tp.cuentaactivo, tp.cuentaactivoren)
		and mp.debe <> 0
		and pz.polizaid = mp.polizaid
		group by pz.polizaid, pz.fechapoliza, mp.cuentaid, mp.debe, mp.haber
		order by pz.fechapoliza limit 1;

		select count(*) into nnum_disp
		from movslinead(pprestamoid, dispIni, current_date, 0)
		where concepto = 'Disposicion';
	
	nnum_disp:=coalesce(nnum_disp,1);
	
	return nnum_disp+1;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;