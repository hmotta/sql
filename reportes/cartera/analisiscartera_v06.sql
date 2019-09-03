--
-- Name: tanalisiscartera; Type: TYPE; Schema: public; Owner: sistema
--
drop TYPE tanalisiscartera cascade;
CREATE TYPE tanalisiscartera AS (
	prestamoid integer,
	clavesocioint character(15),
	nombre character varying(120),
	referenciaprestamo character(18),
	fecha_otorgamiento date,
	montoprestamo numeric,
	dias_mora integer,
	categoria_mora_precierre character(10),
	saldo_prestamo_precierre numeric,
	fecha_precierre date,
	categoria_mora_actual character(10),
	saldo_prestamo_actual numeric,
	fecha_actual date,
	sucursal character(4),
	tipoprestamo character(32),
	dias_mora_precierre integer,
	cobrador character varying(80),
	cobradorid integer,
	frecuencia integer,
	grupo text
);

CREATE or replace FUNCTION analisiscartera(date) RETURNS SETOF tanalisiscartera 
AS $_$
declare
	pfechacierre alias for $1;
	frecuencia integer;
	dfecha_1er_pago date;
	idias_de_cobro integer;
	imeses_de_cobro integer;
	r tanalisiscartera%rowtype;
	fechaprecorte  date;
	fechacierre1  date;
	ssucid character varying(4);
	dfechaultimapagada date;
	ndiasinteres integer;
	nrevolvente integer;
