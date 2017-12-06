CREATE TYPE rprestamosactivos AS (
	treferenciaprestamo character(18),
	tmontoprestamo numeric,
	tsaldoprestamo numeric,
	tfecha_vencimiento date,
	tasanormal numeric,
	tasamoratoria numeric,
	tfechaultimopago date
);

CREATE FUNCTION spsprestamosactivos(character, date, date) RETURNS SETOF rprestamosactivos
    AS $_$
declare
  pclavesocioint alias for $1;
  pfechai alias for $2;
  pfechaf alias for $3;

  r rprestamosactivos%rowtype;
  
  lsocioid int4;
  summonto numeric;
  sumsaldo  numeric;
begin 
  summonto := 0.00;
  sumsaldo := 0.00;
  select socioid into lsocioid from socio where clavesocioint=pclavesocioint;

  for r in
   	select p.referenciaprestamo,p.montoprestamo,
               p.montoprestamo - SUM( case when m.cuentaid=tp.cuentaactivo and po.fechapoliza<=pfechaf then m.haber else 0 end ) as tsaldo,
               p.fecha_vencimiento,p.tasanormal,p.tasa_moratoria, p.fechaultimopago 
        from prestamos p left join movicaja mc on p.prestamoid=mc.prestamoid 
	                 left join polizas po on mc.polizaid = po.polizaid
	                 left join movipolizas m on po.polizaid=m.polizaid , tipoprestamo tp
	where p.fecha_otorga <= pfechaf and
              p.claveestadocredito<>'008' and
              p.socioid = lsocioid --and
              --p.tipoprestamoid <> 'P4'
	group by p.prestamoid, p.tipoprestamoid,p.montoprestamo,
	         p.clavefinalidad,
	         p.fecha_1er_pago,p.fecha_vencimiento,p.referenciaprestamo,p.tasanormal,p.tasa_moratoria,p.fechaultimopago
 	having p.montoprestamo-SUM(case when m.cuentaid=tp.cuentaactivo and po.fechapoliza<=pfechai then m.haber else 0 end)  > 0
   loop
	summonto := summonto + r.tmontoprestamo;
        sumsaldo := sumsaldo + r.tsaldoprestamo;
        return next r;
   end loop;
   
   r.treferenciaprestamo:= null;
   r.tmontoprestamo := summonto;
   r.tsaldoprestamo := sumsaldo;
   r.tfecha_vencimiento := null;
   
   return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;