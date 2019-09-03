Drop type restadocta cascade;
CREATE TYPE restadocta AS (
	fecha date,
	serie character(2),
	nopoliza integer,
	referenciacaja integer,
	monto_prestamo numeric,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	total numeric,
	saldoinicial numeric,
	saldofinal numeric,
	saldocobranza numeric
);

CREATE OR REPLACE FUNCTION edocuenta(character, date) RETURNS SETOF restadocta
    AS $_$
declare
  preferenciaprestamo alias for $1;
  pfechacorte         alias for $2;

  r restadocta%rowtype;

  fimporte    numeric;
  fcapital    numeric;
  finteres    numeric;
  fmoratorio  numeric;
  fiva        numeric;
  ftotal      numeric;

  l record;

  pprestamoid int4;

  dfechapoliza date;
  sseriepoliza char(2);
  lnumero_poliza int4;
  lreferenciamovi int4;
  fmontoprestamo numeric;

  dfecha_otorga date;
  fsaldoinicial numeric;
  fcobranzas numeric;
  fcuentacobranzas numeric;
  fpolizaid numeric;
begin
  raise notice 'Edo cta';
  
  select prestamoid,montoprestamo into pprestamoid,fsaldoinicial
   from prestamos where referenciaprestamo=preferenciaprestamo;

  fimporte    :=0;
  fcapital    :=0;
  finteres    :=0;
  fmoratorio  :=0;
  fiva        :=0;
  ftotal      :=0;


  select p.fechapoliza,p.seriepoliza,p.numero_poliza,
         0,mp.haber 
    into dfechapoliza, sseriepoliza, lnumero_poliza,
         lreferenciamovi, fmontoprestamo
    from movibanco m,polizas p, movipolizas mp
   where m.prestamoid=pprestamoid and
         p.polizaid=m.polizaid and
         mp.movipolizaid=m.movipolizaid;
  if FOUND then
    --r.fecha := dfechapoliza;
    --r.serie := sseriepoliza;
    --r.nopoliza := lnumero_poliza;
    --r.referenciacaja := lreferenciamovi;
    --r.monto_prestamo := fmontoprestamo;
    --return next r;
  else

    select p.fechapoliza,p.seriepoliza,p.numero_poliza,
           m.referenciacaja,mp.haber
      into dfechapoliza, sseriepoliza, lnumero_poliza,
           lreferenciamovi, fmontoprestamo
      from movicaja m,polizas p, movipolizas mp
     where m.prestamoid=pprestamoid and
           p.polizaid=m.polizaid and
           mp.movipolizaid=m.movipolizaid and
           mp.haber>0;

    if FOUND then
      --r.fecha := dfechapoliza;
      --r.serie := sseriepoliza;
      --r.nopoliza := lnumero_poliza;
      --r.referenciacaja := lreferenciamovi;
      --r.monto_prestamo := fmontoprestamo;
      --return next r;
    else
      -- Regresar el monto por que no se encontro el movimiento
      -- ni en bancos ni en movicaja
      select montoprestamo,fecha_otorga
        into fmontoprestamo,dfecha_otorga
        from prestamos
       where referenciaprestamo=preferenciaprestamo;             

      --r.fecha := dfecha_otorga;
      --r.serie := 'Z';
      --r.nopoliza := 0;
      --r.referenciacaja := 0;
      --r.monto_prestamo := fmontoprestamo;
      --return next r;

    end if;


  end if;

  for l in
    select p.fechapoliza,p.seriepoliza,p.numero_poliza,
           m.referenciacaja,
           m.polizaid,t.cuentaactivo,t.cuentaintnormal,t.cuentaintmora,t.cuentaiva
      from movicaja m, prestamos pr, tipoprestamo t, polizas p
     where m.prestamoid = pprestamoid and
           pr.prestamoid =  m.prestamoid and
           t.tipoprestamoid = pr.tipoprestamoid and
           p.polizaid = m.polizaid and
           p.fechapoliza < pfechacorte+1
   order by p.fechapoliza
           
  loop

    select coalesce(sum(haber-debe),0) into fcapital
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaactivo and debe=0;
    select coalesce(sum(haber-debe),0) into finteres
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaintnormal;
    select coalesce(sum(haber-debe),0) into fmoratorio
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaintmora;
    select coalesce(sum(haber-debe),0) into fiva
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaiva;

	select polizaid
    into fpolizaid
    from movicaja
    where referenciacaja=l.referenciacaja and seriecaja=l.seriepoliza and tipomovimientoid='0A';
	
	select cuentadeposito 
    into fcuentacobranzas
    from tipomovimiento 
    where tipomovimientoid='0A';
	
	select coalesce(sum(debe)-sum(haber),0)*-1 
	into fcobranzas
	from movipolizas 
	where cuentaid = fcuentacobranzas and polizaid=fpolizaid;
	
    if fcapital+finteres+fmoratorio+fiva <> 0 then 
       r.fecha := l.fechapoliza;
       r.serie := l.seriepoliza;
       r.nopoliza := l.numero_poliza;
       r.referenciacaja := l.referenciacaja;
       r.capital := coalesce(fcapital,0);
       r.interes := coalesce(finteres,0);
       r.moratorio := coalesce(fmoratorio,0);
       r.iva := coalesce(fiva,0)+(fcobranzas*0.16);
       r.total := r.capital + r.interes + r.moratorio + r.iva;
       r.saldoinicial := fsaldoinicial;
       r.saldofinal := fsaldoinicial-r.capital;
       fsaldoinicial:= fsaldoinicial-r.capital;
	   r.saldocobranza := fcobranzas;
	   r.monto_prestamo := r.saldocobranza+ r.iva+ r.capital + r.interes+ r.moratorio ;
       return next r;

    end if;
    
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.edocuenta(character, date) OWNER TO sistema;

