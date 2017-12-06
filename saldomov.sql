CREATE OR REPLACE FUNCTION saldomov(integer, character, date) RETURNS numeric
    AS $_$
declare
  psocioid alias for $1;
  ptipomovimientoid alias for $2;
  pfecha alias for $3;

  fsaldo numeric;
  ftotalprestamo numeric;
  ftotalprestamos numeric;
  fmontoprestamo numeric;
  fmontoprestamos numeric;
  ssucid character(4);
  r record;

begin

  fsaldo:=0;
  if ptipomovimientoid<>'00' and ptipomovimientoid<>'IN' and
     ptipomovimientoid<>'PA' then

      select sum(mp.haber)-sum(mp.debe) into fsaldo
        from (SELECT movicaja.socioid, movicaja.tipomovimientoid, movicaja.polizaid,
                     movicaja.referenciacaja, movicaja.seriecaja
                FROM movicaja
               WHERE movicaja.socioid=psocioid and
                     movicaja.tipomovimientoid=ptipomovimientoid
            GROUP BY movicaja.socioid, movicaja.tipomovimientoid, movicaja.polizaid,
                     movicaja.referenciacaja, movicaja.seriecaja) mc,
             movipolizas mp, tipomovimiento tm, polizas p
       where mc.socioid=psocioid and
             mc.tipomovimientoid=ptipomovimientoid and
             tm.tipomovimientoid=ptipomovimientoid and
             mp.polizaid = mc.polizaid and
             (mp.cuentaid=tm.cuentadeposito or mp.cuentaid=tm.cuentaretiro) and
             p.polizaid = mp.polizaid and
             p.fechapoliza<=pfecha;
  end if;

  if ptipomovimientoid='IN' then

    select SUM((case when mp.cuentaid=t.cuentapasivo
                then mp.haber-mp.debe
                else 0 end)) into fsaldo
      from polizas p, movicaja m, movipolizas mp, inversion i, tipoinversion t
     where i.socioid=psocioid and
           i.fechainversion<=pfecha and
           m.inversionid = i.inversionid and
           p.polizaid = m.polizaid and
           p.fechapoliza <= pfecha and
           t.tipoinversionid = i.tipoinversionid and
           mp.polizaid = p.polizaid --and
           --t.tipoinversionid <> 'K3'          
    having SUM((case when mp.cuentaid=t.cuentapasivo
                then mp.haber-mp.debe
                else 0 end))>0 ;

  end if;

  if ptipomovimientoid='00' then

    fmontoprestamos:=0;
    fmontoprestamo:=0;

    for r in
      select * from prestamos where socioid=psocioid
    loop

      select p.montoprestamo-sum(m.haber)
        into fmontoprestamo
        from prestamos p, tipoprestamo tp, movicaja mc, movipolizas m
       where p.prestamoid=r.prestamoid and
             tp.tipoprestamoid = p.tipoprestamoid and
             mc.prestamoid = p.prestamoid and
             m.polizaid = mc.polizaid and
             m.cuentaid = tp.cuentaactivo
    group by p.montoprestamo;

      if not found then
        fmontoprestamos:=fmontoprestamos+r.montoprestamo;
      else
        fmontoprestamos:=fmontoprestamos+coalesce(fmontoprestamo,0);
      end if;
    end loop;

    fsaldo := fmontoprestamos;

  end if;


  if ptipomovimientoid='PA' then
		fsaldo:=0;
      select coalesce(sum(mp.debe)-sum(mp.haber),0) as saldo
        into fsaldo
        from movicaja mc, movipolizas mp, tipomovimiento tm
       where mc.socioid=psocioid and
             mp.movipolizaid=mc.movipolizaid and
             mc.tipomovimientoid='PA' and
             tm.tipomovimientoid=mc.tipomovimientoid and
             tm.aplicasaldo='S';
	   
	   select sucid into ssucid from empresa where sucid='008-';
	   
	   if found then
			raise notice 'Estoy en la sucursal 8...';
			if psocioid=1533 then --Socio que se ocupa para oportunidades de sucursal tlacotepec
				fsaldo=1000.00;
			end if;
	   end if;

  end if;

return fsaldo;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;