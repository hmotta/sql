-- ----------------------------
-- Function structure for spsprestamos
-- ----------------------------
DROP FUNCTION IF EXISTS spsprestamos(bpchar);
CREATE OR REPLACE FUNCTION spsprestamos(bpchar)
  RETURNS SETOF prestamos AS $BODY$
declare
  r prestamos%rowtype;
  preferenciaprestamo alias for $1;

  fsaldoact numeric;
  fsaldocalculado numeric;

  lprestamoid int4;

  lsolicitudprestamoid int4;
  sreferenciaprestamo character varying(18);
  o record;
begin

  select prestamoid,trim(referenciaprestamo) into lprestamoid,sreferenciaprestamo
    from prestamos where referenciaprestamo=preferenciaprestamo;

-- Recalcular el saldo en base a pagos
select p.saldoprestamo, p.montoprestamo-sum(m.haber)
  into fsaldoact,fsaldocalculado
  from movipolizas m, movicaja mc, prestamos p, cat_cuentas_tipoprestamo ct
 where p.prestamoid = lprestamoid and
--p.referenciaprestamo = preferenciaprestamo and
       (ct.tipoprestamoid = p.tipoprestamoid and ct.clavefinalidad = p.clavefinalidad and ct.renovado = p.renovado) and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       (m.cuentaid = ct.cuentaactivo)
group by p.saldoprestamo,p.montoprestamo;

  raise notice ' Saldo Actual %  Saldo Calculado %',fsaldoact,fsaldocalculado;
  if fsaldoact<>fsaldocalculado and not exists (select prestamoid from prestamos where referenciaprestamo = sreferenciaprestamo||'CAS-') then
    update prestamos
       set saldoprestamo = fsaldocalculado
     where referenciaprestamo=preferenciaprestamo;

    if fsaldocalculado=0 then
      update prestamos
         set claveestadocredito='002'
       where referenciaprestamo=preferenciaprestamo;
    end if;

  end if;


-- Verificar que haya pasado los avales
   select solicitudprestamoid
     into lsolicitudprestamoid
     from prestamos
    where referenciaprestamo=preferenciaprestamo;

   for o in
     select * from avales where solicitudprestamoid=lsolicitudprestamoid
   loop
     if o.prestamoid is null then
       update avales set prestamoid=lprestamoid where avalid=o.avalid;
     end if;
   end loop;


  if preferenciaprestamo<>'                   ' then
    for r in
      select * from prestamos where referenciaprestamo=preferenciaprestamo
    loop       
      return next r;
    end loop;
  else
   for r in
     select * from prestamos order by referenciaprestamo
    loop
      return next r;
    end loop;
  end if;

return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;