CREATE OR REPLACE FUNCTION finalidaddefault(bpchar)
  RETURNS pg_catalog.bpchar AS $BODY$
declare

  ptipoprestamoid alias for $1;
  pdesctipoprestamo char(30);

begin

  select f.descripcionfinalidad into pdesctipoprestamo from tipoprestamo tp, cat_finalidad_contable f where tp.clavefinalidad=f.clavefinalidad and tp.tipoprestamoid=ptipoprestamoid;

  pdesctipoprestamo := coalesce(pdesctipoprestamo,'CONSUMO');

return pdesctipoprestamo;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100