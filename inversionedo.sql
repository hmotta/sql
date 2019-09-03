drop type inversiontipo cascade;
CREATE TYPE inversiontipo AS (
	tipomovimientoid character(2),
	serie character(2),
	referencia integer,
	numero_poliza integer,
	fecha date,
	saldoinicial numeric,
	depositos numeric,
	retiros numeric,
	interes numeric,
	saldofinal numeric,
	inversionid numeric,
	isr numeric,
	desctipoinversion varchar
);

CREATE or replace  FUNCTION inversionestado(character, date, character) RETURNS SETOF inversiontipo
    AS $_$
declare
  pclavesocioint alias for $1;
  pfechaf alias for $2;
  ptipomovimientoid alias for $3;

  r inversiontipo%rowtype;

  l record;
  
  lsocioid int4;

  fsaldoinicial numeric;
  fsaldofinal   numeric;
  finteres numeric;
  fi numeric;

  fdeposito numeric;
  fretiro numeric;
  finteresinver numeric;

  ftasa numeric;
  dfecha date;
  dfecha1 date;
  pfechai date;

  bprimer bool;
  stipomovimientoid char(2);
  sdopromedio numeric;
  ftasainteres numeric;
  gdiasanualesmov int4;
  idiames integer;
  descripcion varchar;
  isr numeric;
  saldoinicial_total numeric;
  saldofinal_total numeric;
  suma_int_isr numeric;

begin

	select diasanualesmov
    into gdiasanualesmov
    from empresa;

    idiames := cast(date_part('day',pfechaf) as int);
    dfecha1 := pfechaf - idiames;

    select socioid
    into lsocioid
    from socio
    where clavesocioint=pclavesocioint;

    select tasainteres
    into ftasa
    from tipomovimiento
    where tipomovimientoid=ptipomovimientoid;

    fsaldoinicial := 0;
    fi :=0;
    finteres := 0;
	saldoinicial_total = 0;
	saldofinal_total = 0;
	suma_int_isr = 0;
	
    dfecha := '1900-01-01';
    pfechai := '1900-01-01';
    bprimer=true;


	if ptipomovimientoid = 'IN' then

		fsaldoinicial:=0;
		isr := 0;

		for l in
		select m.tipomovimientoid,p.seriepoliza,m.referenciacaja,p.numero_poliza,p.fechapoliza,0 as saldoinicial,
		0 as depositos, 0 as retiros,0 as interes, 0 as saldofinal,m.polizaid,t.cuentapasivo,t.cuentaintinver,m.inversionid
		from movicaja m, inversion i, tipoinversion t, polizas p
		where m.socioid=lsocioid and m.tipomovimientoid = ptipomovimientoid and m.inversionid =  i.inversionid and
			t.tipoinversionid = i.tipoinversionid and p.polizaid = m.polizaid and p.fechapoliza <= pfechaf
		group by m.tipomovimientoid,p.seriepoliza,m.referenciacaja,p.numero_poliza,p.fechapoliza, m.polizaid,t.cuentapasivo,t.cuentaintinver,m.inversionid
		order by m.inversionid,p.fechapoliza
				   
		loop

			select coalesce(haber,0) 
			into fdeposito
			from movipolizas
			where polizaid = l.polizaid and cuentaid = l.cuentapasivo and debe=0;
			
			select coalesce(debe,0) 
			into fretiro
			from movipolizas
			where polizaid = l.polizaid and cuentaid = l.cuentapasivo and haber=0;
			
			if l.fechapoliza<pfechai then
				fsaldoinicial := fsaldoinicial + fdeposito - fretiro;
				fsaldofinal := fsaldoinicial;
			else
				if fdeposito > 0 then
					fsaldoinicial := 0;
					fretiro := 0;
					finteresinver := 0;
					isr := 0;
				else
					fdeposito := 0;
					 
					 select sum(haber) 
					 into fsaldoinicial
					 from movipolizas mp,movicaja mc 
					 where mp.polizaid = mc.polizaid 
					 and mp.cuentaid = (select cuentapasivo from tipoinversion 
					 where tipoinversionid = (select tipoinversionid from inversion 
					 where inversionid = l.inversionid))and mc.inversionid = l.inversionid;

					 select coalesce(debe,0) 
					 into finteresinver
					 from movipolizas
					 where polizaid = l.polizaid and cuentaid = l.cuentaintinver and haber=0;

					 select desctipoinversion 
					 into descripcion
					 from inversion i,tipoinversion ti 
					 where i.tipoinversionid = ti.tipoinversionid and i.inversionid = l.inversionid;

					 select coalesce(haber,0) 
					 into isr
					 from movipolizas 
					 where polizaid = l.polizaid and  cuentaid = '2305100102';
					
					r.tipomovimientoid := l.tipomovimientoid;
					r.serie := l.seriepoliza;
					r.referencia := l.referenciacaja;    
					r.numero_poliza := l.numero_poliza;
					r.fecha := l.fechapoliza;
					
					suma_int_isr = finteresinver + coalesce(isr,0);
					
					if suma_int_isr<>0 then
						r.saldoinicial := saldoinicial_total;
						r.depositos := suma_int_isr;
						r.retiros := 0;
						r.interes := 0;
						r.saldofinal := r.saldoinicial+suma_int_isr;
						r.desctipoinversion := 'INTERES';
						saldoinicial_total := r.saldofinal;
						return next r;
					end if;
					
					if finteresinver<>0 then
						r.saldoinicial := saldoinicial_total;
						r.depositos := 0;
						r.retiros := 0;
						r.interes := finteresinver;
						r.saldofinal := r.saldoinicial-finteresinver;
						r.desctipoinversion := 'INTERES';
						saldoinicial_total := r.saldofinal;
						return next r;
					end if;
					
					if isr<>0 then
						r.saldoinicial := saldoinicial_total;
						r.interes := 0;
						r.depositos := 0;
						r.retiros := 0;
						r.isr := isr;
						r.saldofinal := r.saldoinicial-isr;
						r.desctipoinversion := 'IMPUESTO (ISR)';
						saldoinicial_total := r.saldofinal;
						return next r;
					end if;
				end if;
				
				
				fretiro = coalesce(fretiro,0);
				r.interes := 0;
				r.isr := 0;
				if fretiro <> 0 or fdeposito <> 0 then
					r.saldoinicial:= fsaldoinicial;
					r.depositos := fdeposito;
					r.retiros := fretiro;
					r.saldofinal := r.saldoinicial+r.depositos- r.retiros;
					r.inversionid := l.inversionid;
					if fdeposito <> 0 then
						r.desctipoinversion := 'DEPOSITO';
					end if;
					if fretiro <> 0 then
						r.desctipoinversion := 'RETIRO';
					end if;
					saldoinicial_total := r.saldofinal;
					return next r;
				end if;
			end if;
		end loop;
	end if;
	return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

