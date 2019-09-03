--Modificado Para Cooperativa Yolomecatl el dia 05/10/2011 by Hmota

--alter table estadosmex add abre_estado char(3);
--alter table precorte add importeultimaamort numeric;
--alter table precorte add importevencidoamort numeric;

drop TYPE rformato cascade;
CREATE TYPE rformato AS (
	sujetoid integer,
	prestamoid integer,
	paterno character varying(26),
	materno character varying(26),
	nombre character varying(100),
	fecha_nac date,
	rfc character varying(15),
	nacionalidad character varying (2),
	edo_civil integer,
	sexo integer,
	calle character varying(90),
	numero character varying(40),
	colonia character varying(60),
	municipio character varying(40),
	estado character varying(4),
	cp character (5),
   	suc character varying(3),
	referenciaprestamo character(18),
	responsabilidad character,
	numero_de_amor integer,
    meses_de_cobro integer,
	dias_de_cobro integer,
	fecha_otorga date,
	importevencidoamort numeric,
	importeultimaamort numeric,
	interesdevengadomenoravencido numeric,
	interesdevengadomayoravencido numeric,
	interesdevmormenor numeric,
	interesdevmormayor numeric,
	saldoprestamo numeric,
	ultimoabono date,
	montoprestamo numeric,
	diasvencidos integer,
	noamorvencidas integer,
	clave character (2),
	cuentaanterior character varying(15),
	fecha_primer_incum date,
	monto_ultimo_pago numeric,
	fecha_ult_pago_vencido date,
	revolvente integer,
	pago_minimo numeric,
	fecha_ultima_disp date,
	credito_maximo numeric,
	claveestadocredito character (3)
);



CREATE or replace FUNCTION reporteburo(date) RETURNS SETOF rformato
    AS $_$
declare

  pfecha alias for $1;
  r rformato%rowtype;
  l record;
  m record;
  pposicion integer;
  pnombre character varying(40);
  saldocastigado numeric;
  dultimoadeudo date;
  i int;
