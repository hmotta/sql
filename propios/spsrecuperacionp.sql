
drop type rrecupera cascade;
CREATE TYPE rrecupera AS (
	suc character(4),
	referenciaprestamo character(18),
	prestamoid integer,
	clavesocioint character(15),
	fechadepago date,
	nombresocio character varying(80),
	montoprestamo numeric,
	tipoprestamoid character(3),
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	ivacalculado numeric,
	grupo character(25),
	cobrador character varying(60)
);

--
-- Name: sprecuperacion(date, date, character, character); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE OR REPLACE FUNCTION sprecuperacion(date, date, character, character) RETURNS SETOF rrecupera
    AS $_$
declare

  pfechai     alias for $1;
  pfechaf     alias for $2;
  psocioi     alias for $3;
  psociof     alias for $4;

  r rrecupera%rowtype;

  fiva numeric;
  fivacalculado numeric;
  finterestotal numeric;

begin

  select iva into fiva from empresa;

  for r in
select substr(s.clavesocioint,1,4) as suc,pr.referenciaprestamo,pr.prestamoid,
       s.clavesocioint,p.fechapoliza,
       su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
       pr.montoprestamo,
       pr.tipoprestamoid,
       sum(case when m.cuentaid=t.cuentaactivo 
                then m.haber
                else 0 end) as capital,
       sum(case when m.cuentaid=t.cuentaintnormal
                then m.haber
                else 0 end) as interes,
       sum(case when m.cuentaid=t.cuentaintmora
                then m.haber
                else 0 end) as moratorio,
       sum(case when m.cuentaid=t.cuentaiva
                then m.haber
                else 0 end) as iva,0 as ivacalculado,si.grupo
  from polizas p, movicaja mc, movipolizas m, prestamos pr,
       tipoprestamo t, socio s, sujeto su, solicitudingreso si
 where p.fechapoliza between pfechai and pfechaf and
       mc.polizaid=p.polizaid and
       mc.tipomovimientoid='00' and
       m.polizaid = p.polizaid and
       pr.prestamoid = mc.prestamoid and
       t.tipoprestamoid = pr.tipoprestamoid and
       s.socioid = mc.socioid and
       s.clavesocioint>=psocioi and s.clavesocioint<=psociof and
       su.sujetoid = s.sujetoid and 
       s.socioid=si.socioid
group by pr.referenciaprestamo,s.clavesocioint,p.fechapoliza,su.nombre,su.paterno,su.materno,pr.prestamoid,
         pr.montoprestamo,pr.tipoprestamoid,si.grupo
order by si.grupo,pr.tipoprestamoid,s.clavesocioint         
  loop
    
    finterestotal:=r.interes+r.moratorio;

    select (case when clavefinalidad ='002' then finterestotal*fiva  else 0 end) into fivacalculado from tipoprestamo where tipoprestamoid=r.tipoprestamoid;
    
    select paterno||' '||materno||' '||nombre into r.cobrador from sujeto where sujetoid = (select sujetoid from cobradores natural join carteracobrador where prestamoid=r.prestamoid group by sujetoid);

    r.ivacalculado:=fivacalculado;   

    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


