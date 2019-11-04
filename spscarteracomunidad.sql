CREATE OR REPLACE FUNCTION spscarteracomunidad(date)
  RETURNS pg_catalog.int4 AS $BODY$
declare  

  pfechac alias for $1;
  r record; 
  rsaldoprest numeric;
  rcapital             numeric;
  rcantidadpagada      numeric;
  rinteres             numeric;
  rmoratorio           numeric;
  riva                 numeric;
  rvencidas            numeric;
  rfechaultimopago     date;
  rdiasatraso          integer;
  rcaval1              char(15);
  rnombreaval1         varchar(80);
  rdireccionaval1      varchar(130);
  rcaval2              char(15);
  rnombreaval2         varchar(80);
  rdireccionaval2      varchar(130);
  rcaval3              char(15);
  rnombreaval3         varchar(80);
  rdireccionaval3      varchar(130);
  rcaval4              char(15);
  rnombreaval4         varchar(80);
  rdireccionaval4      varchar(130);

begin

  delete from carteracomunidadfecha where fechadegeneracion=pfechac;

  insert into carteracomunidadfecha (fechadegeneracion,prestamoid,clavesocioint,grupo,referenciaprestamo, tipoprestamo, nombre, direccion,colonia, telefono, comunidad, rfc, curp, sexo, totalingresos, ocupacion, finalidaddefault,finalidadcredito, fecha_otorga, fecha_vencimiento, fecha_ultimopago, fecha_nacimiento, mesesavencer, montoprestamo, saldoprest, cantidadpagada, diasatraso, amortizacion,promotorid)

  select pfechac,p.prestamoid,s.clavesocioint, si.grupo,p.referenciaprestamo,p.tipoprestamoid,su.nombre||' '||su.paterno||' '||su.materno,substr(d.calle||' '||d.numero_ext,1,80),d.colonia,d.teldomicilio , d.comunidad, su.rfc, su.curp, (case when si.sexo=0 then 'MA' else 'FE' end) , 0 as totalingresos, si.ocupacion, fi.descripcionfinalidad, fi.descripcionfinalidad, p.fecha_otorga, p.fecha_vencimiento, p.fechaultimopago,su.fecha_nacimiento,(p.fecha_vencimiento-pfechac)/30,p.montoprestamo, p.saldoprestamo,0 as cantidadpagada, 0 AS diasatrasoprestamo, 0 as amortizacionprestamo,s.promotorid 
from prestamos p, socio s, sujeto su, domicilio d, solicitudingreso si, cat_finalidad_contable fi
where p.saldoprestamo > 0 and p.claveestadocredito <> '008' and tipoprestamoid<>'CAS' and
         p.fecha_otorga<=pfechac and
	 p.socioid = s.socioid and
         s.socioid = si.socioid and
         s.sujetoid = su.sujetoid and
         su.sujetoid= d.sujetoid and        
         p.clavefinalidad=fi.clavefinalidad order by p.prestamoid;

   for r in select c.prestamoid,c.montoprestamo,t.revolvente from carteracomunidadfecha c inner join tipoprestamo t on (c.tipoprestamo=t.tipoprestamoid) where c.fechadegeneracion=pfechac

   loop 
		if r.revolvente=0 then
			select vencidas,fechaultimopago,diasint from spscalculopagocartera(r.prestamoid,pfechac) into rvencidas,rfechaultimopago,rdiasatraso;
			select vencidas,interes,moratorio,iva from spscalculopago(r.prestamoid) into rcapital,rinteres,rmoratorio,riva;
			rcantidadpagada:=r.montoprestamo-rsaldoprest;
		else
			--select vencidas,fechaultimopago,diasint from spscalculopagocartera(r.prestamoid,pfechac) into rvencidas,rfechaultimopago,rdiasatraso;
			--select vencidas,interes,moratorio,iva from spscalculopago(r.prestamoid) into rcapital,rinteres,rmoratorio,riva;
			rcantidadpagada:=r.montoprestamo-rsaldoprest;
		end if;

      select (select clavesocioint from socio where sujetoid=su.sujetoid),su.nombre||' '||su.paterno||' '||su.materno as nombreaval,substring(rtrim(d.calle)||' '||rtrim(d.numero_ext)||' '||rtrim(d.comunidad)||' Tel: '||rtrim(d.teldomicilio),1,130) as direccionaval  into rcaval1,rnombreaval1,rdireccionaval1 from  sujeto su, avales av, domicilio d where av.prestamoid=r.prestamoid and noaval=1 and  av.sujetoid=su.sujetoid and su.sujetoid=d.sujetoid;

      select (select clavesocioint from socio where sujetoid=su.sujetoid),su.nombre||' '||su.paterno||' '||su.materno as nombreaval,substring(rtrim(d.calle)||' '||rtrim(d.numero_ext)||' '||rtrim(d.comunidad)||' Tel: '||rtrim(d.teldomicilio),1,130) as direccionaval  into rcaval2,rnombreaval2,rdireccionaval2 from  sujeto su, avales av,domicilio d where av.prestamoid=r.prestamoid and noaval=2 and  av.sujetoid=su.sujetoid and su.sujetoid=d.sujetoid;

      select (select clavesocioint from socio where sujetoid=su.sujetoid),su.nombre||' '||su.paterno||' '||su.materno as nombreaval,substring(rtrim(d.calle)||' '||rtrim(d.numero_ext)||' '||rtrim(d.comunidad)||' Tel: '||rtrim(d.teldomicilio),1,130) as direccionaval  into rcaval3,rnombreaval3,rdireccionaval3 from  sujeto su, avales av,domicilio d where av.prestamoid=r.prestamoid and noaval=3 and  av.sujetoid=su.sujetoid and su.sujetoid=d.sujetoid;

      select (select clavesocioint from socio where sujetoid=su.sujetoid),su.nombre||' '||su.paterno||' '||su.materno as nombreaval,substring(rtrim(d.calle)||' '||rtrim(d.numero_ext)||' '||rtrim(d.comunidad)||' Tel: '||rtrim(d.teldomicilio),1,130) as direccionaval  into rcaval4,rnombreaval4,rdireccionaval4 from  sujeto su, avales av,domicilio d where av.prestamoid=r.prestamoid and noaval=4 and av.sujetoid=su.sujetoid and su.sujetoid=d.sujetoid;

      update carteracomunidadfecha set saldoprest=rsaldoprest,capital=rcapital,interes=rinteres,moratorio=rmoratorio,iva=riva,vencidas=rvencidas,fecha_ultimopago=rfechaultimopago,diasatraso=rdiasatraso,caval1=rcaval1,caval2=rcaval2,caval3=rcaval3,caval4=rcaval4,nombreaval1=rnombreaval1,nombreaval2=rnombreaval2,nombreaval3=rnombreaval3,nombreaval4=rnombreaval4,direccionaval1=rdireccionaval1,direccionaval2=rdireccionaval2,direccionaval3=rdireccionaval3,direccionaval4=rdireccionaval4 where prestamoid=r.prestamoid and fechadegeneracion=pfechac;

      raise notice ' Procesando % ',r.prestamoid;

    end loop;

return 1;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;