begin

  --Poner la clave de reestructuras en automatico
  --for l in
	--select prestamoid from prestamos where referenciaprestamo in (select referenciaprestamoorigen from prestamos where referenciaprestamo ilike '%-S%') and saldoprestamo=0
  --loop
	--delete from carteraclaveburo where prestamoid=l.prestamoid;
	--insert into carteraclaveburo (prestamoid,clave) values (l.prestamoid,'RV');
  --end loop;
  
  i:=1;
  for r in
       select
	   su.sujetoid,
	   p.prestamoid,
       su.paterno,
       su.materno,
       su.nombre,
	   su.fecha_nacimiento,
       su.rfc,
	   (case when (select nacionalidad from generalesconceatucliente where socioid=s.socioid)=1 then 'MX' else 'MX' end) as nacionalidad,
       so.estadocivilid,
       so.sexo,
       d.calle,
	   d.numero_ext,
	   col.nombrecolonia,
       c.nombreciudadmex,
       e.abre_estado,
       col.cp,
       (select substring(sucid,1,3) from empresa where empresaid=1),
	   p.referenciaprestamo,
	   'I',
       p.numero_de_amor,
       p.meses_de_cobro,
	   p.dias_de_cobro,
	   p.fecha_otorga,
       round(importevencidoamort,2),
	   round(importeultimaamort,2),
	   interesdevengadomenoravencido,
	   interesdevengadomayoravencido,
	   interesdevmormenor,
	   interesdevmormayor,
	   pr.saldoprestamo,
       pr.ultimoabono,
       p.montoprestamo,
       pr.diasvencidos,
       pr.noamorvencidas,
       (select clave from carteraclaveburo where prestamoid=pr.prestamoid),
	   (select cuentaanterior from cuentaanterior where prestamoid=pr.prestamoid),
	   pr.primerincumplimiento as fecha_primer_incum,
	   (select coalesce(sum(debe),0) from movicaja mc,movipolizas mp where mp.movipolizaid = mc.movipolizaid and mc.tipomovimientoid='00' and mc.prestamoid=p.prestamoid group by mc.fechahora order by mc.fechahora desc limit 1 ) as monto_ultimo_pago,
	   NULL as fecha_ult_pago_vencido,
	   tp.revolvente,
	   (case when tp.revolvente=1 then (select (capital+capital_vencido+int_ordinario+int_moratorio) from corte_linea where lineaid=p.prestamoid and fecha_corte<=pfecha order by fecha_corte desc limit 1) else 0 end ) as pago_minimo,
	   (select max(p1.fechapoliza) from polizas p1 natural join movipolizas mp1 inner join prestamos pr1 on (mp1.prestamoid=pr1.prestamoid) inner join tipoprestamo tp1 on (pr1.tipoprestamoid=tp1.tipoprestamoid) where mp1.prestamoid=p.prestamoid and (mp1.cuentaid = tp1.cuentaactivo or mp1.cuentaid=tp1.cuentaactivoren) and p1.fechapoliza<=pfecha and mp1.debe>0),
	   (case when tp.revolvente=1 then (select max(debe) from movslinead(p.prestamoid,p.fecha_otorga,current_date,1) where tipomov=1 ) else p.montoprestamo end ),
	   claveestadocredito
       from precorte pr, prestamos p, tipoprestamo tp, socio s, solicitudingreso so, sujeto su, domicilio d, colonia col, ciudadesmex c, estadosmex e
       where pr.fechacierre = pfecha and  s.tiposocioid = '02' and so.personajuridicaid = 0 and 			 
             p.prestamoid = pr.prestamoid and 
			 tp.tipoprestamoid = p.tipoprestamoid and 
			 p.tipoprestamoid <> 'CAS' and
             s.socioid = p.socioid and
             su.sujetoid=s.sujetoid and
             so.socioid=s.socioid and
             d.sujetoid=su.sujetoid and
             col.coloniaid=d.coloniaid and
             c.ciudadmexid=d.ciudadmexid and
             e.estadomexid=c.estadomexid 
  loop
    --r.clave:=i;
    --i:=i+1;
	--raise notice 'procesando prestamoid: %',r.prestamoid;
	if r.fecha_otorga >= '2011-05-25' then
		if r.revolvente=1 then
			
		else
			if NOT exists(select * from clasificacioncartera natural join amortizaciones where prestamoid=r.prestamoid) then
				select fechapago into r.fecha_primer_incum from calculadiasmora(r.prestamoid) where diasmora>0 and fechapago<=pfecha order by fechapago limit 1;
			else
				select fechadepago into r.fecha_primer_incum from clasificacioncartera natural join amortizaciones where diasmora>0 and prestamoid=r.prestamoid and fechadepago<=pfecha order by fechadepago limit 1;
			end if;
		end if;
	end if;

	select fechacierre into r.fecha_ult_pago_vencido from precorte where prestamoid=r.prestamoid and diasvencidos>diastraspasoavencida order by fechacierre limit 1  ;
	
	return next r;
	--Se agrega informacion de Avales
	for l in
		select 
			su.sujetoid,
			su.paterno,
			su.materno,
			su.nombre,
			su.fecha_nacimiento,
			su.rfc,
			d.calle,
			d.numero_ext,
			col.nombrecolonia,
			c.nombreciudadmex,
			e.abre_estado,
			col.cp
		from avales a,sujeto su,domicilio d, colonia col, ciudadesmex c, estadosmex e
		where su.sujetoid=a.sujetoid and 
			su.sujetoid=d.sujetoid and
             col.coloniaid=d.coloniaid and
             c.ciudadmexid=d.ciudadmexid and
             e.estadomexid=c.estadomexid and
			a.prestamoid = (r.prestamoid)
	  loop
		r.sujetoid=l.sujetoid;
		r.paterno=l.paterno;
		r.materno=l.materno;
		r.nombre=l.nombre;
		r.fecha_nac:=l.fecha_nacimiento;
		r.rfc:=l.rfc;
		r.calle:=l.calle;
		r.numero:=l.numero_ext;
		r.colonia:=l.nombrecolonia;
		r.municipio:=l.nombreciudadmex;
		r.estado:=l.abre_estado;
		r.cp:=l.cp;
		r.edo_civil:=-1;
		r.sexo:=-1;
		r.responsabilidad:='C';
		return next r;
	  end loop;
	
  end loop;

	

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


