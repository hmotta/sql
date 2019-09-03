CREATE OR REPLACE FUNCTION cobroporgrupo(character, date) RETURNS SETOF rcobroporgrupo
    AS $_$
declare
	r rcobroporgrupo%rowtype;
	pgrupo alias for $1;
	pfecha alias for $2;
	pago1 numeric;
	pago2 numeric;
	buff numeric;
begin
	    for r in
			select 	p.prestamoid,
					s.clavesocioint,
					su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
					p.referenciaprestamo,
					p.ahorrocompromiso,
					0.00 as pago
			from 	prestamos p, 
					socio s, 
					sujeto su, 
					tipoprestamo tp, 
					solicitudingreso si
			where 	si.grupo = pgrupo and 
					s.socioid = si.socioid and
					s.socioid = p.socioid and 
					su.sujetoid = s.sujetoid and 
					tp.tipoprestamoid = p.tipoprestamoid and 
					p.claveestadocredito='001' and
					p.tipoprestamoid in('N5','N53','N54')
			order by s.clavesocioint
	    loop
			SELECT total into pago1 FROM spscalculopagod(r.prestamoid,pfecha);
			select totalpago into pago2 from amortizaciones where prestamoid=r.prestamoid and numamortizacion=2;
			if  pago1 >  pago2 then
				buff = pago1;
			else
				buff = pago2;
			end if;
			SELECT into r.pago round(buff);
			if(r.pago < buff) then
				r.pago = r.pago + 1;
			end if;
      		return next r;
    	  end loop;
return;
end
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION public.cobroporgrupo(character, date) OWNER TO sistema;

