CREATE OR REPLACE FUNCTION sumaactivoprestamo(bpchar)
  RETURNS pg_catalog.numeric AS $BODY$
declare
  preferenciaprestamo alias for $1;
 
  r record;
  ptotaldebe numeric;
  ptotaldebe2 numeric;
  pcuentaactivo char(24);


begin

  for r in 
  select prestamoid,referenciaprestamo,tipoprestamoid from prestamos where referenciaprestamo=preferenciaprestamo

  loop
 
      select cta_cap_vig into pcuentaactivo from cat_cuentas_tipoprestamo ct inner join prestamos p on (ct.cat_cuentasid=p.cat_cuentasid) where p.prestamoid=r.prestamoid;

      select sum(debe) into ptotaldebe from movipolizas where cuentaid=pcuentaactivo and polizaid in (select mc.polizaid from movicaja mc, polizas po where mc.polizaid=po.polizaid and mc.prestamoid=r.prestamoid);
      ptotaldebe:= coalesce(ptotaldebe,0);


      select sum(debe) into ptotaldebe2 from movipolizas where cuentaid=pcuentaactivo and polizaid in (select mc.polizaid from movibanco mc, polizas po where mc.polizaid=po.polizaid and mc.prestamoid=r.prestamoid );
      ptotaldebe2:= coalesce(ptotaldebe2,0);

     
  end loop;
   

return ptotaldebe+ptotaldebe2;

end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;