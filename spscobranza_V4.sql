--Modificado
drop function spscobranza(integer);
drop type rgestioncobranza;
CREATE TYPE rgestioncobranza AS(
	prestamoid integer,
	clavesocioint character varying(15),
	nombre character varying(50),
	referenciaprestamo character varying(18),
	grupo character varying (25),
	desctipoprestamo character varying(30),
	pagosvencidos integer,
	diasmora integer,
	fechacompromiso date,
	oportunidad character varying(10),
	cobrador character varying(50),
	montocompromiso numeric,
	montoprestamo numeric,
	saldo numeric
);

CREATE OR REPLACE FUNCTION spscobranza(integer) RETURNS SETOF rgestioncobranza
    AS $_$
declare
  r rgestioncobranza%rowtype;
  l record;
  petapaid alias for $1;
  diasmora integer;
  fechacomptabla date;
  saldoactual numeric;
  suma_compromiso numeric;
begin
	for l in
		SELECT ac.acuerdocobranzaid,pr.prestamoid,pr.socioid,ac.fechacompromiso,ac.acuerdocumplido,ac.montocompromiso,gc.fechagestion,gc.saldo as saldoanterior FROM acuerdocobranza ac,resultadocobranza rc,gestioncredito gc,prestamos pr where pr.prestamoid = gc.prestamoid and ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and acuerdocumplido = 'P'
	loop
		select sum(debe)
		into suma_compromiso
		from movicaja mc, polizas p,movipolizas mp where mc.movipolizaid=mp.movipolizaid and p.polizaid=mp.polizaid and mc.tipomovimientoid in ('00','0A') and mc.socioid=l.socioid and mc. prestamoid=l.prestamoid and p.fechapoliza between l.fechagestion and l.fechacompromiso;
		
		if suma_compromiso >= l.montocompromiso then
			update acuerdocobranza set acuerdocumplido ='S' where acuerdocobranzaid=l.acuerdocobranzaid;
		elsif l.fechacompromiso < current_date then
			update acuerdocobranza set acuerdocumplido ='N' where acuerdocobranzaid=l.acuerdocobranzaid;		
		else
			update acuerdocobranza set acuerdocumplido ='P' where acuerdocobranzaid=l.acuerdocobranzaid;
		end if;
	end loop;
	
    if petapaid=1 then
		for r in
		  select p.prestamoid,
		  s.clavesocioint,
		  su.nombre||' '||su.paterno||' '||su.materno as nombre,
		  trim(p.referenciaprestamo),
		  (select grupo from solicitudingreso where socioid=s.socioid) as grupo,
		  tp.desctipoprestamo,
		  (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date),
		  (select current_date -min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) as diasdemora,
		  (case when exists(select fechacompromiso from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) then (select max(fechacompromiso) from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) else (select min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) end),
		  (select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='N' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid))+(select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='P' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid)) as oportunidad,
		  (select B.nombre||' '||B.paterno||' '||B.materno from carteracobrador cc natural join (select * from cobradores natural join sujeto) B where cc.prestamoid=p.prestamoid)
		  from prestamos p, socio s,sujeto su,tipoprestamo tp 
		  where p.socioid=s.socioid and 
		  su.sujetoid=s.sujetoid and 
		  p.tipoprestamoid=tp.tipoprestamoid and 
		  p.tipoprestamoid<>'CAS' and
		  p.prestamoid not in (select prestamoid from alternativadepago union select prestamoid from carteraabogado) and
		  claveestadocredito='001' group by p.prestamoid,s.socioid,s.clavesocioint,su.nombre,su.paterno,su.materno,p.referenciaprestamo,tp.desctipoprestamo 
		  having (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date)=1 order by grupo,diasdemora
		loop
			if r.diasmora> 0 and r.diasmora<= 30 then
					if r.oportunidad='0' then
						r.oportunidad='NINGUNA';
					elseif r.oportunidad='1' then
						r.oportunidad='PRIMERA';
					elseif r.oportunidad='2' then
						r.oportunidad='SEGUNDA';
					elseif r.oportunidad='3' then
						r.oportunidad='TERCERA';
					else
						r.oportunidad='CUARTA';
					end if;
					
					select min(fechadepago) into fechacomptabla from amortizaciones where abonopagado<>importeamortizacion and prestamoid=r.prestamoid;
					if fechacomptabla>r.fechacompromiso then
						r.fechacompromiso:=fechacomptabla;
					end if;
					
					SELECT ac.montocompromiso
					into r.montocompromiso
					FROM acuerdocobranza ac,resultadocobranza rc,gestioncredito gc,prestamos pr where pr.prestamoid = gc.prestamoid and ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and pr.prestamoid=r.prestamoid and acuerdocumplido='P';
			
					SELECT montoprestamo,saldoprestamo
					into r.montoprestamo,r.saldo
					FROM prestamos where prestamoid=r.prestamoid;
					
					return next r;
					
			end if;
			
			
			
		end loop;
	elseif petapaid=2 then
			
		for r in
		  select p.prestamoid,
		  s.clavesocioint,
		  su.nombre||' '||su.paterno||' '||su.materno as nombre,
		  trim(p.referenciaprestamo),
		  (select grupo from solicitudingreso where socioid=s.socioid) as grupo,
		  tp.desctipoprestamo,
		  (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date),
		  (select current_date -min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) as diasdemora,
		  (case when exists(select fechacompromiso from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) then (select max(fechacompromiso) from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) else (select min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) end),
		  (select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='N' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid))+(select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='P' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid)) as oportunidad,
		  (select B.nombre||' '||B.paterno||' '||B.materno from carteracobrador cc natural join (select * from cobradores natural join sujeto) B where cc.prestamoid=p.prestamoid)
		  from prestamos p, socio s,sujeto su,tipoprestamo tp 
		  where p.socioid=s.socioid and 
		  su.sujetoid=s.sujetoid and 
		  p.tipoprestamoid=tp.tipoprestamoid and 
		  p.tipoprestamoid<>'CAS' and
		  p.prestamoid not in (select prestamoid from alternativadepago union select prestamoid from carteraabogado) and
		  claveestadocredito='001' group by p.prestamoid,s.socioid,s.clavesocioint,su.nombre,su.paterno,su.materno,p.referenciaprestamo,tp.desctipoprestamo 
		  having (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date) <= 3 order by grupo,diasdemora
		loop
			if (r.diasmora> 30 and r.diasmora<= 90) or r.pagosvencidos>1 then
					if r.oportunidad='0' then
						r.oportunidad='NINGUNA';
					elseif r.oportunidad='1' then
						r.oportunidad='PRIMERA';
					elseif r.oportunidad='2' then
						r.oportunidad='SEGUNDA';
					elseif r.oportunidad='3' then
						r.oportunidad='TERCERA';
					else
						r.oportunidad='CUARTA';
					end if;
					
					select min(fechadepago) into fechacomptabla from amortizaciones where abonopagado<>importeamortizacion and prestamoid=r.prestamoid;
					if fechacomptabla<>NULL and fechacomptabla>r.fechacompromiso then
						r.fechacompromiso:=fechacomptabla;
					end if;
					
					SELECT ac.montocompromiso
					into r.montocompromiso
					FROM acuerdocobranza ac,resultadocobranza rc,gestioncredito gc,prestamos pr where pr.prestamoid = gc.prestamoid and ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and pr.prestamoid=r.prestamoid and acuerdocumplido='P';
					
					SELECT montoprestamo,saldoprestamo
					into r.montoprestamo,r.saldo
					FROM prestamos where prestamoid=r.prestamoid;
					
					return next r;
			end if;
		end loop;
	elseif petapaid=3 then
		for r in
		  select p.prestamoid,
		  s.clavesocioint,
		  su.nombre||' '||su.paterno||' '||su.materno as nombre,
		  trim(p.referenciaprestamo),
		  (select grupo from solicitudingreso where socioid=s.socioid) as grupo,
		  tp.desctipoprestamo,
		  (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date),
		  (select current_date -min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) as diasdemora,
		  (case when exists(select fechacompromiso from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) then (select max(fechacompromiso) from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) else (select min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) end),
		  (select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='N' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid))+(select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='P' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid)) as oportunidad,
		  (select B.nombre||' '||B.paterno||' '||B.materno from carteracobrador cc natural join (select * from cobradores natural join sujeto) B where cc.prestamoid=p.prestamoid)
		  from prestamos p, socio s,sujeto su,tipoprestamo tp 
		  where p.socioid=s.socioid and 
		  su.sujetoid=s.sujetoid and 
		  p.tipoprestamoid=tp.tipoprestamoid and 
		  p.tipoprestamoid<>'CAS' and
		  p.prestamoid not in (select prestamoid from alternativadepago union select prestamoid from carteraabogado) and
		  claveestadocredito='001' group by p.prestamoid,s.socioid,s.clavesocioint,su.nombre,su.paterno,su.materno,p.referenciaprestamo,tp.desctipoprestamo 
		  having (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date) <= 5 order by grupo,diasdemora
		loop
			if (r.diasmora> 90 and r.diasmora<= 150) or r.pagosvencidos>3 then
					if r.oportunidad='0' then
						r.oportunidad='NINGUNA';
					elseif r.oportunidad='1' then
						r.oportunidad='PRIMERA';
					elseif r.oportunidad='2' then
						r.oportunidad='SEGUNDA';
					elseif r.oportunidad='3' then
						r.oportunidad='TERCERA';
					else
						r.oportunidad='CUARTA';
					end if;
					
					select min(fechadepago) into fechacomptabla from amortizaciones where abonopagado<>importeamortizacion and prestamoid=r.prestamoid;
					if fechacomptabla<>NULL and fechacomptabla>r.fechacompromiso then
						r.fechacompromiso:=fechacomptabla;
					end if;
					SELECT ac.montocompromiso
					into r.montocompromiso
					FROM acuerdocobranza ac,resultadocobranza rc,gestioncredito gc,prestamos pr where pr.prestamoid = gc.prestamoid and ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and pr.prestamoid=r.prestamoid and acuerdocumplido='P' ;
					
					SELECT montoprestamo,saldoprestamo
					into r.montoprestamo,r.saldo
					FROM prestamos where prestamoid=r.prestamoid;
					return next r;
			end if;
		end loop;
	
	else
		raise notice 'Etapa 4';
		for r in
		  select p.prestamoid,
		  s.clavesocioint,
		  su.nombre||' '||su.paterno||' '||su.materno as nombre,
		  trim(p.referenciaprestamo),
		  (select grupo from solicitudingreso where socioid=s.socioid) as grupo,
		  tp.desctipoprestamo,
		  (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date),
		  (select current_date -min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) as diasdemora,
		  (case when exists(select fechacompromiso from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) then (select max(fechacompromiso) from acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid) else (select min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid) end),
		  (select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='N' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid))+(select coalesce(count(*),0) from acuerdocobranza ac,resultadocobranza rc, gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and ac.acuerdocumplido='P' and gc.numerodeatraso=(select max(numerodeatraso) from gestioncredito where prestamoid=p.prestamoid)) as oportunidad,
		  (select B.nombre||' '||B.paterno||' '||B.materno from carteracobrador cc natural join (select * from cobradores natural join sujeto) B where cc.prestamoid=p.prestamoid)
		  from prestamos p, socio s,sujeto su,tipoprestamo tp 
		  where p.socioid=s.socioid and 
		  su.sujetoid=s.sujetoid and 
		  p.tipoprestamoid=tp.tipoprestamoid and 
		  p.tipoprestamoid<>'CAS' and
		  p.prestamoid not in (select prestamoid from alternativadepago union select prestamoid from carteraabogado) and
		  claveestadocredito='001' group by p.prestamoid,s.socioid,s.clavesocioint,su.nombre,su.paterno,su.materno,p.referenciaprestamo,tp.desctipoprestamo 
		  having (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago < current_date) >= 1 order by grupo,diasdemora
		loop
			if r.diasmora> 150 or r.pagosvencidos>5 then
					if r.oportunidad='0' then
						r.oportunidad='NINGUNA';
					elseif r.oportunidad='1' then
						r.oportunidad='PRIMERA';
					elseif r.oportunidad='2' then
						r.oportunidad='SEGUNDA';
					elseif r.oportunidad='3' then
						r.oportunidad='TERCERA';
					else
						r.oportunidad='CUARTA';
					end if;
					
					select min(fechadepago) into fechacomptabla from amortizaciones where abonopagado<>importeamortizacion and prestamoid=r.prestamoid;
					if fechacomptabla<>NULL and fechacomptabla>r.fechacompromiso then
						r.fechacompromiso:=fechacomptabla;
					end if;
					
					SELECT ac.montocompromiso
					into r.montocompromiso
					FROM acuerdocobranza ac,resultadocobranza rc,gestioncredito gc,prestamos pr where pr.prestamoid = gc.prestamoid and ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and pr.prestamoid=r.prestamoid and acuerdocumplido='P';
					
					SELECT montoprestamo,saldoprestamo
					into r.montoprestamo,r.saldo
					FROM prestamos where prestamoid=r.prestamoid;
					return next r;
			end if;
			
		end loop;
	end if;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;