CREATE OR REPLACE FUNCTION cancelapoliza(int4, bpchar)
  RETURNS pg_catalog.int4 AS $BODY$
declare
  ppolizaid alias for $1;
  plogin alias for $2;

  pmovicajaid int4;
  ptipomovimientoid char(2);
  pfechamov date;

  lprestamoid int4;
  fcapital numeric;
  pfechaant date;
  pfecha_otorga date;
  fAbono numeric;
  fAplicar numeric;
  amor record;

  linversionid int4;
  fdeposito numeric;
  fretiroi  numeric;
  fretiroc  numeric;
  scuentapasivo   char(24);
  scuentaintinver char(24);

  pejercicio int4;
  pperiodo int4;


begin

  select ejercicio,periodo
    into pejercicio,pperiodo
    from polizas
   where polizaid = ppolizaid;

   if periodovalido(pejercicio,pperiodo)=0 then
     raise exception 'El periodo % del Ejercicio % se encuentra CERRADO !!!',pperiodo,pejercicio;
   end if;


  select movicajaid,tipomovimientoid,prestamoid,inversionid
    into pmovicajaid,ptipomovimientoid,lprestamoid,linversionid
    from movicaja
   where polizaid=ppolizaid;
 
  if FOUND and ptipomovimientoid<>'00' and ptipomovimientoid<>'IN' then

    --
    -- Movimientos normales en caja
    --
    update polizas
       set concepto_poliza = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
       where polizaid=ppolizaid;

    update movipolizas
       set debe=0,
           haber=0,
           descripcion=substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
     where polizaid=ppolizaid;

    update movicaja
       set estatusmovicaja='C'
     where movicajaid=pmovicajaid;

  end if;

  if FOUND and ptipomovimientoid='00' or ptipomovimientoid='IN' then

    select fechapoliza
      into pfechamov
      from polizas
     where polizaid = ppolizaid;

    if ptipomovimientoid='00' then
      --
      -- Movimientos de prestamo
      --

      --
      -- Buscar el abono de capital para el prestamo
      --
      select sum(m.haber)
        into fcapital
        from prestamos p, cat_cuentas_tipoprestamo ct, movipolizas m
       where p.prestamoid = lprestamoid and
             ct.cat_cuentasid = p.cat_cuentasid and
             m.polizaid = ppolizaid and
             m.cuentaid = tp.cta_cap_vig;

      fcapital := coalesce(fcapital,0);

      --
      -- Buscar la fecha de abono anterior
      --
      select max(p.fechapoliza)
        into pfechaant
        from movicaja m, polizas p
       where m.prestamoid = lprestamoid and
             p.polizaid = m.polizaid and
             p.fechapoliza < pfechamov;

      select fecha_otorga
        into pfecha_otorga
        from prestamos
       where prestamoid = lprestamoid;

      pfechaant := coalesce(pfechaant,pfecha_otorga);

      update prestamos
         set saldoprestamo = saldoprestamo + fcapital,
             fechaultimopago = pfechaant,
             claveestadocredito = '001'
       where prestamoid=lprestamoid;

      if fcapital>0 then
        --
        -- Regresar Amortizaciones a su estatus anterior
        --

        fAbono := fcapital;

        for amor in
            select *
              from amortizaciones
             where prestamoid=lprestamoid
          order by fechadepago desc
        loop
        
          fAplicar := amor.abonopagado;
          if fAplicar>0 then
            if fAbono>=fAplicar then
              update amortizaciones
                 set abonopagado = abonopagado - fAplicar,
                     ultimoabono = pfechaant
               where amortizacionid=amor.amortizacionid;
               fAbono := fAbono - fAplicar;
            else
              if fAbono>0 then
                update amortizaciones
                   set abonopagado = abonopagado-fAbono,
                       ultimoabono = pfechaant
                 where amortizacionid=amor.amortizacionid;
                 fAbono := 0;
              end if;
            end if;
          end if;
        end loop;

      end if;

      update polizas
         set concepto_poliza = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
       where polizaid=ppolizaid;

      update movipolizas
         set debe = 0,
             haber = 0,
             descripcion = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
       where polizaid=ppolizaid;

      update movicaja
         set estatusmovicaja='C'
       where movicajaid=pmovicajaid;

    else
      --
      -- Movimientos de inversion
      --

      select t.cuentapasivo, t.cuentaintinver
        into scuentapasivo, scuentaintinver
        from inversion i, tipoinversion t
       where i.inversionid = linversionid and
             t.tipoinversionid = i.tipoinversionid;

      --
      -- Verificar si es retiro o deposito
      --
      select sum(m.debe), sum(m.haber)
        into fretiroc, fdeposito
        from movipolizas m
       where m.polizaid = ppolizaid and
             m.cuentaid = scuentapasivo;

      fretiroc   := coalesce(fretiroc,0);
      fdeposito  := coalesce(fdeposito,0);

      if fdeposito>0 or fretiroc>0 then
        if fdeposito>0 then
          update inversion
             set depositoinversion=depositoinversion-fdeposito
           where inversionid=linversionid;

        else
          update inversion
             set retiroinversion=retiroinversion-fretiroc,
                 fechapagoinversion=fechapagoanterior
           where inversionid=linversionid;
        end if;


        update polizas
           set concepto_poliza = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
         where polizaid=ppolizaid;

        update movipolizas
           set debe = 0,
               haber = 0,
               descripcion = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
         where polizaid=ppolizaid;

        update movicaja
           set estatusmovicaja='C'
         where movicajaid=pmovicajaid;

      else
        -- Se trata de un retiro de interes
        select sum(m.debe)
          into fretiroi
          from movipolizas m
         where m.polizaid = ppolizaid and
               m.cuentaid = scuentaintinver;

        fretiroi := coalesce(fretiroi,0);

        if fretiroi>0 then



          update inversion
             set fechapagoinversion=fechapagoanterior
           where inversionid=linversionid;

          update polizas
             set concepto_poliza = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
           where polizaid=ppolizaid;

          update movipolizas
             set debe = 0,
                 haber = 0,
                 descripcion = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
           where polizaid=ppolizaid;

          update movicaja
             set estatusmovicaja='C'
           where movicajaid=pmovicajaid;

        end if;

      end if;
  
    end if;

  end if;

  if NOT FOUND then
    --
    -- Otro clase de polizas Polizas de banco y polizas comunes
    -- pendiente bancos

    update polizas
       set concepto_poliza = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
     where polizaid=ppolizaid;

    update movipolizas
       set debe = 0,
           haber = 0,
           descripcion = substr('CANCELADO '||CURRENT_DATE||' '||plogin,1,29)
     where polizaid=ppolizaid;

  end if;

return 1;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;