CREATE FUNCTION devengaahorro(date, date) RETURNS integer
    AS $_$
declare
  pfecha1 alias for $1;
  pfecha2 alias for $2;

  r record;

  sserie_user char(2);

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  lreferenciacaja int4;

  scuentacaja char(24);
  lmovicajaid int4;

  iperiodo1 int4;
  iano1 int4;
  iperiodo2 int4;
  iano2 int4;

  finteres numeric;

  gdiasanualesmov int4;
begin

  select diasanualesmov
    into gdiasanualesmov
    from empresa
   where empresaid=1;
  
  pnumero_poliza := 0;
  preferencia := 0;

  finteres := 0;

-- Por el momento nadamas tomo el 1er caso donde no hay devengamientos anteriores
-- pendiente terminar programción


  sserie_user := 'ZA';

  select cuentacaja
    into scuentacaja
    from parametros
   where serie_user = sserie_user;

  delete from movicaja where polizaid in (select polizaid
                                            from polizas
                                           where fechapoliza =pfecha2 and
                                                 tipo='T');
  delete from movipolizas where polizaid in
   (select polizaid from polizas where fechapoliza=pfecha2 and tipo='T');

  delete from logpoliza where polizaid in (select polizaid from polizas where fechapoliza=pfecha2 and tipo='T');

  delete from polizas where fechapoliza=pfecha2 and tipo='T';

  delete from movicaja where polizaid in (select polizaid
                                            from polizas
                                           where fechapoliza =pfecha2+1 and tipo='W');

  delete from logpoliza where polizaid in (select polizaid from polizas where fechapoliza=pfecha2+1 and tipo='W');

  delete from movipolizas where polizaid in
   (select polizaid from polizas where fechapoliza=pfecha2+1 and tipo='W');


  delete from polizas where fechapoliza=pfecha2 and tipo='W';
 
      select coalesce(max(referenciacaja),0)
        into lreferenciacaja
        from movicaja
       where seriecaja = sserie_user;

  iperiodo1 := cast(date_part('month',pfecha2) as int);
  iano1 := cast(date_part('year',pfecha2) as int);
  iperiodo2 := cast(date_part('month',pfecha2+1) as int);
  iano2 := cast(date_part('year',pfecha2+1) as int);


  -- Poliza Global del Interes Devengado

  for r in
select m1.tipomovimientoid,t.cuentadeposito, t.cuentaintpagado, t.cuentaintcobrado,
       t.cuentaisr,sum(m1.interes) as interes,sum(m1.isr) as isr
FROM (SELECT m0.socioid,m0.tipomovimientoid,
       SUM(round(m0.sdopromedio*(pfecha2-pfecha1)*t0.tasainteres/100/gdiasanualesmov,2)) as interes,
        0 as isr

  FROM (SELECT s.SOCIOID,t.tipomovimientoid,
          saldopromedio(s.SOCIOID,pfecha1,pfecha2,t.tipomovimientoid) as sdopromedio
          FROM socio s,tipomovimiento t
         WHERE t.tasainteres>0) m0,tipomovimiento t0
  WHERE t0.tipomovimientoid=m0.tipomovimientoid         
GROUP BY m0.socioid,m0.tipomovimientoid) as m1, tipomovimiento t
 WHERE t.tipomovimientoid = m1.tipomovimientoid
GROUP BY m1.tipomovimientoid,t.cuentadeposito, t.cuentaintpagado, t.cuentaintcobrado,t.cuentaisr

  loop

      --
      -- Dar de alta la poliza contable T
      --

      -- Encabezado de la poliza
      select * 
        into ppolizaid
        from spipolizasfecha(preferencia,sserie_user,'T',pnumero_poliza,
                             iano1,
                             iperiodo1,
                             ' ',pfecha2,'D',' ',' ',
                             'Interes a Movimiento '||r.tipomovimientoid,pfecha2);


insert into movipolizas(polizaid,cuentaid,referencia_mov,tipo_mov,debe,haber,diario_mov,identific_descr,descripcion)
    values(ppolizaid,r.cuentaintcobrado,' ','A',0,r.interes-r.isr,'  ',' ','Int. Devengado '||r.tipomovimientoid);

insert into movipolizas(polizaid,cuentaid,referencia_mov,tipo_mov,debe,haber,diario_mov,identific_descr,descripcion)
    values(ppolizaid,r.cuentaisr,' ','A',0,r.isr,'  ',' ','Int. Devengado '||r.tipomovimientoid);

insert into movipolizas(polizaid,cuentaid,referencia_mov,tipo_mov,debe,haber,diario_mov,identific_descr,descripcion)
    values(ppolizaid,r.cuentaintpagado,' ','C',r.interes,0,'  ',' ','Int. Devengado '||r.tipomovimientoid);

  end loop;

  -- Realizar las polizas por cada socio
  for r in

SELECT m0.socioid,m0.tipomovimientoid,t.cuentadeposito, t.cuentaintpagado, t.cuentaintcobrado, t.cuentaisr,
       SUM(round(m0.sdopromedio*(pfecha2-pfecha1)*t.tasainteres/100/gdiasanualesmov,2)) as interes, 0 as isr

  FROM (SELECT s.SOCIOID,t.tipomovimientoid,
          saldopromedio(s.SOCIOID,pfecha1,pfecha2,t.tipomovimientoid) as sdopromedio
          FROM socio s,tipomovimiento t
         WHERE t.tasainteres>0) m0,tipomovimiento t
  WHERE t.tipomovimientoid=m0.tipomovimientoid         
GROUP BY m0.socioid,m0.tipomovimientoid,t.cuentadeposito, t.cuentaintpagado, t.cuentaintcobrado, t.cuentaisr

  loop

    raise notice 'Procesando socioid=%',r.socioid;
    if r.interes>0 then
      --
      -- Dar de alta la poliza contable W
      --

      -- Encabezado de la poliza
      select * 
        into ppolizaid
        from spipolizasfecha(preferencia,sserie_user,'W',pnumero_poliza,
                             iano2,
                             iperiodo2,
                             ' ',pfecha2+1,'D',' ',' ',
                             'Interes a Movimiento '||r.tipomovimientoid,pfecha2+1);

      select *
        into pmovipolizaid
        from spimovipoliza(ppolizaid,r.cuentadeposito,' ','A',0,r.interes-r.isr,' ',' ','Int. Devengado '||r.tipomovimientoid);

      select *
        into pmovipolizaid
        from spimovipoliza(ppolizaid,r.cuentaintcobrado,' ','C',r.interes-r.isr,0,' ',' ','Int. Devengado '||r.tipomovimientoid);

      -- Realizar el movimiento de caja

      lreferenciacaja := lreferenciacaja+1;   

      insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid)
      values (r.socioid,r.tipomovimientoid,ppolizaid,lreferenciacaja,sserie_user,pmovipolizaid,NULL,'A',NULL);

    end if;
  end loop;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;