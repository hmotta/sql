CREATE or replace FUNCTION devengaahorro(date, date) RETURNS integer
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
-- pendiente terminar programcion
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
  delete from polizas where fechapoliza=pfecha2 and tipo='T';

  delete from movicaja where polizaid in (select polizaid
                                            from polizas
                                           where fechapoliza =pfecha2+1 and
                                                 tipo='W');
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

SELECT m.tipomovimientoid, 
       m.cuentadeposito, m.cuentaintpagado, m.cuentaintcobrado,
       SUM(m.interes) as interes
  FROM (SELECT M.SOCIOID, m.tipomovimientoid, 
       t.cuentadeposito, t.cuentaintpagado,t.cuentaintcobrado,
       SUM(round((case when p.fechapoliza<pfecha1 then
             mp.haber-mp.debe else 0 end)*(pfecha2-pfecha1)*t.tasainteres/100/gdiasanualesmov,2)) +
       SUM(round(case when p.fechapoliza>pfecha1-1 then
              mp.haber*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
            else 0 end,2)) -
       SUM(round(case when p.fechapoliza>pfecha1-1 then
               mp.debe*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
             else 0 end,2)) as interes
  FROM ( select ml.socioid, ml.tipomovimientoid, ml.polizaid,
                ml.referenciacaja, ml.seriecaja
           from movicaja ml
       GROUP BY ml.socioid, ml.tipomovimientoid, ml.polizaid,
                ml.referenciacaja, ml.seriecaja ) as m,
       polizas p, movipolizas mp, tipomovimiento t, socio s
 WHERE p.fechapoliza between '1900-01-01' and pfecha2 and
       mp.polizaid = p.polizaid and
       (mp.cuentaid = t.cuentadeposito or mp.cuentaid=t.cuentaretiro) and
       m.polizaid = p.polizaid and       
       t.tipomovimientoid = m.tipomovimientoid and
       t.tasainteres > 0 and 
       s.socioid = m.socioid and 
       (s.estatussocio=1  or s.estatussocio=3)
GROUP BY M.SOCIOID, m.tipomovimientoid, 
       t.cuentadeposito, t.cuentaintpagado,t.cuentaintcobrado
HAVING SUM(round((case when p.fechapoliza<pfecha1 then
             mp.haber-mp.debe else 0 end)*(pfecha2-pfecha1)*t.tasainteres/100/gdiasanualesmov,2)) +
       SUM(round(case when p.fechapoliza>pfecha1-1 then
              mp.haber*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
            else 0 end,2)) -
       SUM(round(case when p.fechapoliza>pfecha1-1 then
               mp.debe*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
             else 0 end,2))>0
order by m.socioid, m.tipomovimientoid) as m
GROUP BY m.tipomovimientoid, 
       m.cuentadeposito, m.cuentaintpagado,m.cuentaintcobrado
order by m.tipomovimientoid

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
    values(ppolizaid,r.cuentaintcobrado,' ','A',0,r.interes,'  ',' ','Int. Devengado '||r.tipomovimientoid);

insert into movipolizas(polizaid,cuentaid,referencia_mov,tipo_mov,debe,haber,diario_mov,identific_descr,descripcion)
    values(ppolizaid,r.cuentaintpagado,' ','C',r.interes,0,'  ',' ','Int. Devengado '||r.tipomovimientoid);

  end loop;

  -- Realizar las polizas por cada socio
  for r in
SELECT M.SOCIOID, m.tipomovimientoid, 
       t.cuentadeposito, t.cuentaintpagado,t.cuentaintcobrado,
       SUM(round((case when p.fechapoliza<pfecha1 then
             mp.haber-mp.debe else 0 end)*(pfecha2-pfecha1)*t.tasainteres/100/gdiasanualesmov,2)) +
       SUM(round(case when p.fechapoliza>pfecha1-1 then
              mp.haber*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
            else 0 end,2)) -
       SUM(round(case when p.fechapoliza>pfecha1-1 then
               mp.debe*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
             else 0 end,2)) as interes
  FROM ( select ml.socioid, ml.tipomovimientoid, ml.polizaid,
                ml.referenciacaja, ml.seriecaja
           from movicaja ml
       GROUP BY ml.socioid, ml.tipomovimientoid, ml.polizaid,
                ml.referenciacaja, ml.seriecaja ) as m,
       polizas p, movipolizas mp, tipomovimiento t, socio s
 WHERE p.fechapoliza between '1900-01-01' and pfecha2 and
       mp.polizaid = p.polizaid and
       (mp.cuentaid = t.cuentadeposito or mp.cuentaid=t.cuentaretiro) and
       m.polizaid = p.polizaid and       
       t.tipomovimientoid = m.tipomovimientoid and
       t.tasainteres > 0 and 
       s.socioid = m.socioid and 
       (s.estatussocio=1 or s.estatussocio=3) 
GROUP BY M.SOCIOID, m.tipomovimientoid, 
       t.cuentadeposito, t.cuentaintpagado,t.cuentaintcobrado
HAVING SUM(round((case when p.fechapoliza<pfecha1 then
             mp.haber-mp.debe else 0 end)*(pfecha2-pfecha1)*t.tasainteres/100/gdiasanualesmov,2)) +
       SUM(round(case when p.fechapoliza>pfecha1-1 then
              mp.haber*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
            else 0 end,2)) -
       SUM(round(case when p.fechapoliza>pfecha1-1 then
               mp.debe*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
             else 0 end,2))>0
order by m.socioid, m.tipomovimientoid

  loop

      raise notice 'Procesando socioid=%',r.socioid;

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
        from spimovipoliza(ppolizaid,r.cuentadeposito,' ','A',0,r.interes,' ',' ','Int. Devengado '||r.tipomovimientoid);

select *
        into pmovipolizaid
        from spimovipoliza(ppolizaid,r.cuentaintcobrado,' ','C',r.interes,0,' ',' ','Int. Devengado '||r.tipomovimientoid);


      -- Realizar el movimiento de caja

      lreferenciacaja := lreferenciacaja+1;   

insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid)
    values (r.socioid,r.tipomovimientoid,ppolizaid,lreferenciacaja,sserie_user,pmovipolizaid,NULL,'A',NULL);

  end loop;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;