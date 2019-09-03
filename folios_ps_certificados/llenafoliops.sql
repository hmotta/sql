CREATE OR REPLACE FUNCTION llenafoliops() RETURNS integer
    AS $$
declare
  r record;
  --psocioid alias for $1;
  nsaldo numeric;
  ipartes real;
  ifolioini integer;
  ifoliofin integer;
begin

    for r in
      select 	s.ultpolizaid,
				s.socioid,
				mc.movicajaid,
				p.ejercicio,
				p.periodo,
				s.saldo,
				p.fechapoliza 
	  from 		polizas p,
				movicaja mc,
				(select mc.socioid,sum(mp.debe)-sum(mp.haber) as saldo,max(mc.polizaid) as ultpolizaid from movicaja mc, movipolizas mp, tipomovimiento tm where  mp.movipolizaid=mc.movipolizaid and mc.tipomovimientoid='P3' and tm.tipomovimientoid=mc.tipomovimientoid and tm.aplicasaldo='S' group by mc.socioid) as s 
	  where 	p.polizaid=s.ultpolizaid and 
				mc.polizaid=p.polizaid and 
				mc.tipomovimientoid='P3' and 
				s.socioid=mc.socioid and 
				s.saldo> 0 order by p.polizaid
    loop
		r.ejercicio:=2012;
		r.periodo:=4;
		select saldomov into nsaldo from saldomov(r.socioid,'P3',current_date);
		if nsaldo<>r.saldo then 
			raise exception 'Error en saldo socioid=%',r.socioid;
		end if;
		ipartes = r.saldo/500;
		select coalesce(max(foliofin)+1,1) into ifolioini from foliops where ejercicio=r.ejercicio;
		
		ifoliofin:=ifolioini+ipartes-1;
		raise notice 'socioid = %, saldo=%, movicajaid = %,tipomovimientoid = P3,folioini = %,foliofin = % ',r.socioid,r.saldo,r.movicajaid,ifolioini,ifoliofin;
		
		insert into foliops(socioid,movicajaid,tipomovimientoid,ejercicio,periodo,folioini,foliofin,vigente) values(r.socioid,r.movicajaid,'P3',r.ejercicio,r.periodo,ifolioini,ifoliofin,'S');
      --return next r;
    end loop;
return 1;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;