begin
	fechaprecorte:=pfechacierre-cast(date_part('day',pfechacierre) as int);
	raise notice ' Fecha Inicial:  %  ',fechaprecorte;
	select fechacierre into fechacierre1 from precorte where fechacierre<=pfechacierre order by fechacierre DESC LIMIT 1;
	select sucid into ssucid from empresa where empresaid=1;
	raise notice ' Fecha cierre:  %  ',fechacierre1;
	if fechacierre1=pfechacierre then
		raise notice ' la fecha que ingreso es de cierre:  %  ',fechacierre1;
		for r in
			select
				p.prestamoid,
				s.clavesocioint,
				substring(su.nombre||' '||su.paterno||' '||su.materno,1,119) as nombre,
				p.referenciaprestamo,
				p.fecha_otorga,
				p.montoprestamo,
				0 as diasmora,
				--Categoria_mora
				'' as cat_mora,
				--saldo_prestamo,
				0 as saldo_prestamo,
				fechaprecorte as fecha_precorte,
				--Categoria_mora2
				'' as categoria_mora2,
				--saldo_prestamo2
				---p.montoprestamo-sum(m.haber) as saldo_prestamo2,
				0 as saldo_prestamo2,
				pfechacierre as fecha_cierre,
				--Sucursal char(4)
				'' as sucursal,
				tp.desctipoprestamo,
				--dias_mora_precierre
				0
			from prestamos p, tipoprestamo tp, socio s, sujeto su
			where p.fecha_otorga <= pfechacierre and p.claveestadocredito<>'008' and
				tp.tipoprestamoid = p.tipoprestamoid
				and p.socioid=s.socioid and s.sujetoid = su.sujetoid
				and p.tipoprestamoid<>'CAS'
				and p.saldoprestamo>0
				and p.prestamoid not in (select prestamoid from prestamos where referenciaprestamo in (select substr(referenciaprestamo,1,7) from prestamos where tipoprestamoid='CAS'))
				group by p.prestamoid, p.tipoprestamoid,p.montoprestamo,p.fecha_otorga,p.dias_de_cobro,p.meses_de_cobro,
				p.clavefinalidad,p.fecha_vencimiento,p.referenciaprestamo,p.tasanormal,p.tasa_moratoria,p.socioid,s.clavesocioint,su.sujetoid,su.nombre,su.paterno,su.materno,tp.desctipoprestamo,p.saldoprestamo,tp.revolvente
				order by s.clavesocioint
		loop
			r.sucursal:=ssucid;
			select revolvente into nrevolvente from tipoprestamo inner join prestamos on (tipoprestamo.tipoprestamoid=prestamos.tipoprestamoid);
			
			select fechaultimapagada into dfechaultimapagada from fechaultimapagada(r.prestamoid,pfechacierre);
			---dias mora cierre actual-----
			select saldoprestamo,diasvencidos into r.saldo_prestamo_actual,r.dias_mora from precorte where prestamoid=r.prestamoid and fechacierre=fechacierre1;
			select saldoprestamo,diasvencidos into r.saldo_prestamo_precierre,r.dias_mora_precierre from precorte where prestamoid=r.prestamoid and fechacierre=fechaprecorte;
			select fecha_1er_pago,dias_de_cobro,meses_de_cobro into dfecha_1er_pago,idias_de_cobro,imeses_de_cobro from prestamos where prestamoid=r.prestamoid;
			if nrevolvente=1 then
				frecuencia:=30;
			else
				frecuencia:=(case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			end if;
			--raise notice ' nombre:  %  ',r.nombre;
			--raise notice 'dias mora cierre:  %  ',r.dias_mora_precierre;
			--raise notice 'frecuencia:  %  ',frecuencia;
			if (nrevolvente=1 and r.dias_mora_precierre>=60) or (nrevolvente=0 and ((r.dias_mora_precierre>=21 and frecuencia=7) or (r.dias_mora_precierre>=42 and frecuencia=14) or  (r.dias_mora_precierre>=45 and frecuencia=15) or (r.dias_mora_precierre>=90)))then
				r.categoria_mora_precierre:='D.VENCIDA';
			end if;
			if (nrevolvente=1 and r.dias_mora_precierre<60) or (nrevolvente=0 and ((r.dias_mora_precierre<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora_precierre<21 and frecuencia=7) or (r.dias_mora_precierre<45 and frecuencia=15) or (r.dias_mora_precierre<42 and frecuencia=14)))then
				r.categoria_mora_precierre:='C.MOROSA';
			end if;
			if r.dias_mora_precierre=0 then
				r.categoria_mora_precierre:='B.VIGENTE';
			end if;

			if r.fecha_otorgamiento>fechaprecorte  then
				r.categoria_mora_precierre:='A.NUEVA';
			end if;
			-------categoria cartera cierre
			if (nrevolvente=1 and r.dias_mora>=60) or (nrevolvente=0 and ((r.dias_mora>=21 and frecuencia=7) or (r.dias_mora>=45 and frecuencia=15)or (r.dias_mora>=42 and frecuencia=14) or (r.dias_mora>=90))) then
				r.categoria_mora_actual:='D.VENCIDA';
			end if;
			if (nrevolvente=1 and r.dias_mora<60) or (nrevolvente=0 and ((r.dias_mora<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora<21 and frecuencia=7) or (r.dias_mora<45 and frecuencia=15) or(r.dias_mora<42 and frecuencia=14))) then
				r.categoria_mora_actual:='C.MOROSA';
			end if;
			if r.dias_mora=0 then
				r.categoria_mora_actual:='B.VIGENTE';
			end if;
			if r.categoria_mora_precierre='A.NUEVA' then
				r.categoria_mora_actual:='A.NUEVA';
			end if;
			select paterno||' '||materno||' '||nombre into r.cobrador from sujeto where sujetoid = (select sujetoid from cobradores natural join carteracobrador where prestamoid=r.prestamoid group by sujetoid);
			select cobradorid into r.cobradorid from carteracobrador where prestamoid=r.prestamoid;
			if nrevolvente=0 then
				r.frecuencia:=30;
			else
				r.frecuencia:=(case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			end if;
			select sl.grupo into r.grupo from solicitudingreso sl, prestamos p, socio s where sl.socioid=s.socioid and p.socioid=s.socioid and p.prestamoid=r.prestamoid; 																																									
			return next r;
		
		end loop;
		
		return;
	
	else
		
		for r in
			select
				p.prestamoid,
				s.clavesocioint,
				substring(su.nombre||' '||su.paterno||' '||su.materno,1,119) as nombre,
				p.referenciaprestamo,
				p.fecha_otorga,
				p.montoprestamo,
				--(case when (pfechacierre-fechaultimapagada(p.prestamoid,pfechacierre))-(case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end) > 0 then (pfechacierre-fechaultimapagada(p.prestamoid,pfechacierre))-(case when p.dias_de_cobro > 0 then p.dias_de_cobro else p.meses_de_cobro*30 end) else 0 end) as dias,
				(case when tp.revolvente=1 then (select dias_mora_linea from dias_mora_linea(p.prestamoid)) else (select diasmoracapital from diasmoracapital(p.prestamoid,pfechacierre)) end) as dias,--case when (pfechacierre-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfechacierre))) > 0 then (pfechacierre-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfechacierre))) else 0 end) as dias,
				--Categoria_mora
				'' as cat_mora,
				--saldo_prestamo,
				0 as saldo_prestamo,
				fechaprecorte as fecha_precorte,
				--Categoria_mora2
				'' as categoria_mora2,
				--saldo_prestamo2
				p.saldoprestamo as saldo_prestamo2,
				pfechacierre as fecha_cierre,
				--Sucursal char(4)
				'' as sucursal,
				tp.desctipoprestamo,
				--dias_mora_precierre
				0
			from prestamos p, tipoprestamo tp,socio s, sujeto su
			where p.fecha_otorga <= pfechacierre and p.claveestadocredito<>'008' and
				tp.tipoprestamoid = p.tipoprestamoid 
				and p.socioid=s.socioid and s.sujetoid = su.sujetoid
				and p.tipoprestamoid<>'CAS'
				and p.saldoprestamo>0
				and p.prestamoid not in (select prestamoid from prestamos where referenciaprestamo in (select substr(referenciaprestamo,1,7) from prestamos where tipoprestamoid='CAS'))
				group by p.prestamoid, p.tipoprestamoid,p.montoprestamo,p.fecha_otorga,p.dias_de_cobro,p.meses_de_cobro,
				p.clavefinalidad,p.fecha_vencimiento,p.referenciaprestamo,p.tasanormal,p.tasa_moratoria,p.socioid,s.clavesocioint,su.sujetoid,su.nombre,su.paterno,su.materno,tp.desctipoprestamo,p.saldoprestamo,tp.revolvente
				order by s.clavesocioint
		loop
			r.sucursal:=ssucid;
			select revolvente into nrevolvente from tipoprestamo inner join prestamos on (tipoprestamo.tipoprestamoid=prestamos.tipoprestamoid);
			select fechaultimapagada into dfechaultimapagada from fechaultimapagada(r.prestamoid,pfechacierre);
			
			-- select (case when diasvencidos = 0 then 'B.VIGENTE' else
			-- (case when diasvencidos > 0 and diasvencidos <= 89 then 'C.MOROSA' else
			-- (case when diasvencidos > 89  then 'D.VENCIDA' end) end) end),saldoprestamo,diasvencidos into r.categoria_mora_precierre,r.saldo_prestamo_precierre,r.dias_mora_precierre from precorte where prestamoid=r.prestamoid and fechacierre=fechaprecorte;
			
			-------categoria cartera cierre
			select saldoprestamo,diasvencidos into r.saldo_prestamo_precierre,r.dias_mora_precierre from precorte where prestamoid=r.prestamoid and fechacierre=fechaprecorte;
			select fecha_1er_pago,dias_de_cobro,meses_de_cobro into dfecha_1er_pago,idias_de_cobro,imeses_de_cobro from prestamos where prestamoid=r.prestamoid;
			if nrevolvente=1 then
				frecuencia:=30;
			else
				frecuencia:=(case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			end if;
			
			select diasmorainteres into ndiasinteres from diasmorainteres(r.prestamoid,pfechacierre,dfechaultimapagada,frecuencia);
			if nrevolvente=0 and ndiasinteres>r.dias_mora then
				r.dias_mora:=ndiasinteres;
			end if;
			raise notice ' dias de interes: -------->  %  ',ndiasinteres;
			raise notice ' nombre:  %  ',r.nombre;
			raise notice 'dias mora cierre:  %  ',r.dias_mora_precierre;
			raise notice 'frecuencia:  %  ',frecuencia;
			if (nrevolvente=1 and r.dias_mora_precierre>=60) or (nrevolvente=0 and ((r.dias_mora_precierre>=21 and frecuencia=7) or (r.dias_mora_precierre>=42 and frecuencia=14) or (r.dias_mora_precierre>=45 and frecuencia=15) or (r.dias_mora_precierre>=90)))then
				r.categoria_mora_precierre:='D.VENCIDA';
			end if;
			if (nrevolvente=1 and r.dias_mora_precierre<60) or (nrevolvente=0 and ((r.dias_mora_precierre<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora_precierre<21 and frecuencia=7) or (r.dias_mora_precierre<42 and frecuencia=14) or (r.dias_mora_precierre<45 and frecuencia=15)))then
				r.categoria_mora_precierre:='C.MOROSA';
			end if;
			if r.dias_mora_precierre=0 then
				r.categoria_mora_precierre:='B.VIGENTE';
			end if;

			if r.fecha_otorgamiento>fechaprecorte  then
				r.categoria_mora_precierre:='A.NUEVA';
			end if;
			-------categoria cartera cierre

			if (nrevolvente=1 and r.dias_mora>=60) or (nrevolvente=0 and ((r.dias_mora>=21 and frecuencia=7) or (r.dias_mora>=42 and frecuencia=14) or (r.dias_mora>=45 and frecuencia=15) or (r.dias_mora>=90))) then
				r.categoria_mora_actual:='D.VENCIDA';
			end if;
			if (nrevolvente=1 and r.dias_mora<60) or (nrevolvente=0 and ((r.dias_mora<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora<21 and frecuencia=7) or (r.dias_mora<42 and frecuencia=14) or (r.dias_mora<45 and frecuencia=15)))then
				r.categoria_mora_actual:='C.MOROSA';
			end if;
			if r.dias_mora=0 then
				r.categoria_mora_actual:='B.VIGENTE';
			end if;

			if r.categoria_mora_precierre='A.NUEVA' then
				r.categoria_mora_actual:='A.NUEVA';
			end if;
			select paterno||' '||materno||' '||nombre into r.cobrador from sujeto where sujetoid = (select sujetoid from cobradores natural join carteracobrador where prestamoid=r.prestamoid group by sujetoid);
			select cobradorid into r.cobradorid from carteracobrador where prestamoid=r.prestamoid;
			if nrevolvente=1 then
				r.frecuencia=30;
			else
				r.frecuencia= (case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			end if;
			select sl.grupo into r.grupo from solicitudingreso sl, prestamos p, socio s where sl.socioid=s.socioid and p.socioid=s.socioid and p.prestamoid=r.prestamoid;
			return next r;
		end loop;
		return;
	end if;
end

$_$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE or replace FUNCTION analisiscarterac(date) RETURNS SETOF tanalisiscartera
AS $_$
declare

pfecha alias for $1;
r tanalisiscartera%rowtype;
f record;
dblink1 text;
dblink2 text;
begin
	for f in
	select * from sucursales where vigente='S'
	loop
	raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

	dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
	dblink2:='set search_path to public,'||f.esquema||';select * from  analisiscartera('||''''||pfecha||''''||');';

	for r in
	select * from
	dblink(dblink1,dblink2) as
	t2(
		fprestamoid integer,
		clavesocioint character(15),
		nombre character varying(120),
		referenciaprestamo character(18),
		fecha_otorgamiento date,
		montoprestamo numeric,
		dias_mora integer,
		categoria_mora_precierre character(10),
		saldo_prestamo_precierre numeric,
		fecha_precierre date,
		categoria_mora_actual character(10),
		saldo_prestamo_actual numeric,
		fecha_actual date,
		sucursal character(4),
		tipoprestamo character(32),
		dias_mora_precierre integer,
		cobrador character varying(80),
		cobradorid integer,
		frecuencia integer,
		grupo text
	)
		loop
			return next r;
		end loop;
	end loop;
	return;
end
$_$
LANGUAGE plpgsql;
