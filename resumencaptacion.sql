CREATE FUNCTION resumencaptacion(date, character) RETURNS SETOF tresumencaptacion
    AS $_$
declare

  r tresumencaptacion%rowtype;
  pfecha alias for $1;
  psucursal alias for $2;

  dfechai date;
  idiasanuales int;
  pdiafecha numeric;

begin

    select diasanualesinversion into idiasanuales
      from empresa where empresaid=1;

    -- Inicio de mes
    dfechai := pfecha - cast(extract(day from pfecha) as integer);
    raise notice 'Fecha inicio de mes %',dfechai;

---
---

    for r in

 select pfecha,psucursal,t.desctipoinversion,s.clavesocioint,
        su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
        mc.inversionid, i.fechainversion, i.fechavencimiento,
        i.tasainteresnormalinversion, t.plazo, SUM((case when mp.cuentaid=t.cuentapasivo
                 then mp.haber-mp.debe
                 else 0 end)) AS deposito,
        (case when i.fechavencimiento-pfecha>0
              then i.fechavencimiento-pfecha
              else 0 end),
        t.plazo as formapagorendimiento,
        0 as intdevmensual,
(( pfecha -
       COALESCE(MAX(case when mp.cuentaid=t.cuentaintinver
               then (case when p.fechapoliza<pfecha
                          then p.fechapoliza
                          else i.fechainversion end)
               else i.fechainversion end),i.fechainversion))*i.tasainteresnormalinversion/100/idiasanuales*SUM((case when mp.cuentaid=t.cuentapasivo
                 then mp.haber-mp.debe
                 else 0 end))) as intdevacumulado,
        0 as saldototal,
        0 as saldopromedio,COALESCE(MAX(case when mp.cuentaid=t.cuentaintinver
               then (case when p.fechapoliza<pfecha
                          then p.fechapoliza
                          else i.fechainversion end) else i.fechainversion end),i.fechainversion)
        ,mc.tipomovimientoid,tm.cuentadeposito,d.ciudadmexid,s.socioid,(select grupo from solicitudingreso where socioid=s.socioid) as grupo
   from movicaja mc, socio s, polizas p, movipolizas mp, inversion i, 
        tipoinversion t,sujeto su, domicilio d, tipomovimiento tm
  where mc.inversionid is not null and        
        s.socioid = mc.socioid and        
        p.polizaid = mc.polizaid and        
        p.fechapoliza<pfecha+1 and
        i.inversionid = mc.inversionid and
        i.fechainversion<pfecha+1 and

        t.tipoinversionid = i.tipoinversionid and
        mp.polizaid =mc.polizaid and
        su.sujetoid = s.sujetoid and
        d.sujetoid = su.sujetoid and 
        tm.tipomovimientoid = mc.tipomovimientoid

group by psucursal,t.desctipoinversion,s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno, mc.inversionid, i.fechainversion,i.fechavencimiento,i.tasainteresnormalinversion, t.plazo,i.fechapagoinversion,mc.tipomovimientoid,tm.cuentadeposito,d.ciudadmexid,s.socioid
having   SUM((case when mp.cuentaid=t.cuentapasivo
                 then mp.haber-mp.debe
                 else 0 end))>0 order by clavesocioint
    loop

      
      --
      -- Calcular devengamiento mensual
      --
      -- dfechai = primero del mes

      if r.fechainversion<=dfechai then

        if r.fechavencimiento>=pfecha then
          r.intdevmensual:=(pfecha-dfechai)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;
        else
          if r.fechavencimiento>dfechai-1 then
            r.intdevmensual:=(r.fechavencimiento-dfechai)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;
          else
            r.intdevmensual:=0;
          end if;         
        end if;

      else

        if r.fechavencimiento>=pfecha then
          r.intdevmensual:=(pfecha-r.fechainversion)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;

        else
          r.intdevmensual:=(r.fechavencimiento-r.fechainversion)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;

        end if;

      end if;

      if r.intdevmensual<0 then
        raise exception 'El interes mensual no puede ser negativo %',r.clavesocioint;
      end if;
      r.intdevmensual := round(r.intdevmensual,2);

      -- Calcular devengamiento acumulado
      -- desde el inicio de la inversion


      pdiafecha:=cast(extract(day from pfecha) as numeric);

      r.saldototal:=r.deposito+r.intdevacumulado;

     
      r.saldopromedio:=r.deposito+round((r.intdevmensual/pdiafecha)*((pdiafecha+1)/2),2);

     
      return next r;

    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;