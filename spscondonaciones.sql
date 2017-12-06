CREATE TYPE tcondonaciones AS (
	usuarioid character(20),
	seriepoliza character(2),
	fechapoliza date,
	socioid integer,
	clavesocioint character(15),
	nombresocio character varying(80),
	grupo character(25),
	referenciaprestamo character(18),
	fecha_otorga date,
	montoprestamo numeric,
	tipoprestamoid character(3),
	diasmora integer,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	ordendeudornormalbonificado numeric,
	ordenacredornormalbonificado numeric,
	ordeninteres numeric,
	intmoranocobact numeric,
	intmoradevnocobres numeric,
	haberes numeric,
	cobradoefectivo numeric,
	claveestadocredito character(3)
);

CREATE FUNCTION spscondonaciones(date, date, character, character) RETURNS SETOF tcondonaciones
    AS $_$
declare
  pfechai     alias for $1;
  pfechaf     alias for $2;
  psocioi     alias for $3;
  psociof     alias for $4;

  r tcondonaciones%rowtype;

  r1 record;
  fiva numeric;
  finterestotal numeric;  
  vtipomovimientoid character(2);
  saldomovimiento numeric;
begin
  select iva into fiva from empresa;

  for r in
      select '',
             p.seriepoliza,
      	     p.fechapoliza,
	     s.socioid,
	     s.clavesocioint,
	     su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
	     si.grupo,
	     pr.referenciaprestamo,
      	     pr.fecha_otorga,
      	     pr.montoprestamo,
	     pr.tipoprestamoid,
	     (case when (pfechaf-fechaultimapagada(pr.prestamoid,pfechaf))-(case when pr.dias_de_cobro > 0 then pr.dias_de_cobro else pr.meses_de_cobro*30 end) > 0 then (pfechaf-fechaultimapagada(pr.prestamoid,pfechaf))-(case when pr.dias_de_cobro > 0 then pr.dias_de_cobro else pr.meses_de_cobro*30 end) else 0 end) as diasmora,
       	     sum(case when m.cuentaid=t.cuentaactivo then m.haber else 0 end) as capital,
       	     sum(case when m.cuentaid=t.cuentaintnormal then m.haber else 0 end) as interes,
       	     sum(case when m.cuentaid=t.cuentaintmora then m.haber else 0 end) as moratorio,
     	     sum(case when m.cuentaid=t.cuentaiva then m.haber else 0 end) as iva,
	     sum(case when m.cuentaid=t.ordendeudornormalbonificado then m.haber else 0 end) as ordendeudornormalbonificado,
	     sum(case when m.cuentaid=t.ordenacredornormalbonificado then m.haber else 0 end) as ordenacredornormalbonificado,
	     sum(case when m.cuentaid=t.cuentaordeninteres then m.haber else 0 end) as ordeninteres,
	     sum(case when m.cuentaid=t.cuentaintmoranocobact then m.haber else 0 end) as intmoranocobact,
	     sum(case when m.cuentaid=t.cuentaintmoradevnocobres then m.haber else 0 end) as intmoradevnocobres,	     
	     --haberes
	     0,
	     --cobrado efectivo
	     0,
             pr.claveestadocredito
      from polizas p, movicaja mc, movipolizas m, prestamos pr, tipoprestamo t, socio s, sujeto su, solicitudingreso si
      where p.fechapoliza between pfechai and pfechaf 
      	    and mc.polizaid=p.polizaid
	    and mc.tipomovimientoid='00'
	    and m.polizaid = p.polizaid
	    and pr.prestamoid = mc.prestamoid
	    and t.tipoprestamoid = pr.tipoprestamoid
	    and s.socioid = mc.socioid
	    and s.clavesocioint>=psocioi
	    and s.clavesocioint<=psociof
	    and su.sujetoid = s.sujetoid
	    and s.socioid=si.socioid
      group by pr.usuarioid,
      	     p.fechapoliza,
	     s.clavesocioint,
	     su.nombre,
	     su.paterno,
	     su.materno,
	     si.grupo,
	     pr.referenciaprestamo,
      	     pr.fecha_otorga,
      	     pr.montoprestamo,
	     pr.tipoprestamoid,
	     pr.prestamoid,
	     pr.dias_de_cobro,
	     pr.meses_de_cobro,
	     s.socioid,
             p.seriepoliza,
             pr.claveestadocredito
      order by si.grupo,pr.tipoprestamoid,s.clavesocioint
  loop
       if r.claveestadocredito = '002' then
          r.diasmora := 0;
       end if;
      select usuarioid into r.usuarioid from usuarios natural join parametros where serie_user = r.seriepoliza;
    
    finterestotal:=r.interes+r.moratorio;

    for vtipomovimientoid in 
    select tipomovimientoid from tipomovimiento where aplicasaldo='S' loop
    	select coalesce(saldomov,0) into saldomovimiento from saldomov (r.socioid,vtipomovimientoid,pfechaf);
    	r.haberes := r.haberes + saldomovimiento;
    end loop;

    return next r;

  end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;