CREATE OR REPLACE FUNCTION prestamosotorgados(date, date)
  RETURNS SETOF tprestamosotorgados AS $BODY$
declare
  pfecha alias for $1;
  pfecha2 alias for $2;
r tprestamosotorgados%rowtype;

begin
for r in
	select 
	substring(so.clavesocioint,1,4),
	p.referenciaprestamo,
	so.clavesocioint,
	substring(su.nombre||' '||su.paterno||' '|| su.materno,1,25) AS nombresocio,
	p.tipoprestamoid,
	p.montoprestamo,
	p.tasanormal,
	p.tasa_moratoria,
	sumaactivoprestamo(p.referenciaprestamo),
	p.fecha_otorga,
	p.fecha_vencimiento,
	p.usuarioid,
	fi.descripcionfinalidad,
	ti.desctipoprestamo 
	from prestamos p, socio so, sujeto su, cat_finalidad_contable fi, tipoprestamo ti   
	where p.claveestadocredito <> '008' and
	 p.fecha_otorga >= pfecha and
	 p.fecha_otorga <= pfecha2 and
	 p.socioid=so.socioid and 
	 so.sujetoid = su.sujetoid and
	 p.clavefinalidad=fi.clavefinalidad and
	 p.tipoprestamoid=ti.tipoprestamoid and
	 so.socioid in (select socioid from solicitudingreso)
loop
 return next r;

end loop;
return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;