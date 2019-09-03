CREATE TYPE rptxtipomovimiento AS (
	tipomovimientoid character(2),
	serie character(2),
	referencia integer,
	numero_poliza integer,
	fecha date,
	saldoinicial numeric,
	depositos numeric,
	retiros numeric,
	interes numeric,
	saldofinal numeric
);

CREATE or replace  FUNCTION spsrptxtipomovimiento(character, date, date, character) RETURNS SETOF rptxtipomovimiento
    AS $_$
declare
  pclavesocioint alias for $1;
  pfechai alias for $2;
  pfechaf alias for $3;
  ptipomovimientoid alias for $4;

  r rptxtipomovimiento%rowtype;

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

  bprimer bool;
  stipomovimientoid char(2);
  sdopromedio numeric;
  ftasainteres numeric;
  gdiasanualesmov int4;
  idiames integer;

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

    dfecha := '1900-01-01';

    bprimer=true;


if ptipomovimientoid = 'IN' then

fsaldoinicial:=0;

for l in
    select m.tipomovimientoid,p.seriepoliza,m.referenciacaja,p.numero_poliza,
       p.fechapoliza,
       0 as saldoinicial,
       0 as depositos, 0 as retiros,
       0 as interes, 0 as saldofinal,
       m.polizaid,t.cuentapasivo,t.cuentaintinver,m.inversionid
      from movicaja m, inversion i, tipoinversion t, polizas p
     where m.socioid=lsocioid and m.tipomovimientoid = ptipomovimientoid and
           m.inversionid =  i.inversionid and
           t.tipoinversionid = i.tipoinversionid and
           p.polizaid = m.polizaid and           
           p.fechapoliza <= pfechaf
     group by m.tipomovimientoid,p.seriepoliza,m.referenciacaja,p.numero_poliza,
       p.fechapoliza, m.polizaid,t.cuentapasivo,t.cuentaintinver,m.inversionid
   order by p.fechapoliza
           
  loop

    select coalesce(sum(haber),0) into fdeposito
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentapasivo and debe=0;

    select coalesce(sum(debe),0) into fretiro
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentapasivo and haber=0;

    select coalesce(sum(debe),0) into finteresinver
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaintinver and haber=0;

      if l.fechapoliza<pfechai then
        fsaldoinicial := fsaldoinicial + fdeposito - fretiro;
        fsaldofinal := fsaldoinicial;

      else

	r.tipomovimientoid := l.tipomovimientoid;
        r.serie := l.seriepoliza;
        r.referencia := l.referenciacaja;    
	r.numero_poliza := l.numero_poliza;
        r.fecha := l.fechapoliza;

	r.saldoinicial:= fsaldoinicial;
	r.depositos := fdeposito;
	r.retiros := fretiro;
	r.interes := finteresinver;

	r.saldofinal := r.saldoinicial+r.depositos- r.retiros;

        fsaldoinicial:= fsaldoinicial+r.depositos- r.retiros;

        return next r;

      end if;

    end loop;
    
     
else

for r in 
select m.tipomovimientoid,p.seriepoliza,m.referenciacaja,p.numero_poliza,
       p.fechapoliza as fecha,
       0 as saldoinicial,
       mp.debe as depositos, mp.haber as retiros,
       0 as interes, 0 as saldofinal
  from movicaja m, movipolizas mp, polizas p
 where m.socioid=lsocioid and
       (ptipomovimientoid='  ' or m.tipomovimientoid=ptipomovimientoid) and
       mp.movipolizaid=m.movipolizaid and
       p.polizaid = m.polizaid and
       p.fechapoliza<=pfechaf      
order by m.tipomovimientoid,p.fechapoliza,mp.haber 

    loop
      if bprimer=true then
        stipomovimientoid=r.tipomovimientoid;
       
      else
        if stipomovimientoid<>r.tipomovimientoid then
          fsaldoinicial:=0;
          stipomovimientoid=r.tipomovimientoid;
          select saldopromedio into sdopromedio from saldopromedio(lsocioid,dfecha1,pfechaf,stipomovimientoid);
          select tasainteres into ftasainteres from tipomovimiento where tipomovimientoid=stipomovimientoid;
          ftasainteres:=coalesce(ftasainteres,0);
          r.interes:=(round(sdopromedio*(pfechaf-dfecha1)*ftasainteres/100/gdiasanualesmov,2));
        
        end if;
      end if;

      if r.fecha<pfechai then
        fsaldoinicial := fsaldoinicial + r.depositos - r.retiros;
        fsaldofinal := fsaldoinicial;       
      else

        if bprimer=true then
                select saldopromedio into sdopromedio from saldopromedio(lsocioid,dfecha1,pfechaf,stipomovimientoid);
                select tasainteres into ftasainteres from tipomovimiento where tipomovimientoid=stipomovimientoid;
                ftasainteres:=coalesce(ftasainteres,0);
                r.interes:=(round(sdopromedio*(pfechaf-dfecha1)*ftasainteres/100/gdiasanualesmov,2));
                bprimer=false;
        end if;
        r.saldoinicial := fsaldoinicial;
        r.saldofinal := r.saldoinicial + r.depositos - r.retiros;
        fsaldofinal:= r.saldofinal;
        fsaldoinicial := r.saldofinal;

        if r.tipomovimientoid = 'IN' then

          if r.saldofinal < 0 then
            r.retiros:=r.retiros + r.saldofinal;
            r.interes:=abs(r.saldofinal);
            r.saldofinal:=  r.saldoinicial + r.depositos - r.retiros;
            fsaldoinicial := r.saldofinal;

          end if;
        end if;
      

        return next r;
      end if;
     
      
    end loop;

    if fsaldoinicial=fsaldofinal and bprimer=true then
           r.saldoinicial := fsaldoinicial;
           r.depositos := 0;
           r.retiros := 0;
           r.saldofinal := fsaldoinicial;
           r.tipomovimientoid:=stipomovimientoid;
       
           select saldopromedio into sdopromedio from saldopromedio(lsocioid,dfecha1,pfechaf,stipomovimientoid);
           select tasainteres into ftasainteres from tipomovimiento where tipomovimientoid=stipomovimientoid;
           ftasainteres:=coalesce(ftasainteres,0);
           r.interes:=(round(sdopromedio*(pfechaf-dfecha1)*ftasainteres/100/gdiasanualesmov,2));
           return next r;
     end if;

end if;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

