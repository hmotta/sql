--
-- Name: spssaldosmovf(integer, date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE OR REPLACE FUNCTION spssaldosmovf(integer, date) RETURNS SETOF tsaldosmov
    AS $_$
declare
  psocioid alias for $1;
  pfecha alias for $2;
  
  r tsaldosmov%rowtype;

begin

    for r in

      select mc.tipomovimientoid, tm.desctipomovimiento, sum(mp.debe)-sum(mp.haber) as saldo
        from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p
       where mc.socioid=psocioid and
             mp.movipolizaid=mc.movipolizaid and
             tm.tipomovimientoid=mc.tipomovimientoid and
             mc.tipomovimientoid<>'00' and
             mc.tipomovimientoid<>'IN' and
             p.polizaid = mc.polizaid and
             p.fechapoliza < pfecha+1 and
             tm.aplicasaldo='S'
      group by mc.tipomovimientoid,tm.desctipomovimiento
      order by mc.tipomovimientoid
    loop
      return next r;
    end loop;

    -- Calcular el saldo para la inversion tomando movimientos de la cuenta de pasivo de
    -- la inversion 
	-- Solo inversiones excepto PS2
    for r in
       SELECT m.tipomovimientoid,tm.desctipomovimiento, -sum(debe)+sum(haber) as saldo
         from movicaja m, polizas p,tipoinversion t,movipolizas mp,inversion i,tipomovimiento tm
        where m.socioid=psocioid and m.tipomovimientoid='IN' and t.tipoinversionid<>'PS2' and t.tipoinversionid<>'PSV' and t.tipoinversionid<>'PSO' and p.polizaid=m.polizaid and
              p.fechapoliza < pfecha+1 and
              i.inversionid = m.inversionid and
              t.tipoinversionid=i.tipoinversionid and mp.polizaid=m.polizaid and
              mp.cuentaid = t.cuentapasivo and
              tm.tipomovimientoid=m.tipomovimientoid
      group by m.tipomovimientoid,tm.desctipomovimiento
    loop
        return next r;
    end loop;
	
	-- aqui solo PSO
	 for r in
       SELECT m.tipomovimientoid,tm.desctipomovimiento, -sum(debe)+sum(haber) as saldo
         from movicaja m, polizas p,tipoinversion t,movipolizas mp,inversion i,tipomovimiento tm
        where m.socioid=psocioid and m.tipomovimientoid='IN' and t.tipoinversionid='PSO' and p.polizaid=m.polizaid and
              p.fechapoliza < pfecha+1 and
              i.inversionid = m.inversionid and
              t.tipoinversionid=i.tipoinversionid and mp.polizaid=m.polizaid and
              mp.cuentaid = t.cuentapasivo and
              tm.tipomovimientoid=m.tipomovimientoid
      group by m.tipomovimientoid,tm.desctipomovimiento
    loop
			r.desctipomovimiento = 'PARTE SOCIAL ADICIONAL PSO';
        return next r;
	end loop;
		
	-- aqui solo PSV
	 for r in
       SELECT m.tipomovimientoid,tm.desctipomovimiento, -sum(debe)+sum(haber) as saldo
         from movicaja m, polizas p,tipoinversion t,movipolizas mp,inversion i,tipomovimiento tm
        where m.socioid=psocioid and m.tipomovimientoid='IN' and t.tipoinversionid='PSV' and p.polizaid=m.polizaid and
              p.fechapoliza < pfecha+1 and
              i.inversionid = m.inversionid and
              t.tipoinversionid=i.tipoinversionid and mp.polizaid=m.polizaid and
              mp.cuentaid = t.cuentapasivo and
              tm.tipomovimientoid=m.tipomovimientoid
      group by m.tipomovimientoid,tm.desctipomovimiento
    loop
			r.desctipomovimiento = 'PARTE SOCIAL ADICIONAL PSV';
        return next r;
	end loop;
	
	-- aqui solo PS2
	 for r in
       SELECT m.tipomovimientoid,tm.desctipomovimiento, -sum(debe)+sum(haber) as saldo
         from movicaja m, polizas p,tipoinversion t,movipolizas mp,inversion i,tipomovimiento tm
        where m.socioid=psocioid and m.tipomovimientoid='IN' and t.tipoinversionid='PS2' and p.polizaid=m.polizaid and
              p.fechapoliza < pfecha+1 and
              i.inversionid = m.inversionid and
              t.tipoinversionid=i.tipoinversionid and mp.polizaid=m.polizaid and
              mp.cuentaid = t.cuentapasivo and
              tm.tipomovimientoid=m.tipomovimientoid
      group by m.tipomovimientoid,tm.desctipomovimiento
    loop
			r.desctipomovimiento = 'PARTE SOCIAL ADICIONAL 360';
        return next r;
    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

