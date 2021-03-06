CREATE OR REPLACE FUNCTION analisiscartera(date)
  RETURNS SETOF tanalisiscartera AS $BODY$
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
	dultimoabonointeres date;
	ndiasinteres integer;
	psostenido integer;
	idiascapital integer;
	idiasinteres integer;
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
				p.clavefinalidad,p.fecha_vencimiento,p.referenciaprestamo,p.tasanormal,p.tasa_moratoria,p.socioid,s.clavesocioint,su.sujetoid,su.nombre,su.paterno,su.materno,tp.desctipoprestamo,p.saldoprestamo
				order by s.clavesocioint
		loop
			r.sucursal:=ssucid;
			select fechaultimapagada into dfechaultimapagada from fechaultimapagada(r.prestamoid,pfechacierre);
			---dias mora cierre actual-----
			select saldoprestamo,diasvencidos into r.saldo_prestamo_actual,r.dias_mora from precorte where prestamoid=r.prestamoid and fechacierre=fechacierre1;
			select saldoprestamo,diasvencidos into r.saldo_prestamo_precierre,r.dias_mora_precierre from precorte where prestamoid=r.prestamoid and fechacierre=fechaprecorte;
			select fecha_1er_pago,dias_de_cobro,meses_de_cobro into dfecha_1er_pago,idias_de_cobro,imeses_de_cobro from prestamos where prestamoid=r.prestamoid;
			frecuencia:=(case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			--raise notice ' nombre:  %  ',r.nombre;
			--raise notice 'dias mora cierre:  %  ',r.dias_mora_precierre;
			--raise notice 'frecuencia:  %  ',frecuencia;
			if (r.dias_mora_precierre>=21 and frecuencia=7) or (r.dias_mora_precierre>=42 and frecuencia=14) or  (r.			dias_mora_precierre>=45 and frecuencia=15) or (r.dias_mora_precierre>=90)then
				r.categoria_mora_precierre:='D.VENCIDA';
			end if;
			if (r.dias_mora_precierre<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora_precierre<21 and frecuencia=7) or (r.dias_mora_precierre<45 and frecuencia=15) or (r.dias_mora_precierre<42 and frecuencia=14)then
				r.categoria_mora_precierre:='C.MOROSA';
			end if;
			if r.dias_mora_precierre=0 then
				r.categoria_mora_precierre:='B.VIGENTE';
			end if;

			if r.fecha_otorgamiento>fechaprecorte  then
				r.categoria_mora_precierre:='A.NUEVA';
			end if;
			-------categoria cartera cierre
			if (r.dias_mora>=21 and frecuencia=7) or (r.dias_mora>=45 and frecuencia=15)or (r.dias_mora>=42 and frecuencia=14) or (r.dias_mora>=90)then
				r.categoria_mora_actual:='D.VENCIDA';
			end if;
			if (r.dias_mora<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora<21 and frecuencia=7) or (r.dias_mora<45 and frecuencia=15) or(r.dias_mora<42 and frecuencia=14) then
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
			 r.frecuencia:=(case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			select sp.grupo into r.grupo from solicitudprestamo sp, prestamos p, socio s where sp.solicitudprestamoid=p.solicitudprestamoid and sp.socioid=s.socioid and p.socioid=s.socioid and p.prestamoid=r.prestamoid; 							    	
select tipo_cartera_est into r.tipocartera from prestamos where prestamoid=r.prestamoid;  																																				
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
				(select * from diasatrasocapital(p.prestamoid,pfechacierre)) as dias,--case when (pfechacierre-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfechacierre))) > 0 then (pfechacierre-(select fechaprimeradeudo from fechaprimeradeudo(p.prestamoid,pfechacierre))) else 0 end) as dias,
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
				p.clavefinalidad,p.fecha_vencimiento,p.referenciaprestamo,p.tasanormal,p.tasa_moratoria,p.socioid,s.clavesocioint,su.sujetoid,su.nombre,su.paterno,su.materno,tp.desctipoprestamo,p.saldoprestamo
				order by s.clavesocioint
		loop
			r.sucursal:=ssucid;
			---mora + mora origen
			select pagosostenido into psostenido from prestamos where prestamoid=r.prestamoid;
			 if psostenido<3 then
			   	r.dias_mora:=r.dias_mora + (select diasmoraorigen from prestamos where prestamoid=r.prestamoid);
			 end if;

			select fechaultimapagada into dfechaultimapagada from fechaultimapagada(r.prestamoid,pfechacierre);
			select ultimoabonointeres into dultimoabonointeres from ultimoabonointeres(r.prestamoid,pfechacierre);
			
			-- select (case when diasvencidos = 0 then 'B.VIGENTE' else
			-- (case when diasvencidos > 0 and diasvencidos <= 89 then 'C.MOROSA' else
			-- (case when diasvencidos > 89  then 'D.VENCIDA' end) end) end),saldoprestamo,diasvencidos into r.categoria_mora_precierre,r.saldo_prestamo_precierre,r.dias_mora_precierre from precorte where prestamoid=r.prestamoid and fechacierre=fechaprecorte;
			
			-------categoria cartera cierre
			select saldoprestamo,diasvencidos into r.saldo_prestamo_precierre,r.dias_mora_precierre from precorte where prestamoid=r.prestamoid and fechacierre=fechaprecorte;
			select fecha_1er_pago,dias_de_cobro,meses_de_cobro into dfecha_1er_pago,idias_de_cobro,imeses_de_cobro from prestamos where prestamoid=r.prestamoid;
			frecuencia:=(case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			select diasmorainteres into ndiasinteres from diasmorainteres(r.prestamoid,pfechacierre,dfechaultimapagada,frecuencia);
			if ndiasinteres>r.dias_mora then
				r.dias_mora:=ndiasinteres;
			end if;
			---calcular dias mora de una linea de credito
			if r.tipoprestamo='CREDILINEA' then
				idiascapital:=dias_mora_linea(r.prestamoid,pfechacierre);
			idiasinteres:=(case when (select fecha_limite from corte_linea where lineaid=r.prestamoid and int_ordinario>0 order by fecha_limite  limit 1)<=pfechacierre then (case when (dfechaultimapagada-dultimoabonointeres)-r.frecuencia > 0 then (dfechaultimapagada-dultimoabonointeres)-r.frecuencia else 0 end) else 0 end);
			
			
			if idiascapital>idiasinteres then
				r.dias_mora:=idiascapital;
			else
				r.dias_mora:=idiasinteres;
			end if;
			end if;
			------fin de dias mora de una linea de credito
			raise notice ' dias de interes: -------->  %  ',ndiasinteres;
			raise notice ' nombre:  %  ',r.nombre;
			raise notice 'dias mora cierre:  %  ',r.dias_mora_precierre;
			raise notice 'frecuencia:  %  ',frecuencia;
			raise notice ' Fecha Inicial:  %  ',fechaprecorte;
			if (r.dias_mora_precierre>=21 and frecuencia=7) or (r.dias_mora_precierre>=42 and frecuencia=14) or (r.dias_mora_precierre>=45 and frecuencia=15) or (r.dias_mora_precierre>=90)then
				r.categoria_mora_precierre:='D.VENCIDA';
			end if;
			if (r.dias_mora_precierre<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora_precierre<21 and frecuencia=7) or (r.dias_mora_precierre<42 and frecuencia=14) or (r.dias_mora_precierre<45 and frecuencia=15)then
				r.categoria_mora_precierre:='C.MOROSA';
			end if;
			if r.dias_mora_precierre=0 then
				r.categoria_mora_precierre:='B.VIGENTE';
			end if;

			if r.fecha_otorgamiento>fechaprecorte  then
				r.categoria_mora_precierre:='A.NUEVA';
			end if;
			-------categoria cartera cierre

			if (r.dias_mora>=21 and frecuencia=7) or (r.dias_mora>=42 and frecuencia=14) or (r.dias_mora>=45 and frecuencia=15) or (r.dias_mora>=90)then
				r.categoria_mora_actual:='D.VENCIDA';
			end if;
			if (r.dias_mora<90 and frecuencia<>7 and frecuencia<>15 and frecuencia<>14) or (r.dias_mora<21 and frecuencia=7) or (r.dias_mora<42 and frecuencia=14) or (r.dias_mora<45 and frecuencia=15)then
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
			r.frecuencia= (case when dfecha_1er_pago > dfechaultimapagada then dfecha_1er_pago-r.fecha_otorgamiento else (case when idias_de_cobro > 0 then idias_de_cobro else imeses_de_cobro*30 end) end);
			select sp.grupo into r.grupo from solicitudprestamo sp, prestamos p, socio s where sp.solicitudprestamoid=p.solicitudprestamoid and sp.socioid=s.socioid and p.socioid=s.socioid and p.prestamoid=r.prestamoid;
select tipo_cartera_est into r.tipocartera from prestamos where prestamoid=r.prestamoid;
			return next r;
		end loop;
		return;
	end if;
end

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION public.analisiscartera(date) OWNER TO sistema;
