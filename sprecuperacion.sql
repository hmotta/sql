-- ----------------------------
-- Function structure for sprecuperacion
-- ----------------------------
DROP FUNCTION IF EXISTS sprecuperacion(date, date);
CREATE OR REPLACE FUNCTION sprecuperacion(date, date)
  RETURNS SETOF rrecupera AS $BODY$
declare

  pfechai     alias for $1;
  pfechaf     alias for $2;


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
       sum(case when m.cuentaid=ct.cuentaactivo
                then m.haber
                else 0 end) as capital,
       sum(case when m.cuentaid=ct.cuentaintnormal
                then m.haber
                else 0 end) as interes,
       sum(case when m.cuentaid=ct.cuentaintmora
                then m.haber
                else 0 end) as moratorio,
       sum(case when m.cuentaid=ct.cuentaiva
                then m.haber
                else 0 end) as iva,0 as ivacalculado,si.grupo
  from polizas p, movicaja mc, movipolizas m, prestamos pr,
       cat_cuentas_tipoprestamo ct, socio s, sujeto su, solicitudingreso si
 where p.fechapoliza between pfechai and pfechaf and
       mc.polizaid=p.polizaid and
       mc.tipomovimientoid='00' and
       m.polizaid = p.polizaid and
       pr.prestamoid = mc.prestamoid and
       (ct.tipoprestamoid = pr.tipoprestamoid and ct.clavefinalidad = pr.clavefinalidad and ct.renovado = pr.renovado) and
       s.socioid = mc.socioid and
       s.clavesocioint>=(select min(clavesocioint) from socio) and s.clavesocioint<=(select max(clavesocioint) from socio) and
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
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;