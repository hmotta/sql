CREATE FUNCTION spsprestamos(character) RETURNS SETOF prestamos
    AS $_$
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
  from movipolizas m, movicaja mc, prestamos p, tipoprestamo tp
 where p.prestamoid = lprestamoid and
--p.referenciaprestamo = preferenciaprestamo and
       tp.tipoprestamoid = p.tipoprestamoid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.cuentaid = tp.cuentaactivo
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
$_$
    LANGUAGE plpgsql SECURITY DEFINER;