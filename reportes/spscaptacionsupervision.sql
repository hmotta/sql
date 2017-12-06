--
drop TYPE tcaptacionsupervision cascade;
CREATE TYPE tcaptacionsupervision AS (
	numero_de_socio character varying(18),
	numero_de_socio_tutor character varying(18),
	nombre_de_socio character varying(80),
	nombre_de_tutor character varying(80),
	tipo_persona character varying(6), 
	fecha_ingreso character(10),
	fecha_nacimiento character(10),
	tipo_de_producto character varying(30),
	clasificacion_contable character(12),
	fecha_de_apertura character(10),
	fecha_de_vencimiento character varying(10),
	plazo_rendimiento_dias integer,
	plazo_deposito_dias integer,
	tasa_de_interes_pactada_anual numeric,
	monto_del_ahorro_o_deposito numeric,
	interes_devengados numeric,
	sucursal character varying(16)
);
CREATE or replace FUNCTION spscaptacionsupervision(date) RETURNS SETOF tcaptacionsupervision
    AS $_$
declare
  pfechacierre alias for $1;
  r tcaptacionsupervision%rowtype;
begin

	for r in
		select
		--01-numero_de_socio
			Rtrim(clavesocioint),
		--02-numero_de_socio_tutor
			(case when (select tiposocioid from socio where socioid=captaciontotal.socioid)='01' then (select Rtrim(clavesocioint) from socio where socioid=(select socioid from relacion where esrepresentante=1 and solicitudingresoid=(select solicitudingresoid from solicitudingreso where socioid=captaciontotal.socioid) limit 1)) else '' end),
		--03-nombre_de_socio 
			Rtrim(nombresocio), 
		--04-nombre_de_tutor 	
			(case when (select tiposocioid from socio where socioid=captaciontotal.socioid)='01' then (select nombre||' '||paterno||' '||materno as tutor from sujeto where sujetoid=(select sujetoid from relacion where esrepresentante=1 and solicitudingresoid=(select solicitudingresoid from solicitudingreso where socioid=captaciontotal.socioid) limit 1)) else '' end),
		--05-tipo_persona 	
			(case when (select tiposocioid from socio where socioid=captaciontotal.socioid)='05' then 'MORAL' else 'FISICA' end),
		--06-fecha_ingreso 	
			(select rtrim(fechaalta) from socio where socioid=captaciontotal.socioid),
		--07-fecha_nacimiento 	
			(select fecha_nacimiento from socio s, sujeto su  where su.sujetoid=s.sujetoid and s.socioid=captaciontotal.socioid),
		--08-tipo_de_producto 	
			rtrim(desctipoinversion),
		--09-clasificacion_contable 
			(case when captaciontotal.tipomovimientoid='IN' then '211190000000' else '210101000000' end),
		--10-fecha_de_apertura 	
			(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PB','PR','TA','AI','PR','AM') then (select min(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else (case when tipomovimientoid in ('IN') then fechainversion else (select fechaingreso from solicitudingreso where socioid=captaciontotal.socioid ) end ) end),
		--11-fecha_de_vencimiento 	
			(case when tipomovimientoid in ('IN') then to_char(fechavencimiento,'DD/MM/YYYY') else '' end),
		--12-plazo_rendimiento_dias 	
			(case when tipomovimientoid in ('IN') then (case when (select i.noderenovaciones from inversion i where i.socioid=captaciontotal.socioid and i.inversionid=captaciontotal.inversionid)=3 then '30' else  formapagorendimiento end) else formapagorendimiento end),
		--13-plazo_deposito_dias 	
			plazo,
		--14-tasa_de_interes_pactada_anual 	
			tasainteresnormalinversion,
		--15-monto_del_ahorro_o_deposito 
			deposito,
		--16-interes_devengados
			(case when tipomovimientoid in ('IN') then round(intdevacumulado,2) else round(intdevmensual,2) end), 	
		--17-sucursal 	
			(select Rtrim(nombresucursal) from empresa where empresaid=1)
			
			from captaciontotal 
			where fechadegeneracion=pfechacierre 
			and tipomovimientoid not in ('IP','ID','PA','P3','PP') and
			desctipoinversion not in ('PARTE SOCIAL ADICIONAL OBLIGAT','PARTE SOCIAL ADICIONAL VOLUNTA')
			order by clavesocioint, tipomovimientoid

	loop 
  
		return next r;

	end loop;
	return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


