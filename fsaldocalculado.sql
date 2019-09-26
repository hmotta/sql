CREATE OR REPLACE FUNCTION fsaldocalculado(int4)
  RETURNS pg_catalog.numeric AS $BODY$
declare
  pprestamoid alias for $1;
  fsaldo numeric;
begin


select p.montoprestamo-sum(m.haber)
  into fsaldo
  from prestamos p, cat_cuentas_tipoprestamo ct, movicaja mc, movipolizas m
 where p.prestamoid = pprestamoid and
       ct.cat_cuentasid = p.cat_cuentasid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.cuentaid = ct.cta_cap_vig
group by p.saldoprestamo,p.montoprestamo
having p.saldoprestamo<>p.montoprestamo-sum(m.haber);

  fsaldo := coalesce(fsaldo,0);

return fsaldo;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;