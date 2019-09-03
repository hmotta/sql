--
-- Name: sumadepositos(character, date, integer); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE FUNCTION sumadepositosold(character, date, integer) RETURNS numeric
    AS $_$
declare
  ptipomovimientoid alias for $1;
  pfecha alias for $2;
  psocioid alias for $3;
 
  periodo integer;
  ejercicio integer;

  fdeposito numeric;
 
begin


  ejercicio:=cast(date_part('year',pfecha) as int);

  periodo:=cast(date_part('month',pfecha) as int);

     select sum(mp.debe) into fdeposito
        from movicaja mc, movipolizas mp, polizas p
       where mc.socioid=psocioid and mc.efectivo=1 and
             ( mc.tipomovimientoid in (select tipomovimientoid from tipomovimiento where tipomovimientoid<>'CI' and tipomovimientoid<>'IP'  and tipomovimientoid<>'RE' and aplicasaldo='S')) and
             p.polizaid = mc.polizaid and
             mp.movipolizaid=mc.movipolizaid and
             p.ejercicio=ejercicio and p.periodo=periodo ;

    fdeposito:=coalesce(fdeposito,0);

   
return fdeposito;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

