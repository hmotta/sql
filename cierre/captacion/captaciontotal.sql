CREATE FUNCTION captaciontotal(date) RETURNS SETOF tresumencaptacion
    AS $_$
declare
  r tresumencaptacion%rowtype;
  pfecha alias for $1;
  psucursal char(4);

  dfechai date;
  idiasanuales int;
  isocioid  int4;

begin

    select diasanualesinversion,sucid into idiasanuales,psucursal
      from empresa where empresaid=1;

    -- Inicio de mes
    dfechai := pfecha - cast(extract(day from pfecha)-1 as integer);
    raise notice 'Fecha inicio de mes %',dfechai;

    for r in
      select * from resumencaptacion(pfecha,psucursal)
    loop
      return next r;
    end loop;

    for r in
      select pfecha,psucursal,t.desctipomovimiento,s.clavesocioint,
             su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
             0 as inversionid, pfecha as fechainversion,
             pfecha+1 as fechavencimiento, t.tasainteres, 1 as plazo,
             sum(mp.debe)-sum(mp.haber) as deposito, 1 as diasvencimiento,
             1 as formapagorendimiento,(case when mc.tipomovimientoid<>'IN' and t.aplicasaldo='S' then intdevengadomensual(s.clavesocioint,pfecha,mc.tipomovimientoid) else 0 end) as  intdevmensual,
        0 as intdevacumulado,
        0 as saldototal,
        0 as saldopromedio,
        pfecha as fechapagoinversion,mc.tipomovimientoid,tm.cuentadeposito,d.ciudadmexid,s.socioid,(select grupo from solicitudingreso where socioid=s.socioid) as grupo
        from movicaja mc, movipolizas mp, polizas p, socio s,
             tipomovimiento t, sujeto su, domicilio d, tipomovimiento tm
       where mc.tipomovimientoid in (select tipomovimientoid from tipomovimiento where tipomovimientoid<>'IN' and aplicasaldo='S') and
             p.polizaid = mc.polizaid and             
             p.fechapoliza<=pfecha and
             mp.movipolizaid=mc.movipolizaid and     
             s.socioid = mc.socioid and
             t.tipomovimientoid = mc.tipomovimientoid and
             su.sujetoid = s.sujetoid and 
             d.sujetoid = su.sujetoid and 
             tm.tipomovimientoid = mc.tipomovimientoid
      group by t.desctipomovimiento,s.clavesocioint,su.nombre,
               su.paterno,su.materno,t.tasainteres,mc.tipomovimientoid,t.aplicasaldo,tm.cuentadeposito,d.ciudadmexid,s.socioid
      having sum(mp.debe)-sum(mp.haber)<>0 or (case when mc.tipomovimientoid<>'IN' and t.aplicasaldo='S' then intdevengadomensual(s.clavesocioint,pfecha,mc.tipomovimientoid) else 0 end) <> 0
    loop
      if r.tipomovimientoid in (select tipomovimientoid from tipomovimiento where tipomovimientoid<>'IN' and aplicasaldo='S') then
         r.saldototal:=r.deposito+r.intdevacumulado;
         select socioid into isocioid from socio where clavesocioint=r.clavesocioint;
         r.saldopromedio := saldopromedio(isocioid,dfechai,pfecha,r.tipomovimientoid);

      end if;
      return next r;
    end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;