CREATE OR REPLACE FUNCTION edocuenta(character, character, date) RETURNS SETOF restadocta
    AS $_$
declare
  pclavesocioint      alias for $1;
  preferenciaprestamo alias for $2;
  pfechacorte         alias for $3;

  r restadocta%rowtype;

  fimporte    numeric;
  fcapital    numeric;
  finteres    numeric;
  fmoratorio  numeric;
  fiva        numeric;
  ftotal      numeric;

  l record;

  pprestamoid int4;

  dfechapoliza date;
  sseriepoliza char(2);
  lnumero_poliza int4;
  lreferenciamovi int4;
  fmontoprestamo numeric;

  dfecha_otorga date;
begin

  select prestamoid into pprestamoid
   from prestamos where referenciaprestamo=preferenciaprestamo;

  fimporte    :=0;
  fcapital    :=0;
  finteres    :=0;
  fmoratorio  :=0;
  fiva        :=0;
  ftotal      :=0;

raise notice 'Prestamoid = %',pprestamoid;

  select p.fechapoliza,p.seriepoliza,p.numero_poliza,
         cast(substr(referenciamovi,4) as int4),mp.haber
    into dfechapoliza, sseriepoliza, lnumero_poliza,
         lreferenciamovi, fmontoprestamo
    from movibanco m,polizas p, movipolizas mp, tipoprestamo t, prestamos pr
   where pr.prestamoid=pprestamoid and
         m.prestamoid=pprestamoid and
         p.polizaid=m.polizaid and
         mp.polizaid=p.polizaid and
         t.tipoprestamoid=pr.tipoprestamoid and
         mp.cuentaid = t.cuentaactivo and
         mp.haber>0;

  if FOUND then
    r.fecha := dfechapoliza;
    r.serie := sseriepoliza;
    r.nopoliza := lnumero_poliza;
    r.referenciacaja := lreferenciamovi;
    r.monto_prestamo := fmontoprestamo;
    return next r;
  else

    select p.fechapoliza,p.seriepoliza,p.numero_poliza,
           m.referenciacaja,mp.haber
      into dfechapoliza, sseriepoliza, lnumero_poliza,
           lreferenciamovi, fmontoprestamo
      from movicaja m,polizas p, movipolizas mp
     where m.prestamoid=pprestamoid and
           p.polizaid=m.polizaid and
           mp.movipolizaid=m.movipolizaid and
           mp.haber>0;

    if FOUND then
      r.fecha := dfechapoliza;
      r.serie := sseriepoliza;
      r.nopoliza := lnumero_poliza;
      r.referenciacaja := lreferenciamovi;
      r.monto_prestamo := fmontoprestamo;
      return next r;
    else
      -- Regresar el monto por que no se encontro el movimiento
      -- ni en bancos ni en movicaja
      select montoprestamo,fecha_otorga
        into fmontoprestamo,dfecha_otorga
        from prestamos
       where referenciaprestamo=preferenciaprestamo;             

      r.fecha := dfecha_otorga;
      r.serie := 'Z';
      r.nopoliza := 0;
      r.referenciacaja := 0;
      r.monto_prestamo := fmontoprestamo;
      return next r;

    end if;


  end if;



  for l in
    select p.fechapoliza,p.seriepoliza,p.numero_poliza,
           m.referenciacaja,
           m.polizaid,t.cuentaactivo,t.cuentaintnormal,t.cuentaintmora,t.cuentaiva
      from movicaja m, prestamos pr, tipoprestamo t, polizas p
     where m.prestamoid = pprestamoid and
           pr.prestamoid =  m.prestamoid and
           t.tipoprestamoid = pr.tipoprestamoid and
           p.polizaid = m.polizaid and
           p.fechapoliza < pfechacorte+1
    order by p.fechapoliza
           
  loop

    select sum(coalesce(haber-debe,0)) into fcapital
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaactivo and debe=0;
    select sum(coalesce(haber-debe,0)) into finteres
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaintnormal;
    select sum(coalesce(haber-debe,0)) into fmoratorio
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaintmora;
    select sum(coalesce(haber-debe,0)) into fiva
      from movipolizas
     where polizaid = l.polizaid and
           cuentaid = l.cuentaiva;

    r.fecha := l.fechapoliza;
    r.serie := l.seriepoliza;
    r.nopoliza := l.numero_poliza;
    r.referenciacaja := l.referenciacaja;
    r.monto_prestamo := 0;
    r.capital := coalesce(fcapital,0);
    r.interes := coalesce(finteres,0);
    r.moratorio := coalesce(fmoratorio,0);
    r.iva := coalesce(fiva,0);
    r.total := r.capital + r.interes + r.moratorio + r.iva;

    return next r;
    
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;