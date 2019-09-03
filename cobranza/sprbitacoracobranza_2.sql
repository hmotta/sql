drop function sprbitacoracobranza(date,character);
drop type rbitacoracobranza;
CREATE TYPE rbitacoracobranza AS (
	consecutivo integer,
	etapa character varying(30),
	clavesocioint character varying(15),
	nombre character varying(50),	
	telefono character varying(30),
	saldoactual numeric,
	montomoroso numeric,
	abonosvencidos integer,
	diasmora integer,
	fechagestion date,
	nombreatiende character varying(50),
	acuerdo text
);

CREATE OR REPLACE FUNCTION sprbitacoracobranza(date,character) RETURNS SETOF rbitacoracobranza
    AS $_$
declare
  r rbitacoracobranza%rowtype;
  l record;
  pfecha alias for $1;
  pusuario alias for $2;
  diasmora integer;
  i integer;
begin
	i:=0;
	for l in
		SELECT ac.acuerdocobranzaid,prestamoid FROM acuerdocobranza ac,resultadocobranza rc,gestioncredito gc where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and fechacompromiso<current_date
	loop
		select current_date -min(fechadepago) into diasmora from amortizaciones where abonopagado<>importeamortizacion and prestamoid=l.prestamoid;
		if diasmora>0 then 
			update acuerdocobranza set acuerdocumplido='N' where acuerdocobranzaid=l.acuerdocobranzaid;
		end if;
	end loop;
	
	for r in
		  select 0,
		  gc.etapa,
		  s.clavesocioint,
		  nombre||' '||paterno||' '||materno as nombre,
		  (select coalesce((select celular from extensionsujeto where sujetoid=su.sujetoid),(select teldomicilio from domicilio where sujetoid=su.sujetoid))) as telefono,
		  p.saldoprestamo,
		  (SELECT vencidas FROM spscalculopago(p.prestamoid)),
		  (select current_date -min(fechadepago) from amortizaciones where abonopagado<>importeamortizacion and prestamoid=p.prestamoid),
		  (select count(*) from amortizaciones where (importeamortizacion-abonopagado)>0 and prestamoid=p.prestamoid and fechadepago <= current_date),
		  gc.fechagestion,
		  rc.nombreatiende,
		  ac.acuerdo
		  from prestamos p,acuerdocobranza ac,resultadocobranza rc,gestioncredito gc,socio s,sujeto su where ac.acuerdocobranzaid=rc.acuerdocobranzaid and rc.resultadocobranzaid=gc.resultadocobranzaid and gc.prestamoid=p.prestamoid and s.socioid=p.socioid and su.sujetoid=s.sujetoid and usuariogestiona=pusuario and fechagestion=pfecha
	loop
		i:=i+1;
		r.consecutivo:=i;
		
		return next r;
	end loop;
	
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;