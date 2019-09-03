DROP TYPE rvalidarreciprocidades CASCADE;
CREATE TYPE rvalidarreciprocidades AS (
	sucursal character(4),
	nombre character varying(100),
	clave_socio_cliente character varying(18),
	tipoprestamo character(10),
	referenciaprestamo character varying(18),
	monto_original numeric,
	saldo numeric,
	fecha_de_otorgamiento character(10),
	fecha_de_vencimiento character(10),
	tasa_ordinaria_nominal_anual numeric,
	tasa_moratoria_nominal_anual numeric,
	usuario_apertura character(12),
	monto_garantia_liquida numeric,
	saldoaa numeric,
	saldop3 numeric,
	garantiasugerida numeric,
	fecha_liberacion date,
	usuario_libera character varying(12),
	monto_liberado numeric
);

CREATE OR REPLACE FUNCTION spsvalidarreciprocidades(date, date) RETURNS SETOF rvalidarreciprocidades
    AS $_$
declare

	pfechaini  alias for $1;
	pfechafin alias for $2;
  r rvalidarreciprocidades%rowtype;
  l rvalidarreciprocidades%rowtype;
  f record;
  pmultiplica numeric;
  pnombre character varying(40);
  i int;
begin

  i:=1;
  for r in
       select
	--1 sucursal
		substring(s.clavesocioint,1,4),
	--2 nombre socio
		su.nombre||' '||su.paterno||' '|| su.materno as nombre,
	--3 clave socio 
		s.clavesocioint,
	--4 tipo prestamo
		p.tipoprestamoid,
	--5 referencia prestamo  
		trim(p.referenciaprestamo),
	--6 Monto prestamo 
		p.montoprestamo ,
	--7 Saldo prestamo 
		p.saldoprestamo,
	--8 Fecha otorgamiento
		p.fecha_otorga,
	--9 Fecha vencimiento
		p.fecha_vencimiento,
	--10 Tasa normal
		p.tasanormal,
	--11 Tasa moratoria
		p.tasa_moratoria,
	--12 usuario de apertura 
		p.usuarioid,
	--13 Monto Garantia
		p.monto_garantia,
	--14 saldo AA
		saldomov(s.socioid,'AA',current_date)as aa,
	--15 Saldo en P3
		saldomov(s.socioid,'P3',current_date) as p3,
	--16 garantia sugerida
		 (select reciprocidadinicial from tasastipoprestamo where tipoprestamoid=p.tipoprestamoid and tasanormal>=p.tasanormal order by tasanormal, reciprocidadinicial limit 1),
	--17 fecha liberacion
		null,
	--18 usuario libera
		null,
	--19 monto liberado
		null

	from socio s, sujeto su, prestamos p

	where
		-- p.monto_garantia=0 
		 s.sujetoid=su.sujetoid 
		and s.socioid=p.socioid 
		and p.claveestadocredito<>'008' 
		and p.claveestadocredito<>'002' 
		--and p.tipoprestamoid<>'N16' 
		--and p.tipoprestamoid<>'N7'  
		--and p.tipoprestamoid<>'P4'  
		and p.fecha_otorga>=pfechaini and p.fecha_otorga<=pfechafin


  loop
   	
	 r.garantiasugerida:=r.monto_original*(r.garantiasugerida/100);
	 return next r;
	 --l=r;
	 raise notice 'Referencia=-%-',r.referenciaprestamo;
	 
	 for f in
		select fecha,usuarioid,montogarantialiberado from bitacoraliberagarantia where referenciaprestamo=r.referenciaprestamo order by fecha
	 loop
		raise notice 'fecha_liberacion=%',f.fecha;
		l.fecha_liberacion:=f.fecha;
		l.usuario_libera:=f.usuarioid;
		l.monto_liberado:=f.montogarantialiberado;
		return next l;
	 end loop;
	 
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;