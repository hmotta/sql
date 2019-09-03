

drop TYPE ramortizacionesxgrupo cascade;

CREATE TYPE ramortizacionesxgrupo AS (
	grupo character(25),
        referenciaprestamo char(18),
        numamortizacion integer,
        fechadepago date,
        importeamortizacion numeric,
        interesnormal numeric,
        iva numeric,
        totalpago numeric,
        prestamoid integer,
        clavesocioint char(15),       
	nombresocio character(40),
        vencapital numeric,
        veninteres numeric,
        venmoratorio numeric,
        veniva numeric,
        ventotal numeric
); 


CREATE FUNCTION spamortizacionesxgrupo(date,date,char(25),char(25),date) RETURNS SETOF ramortizacionesxgrupo
    AS $_$
declare

  pfechai alias for $1;
  pfechaf alias for $2;
  pgrupo1 alias for $3;
  pgrupo2 alias for $4;
  pfechacal alias for $5;
  
  r ramortizacionesxgrupo;
 
begin

  for r in  
     select si.grupo,p.referenciaprestamo,a.numamortizacion,a.fechadepago,a.importeamortizacion,a.interesnormal,a.iva,a.totalpago,p.prestamoid,s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio,0 as vencapital,0 as veninteres, 0 as venmoratorio, 0 as veniva,0 as ventotal from amortizaciones a, prestamos p, solicitudingreso si,socio s,sujeto su where (a.importeamortizacion > a.abonopagado ) and a.fechadepago >= pfechai and a.fechadepago <= pfechaf and a.prestamoid=p.prestamoid and p.socioid=si.socioid and si.grupo >= pgrupo1 and si.grupo<=pgrupo2 and p.socioid=s.socioid and s.sujetoid=su.sujetoid order by si.grupo

  loop

     select capital,interes,moratorio,iva,capital+interes+moratorio+iva into r.vencapital,r.veninteres,r.venmoratorio,r.veniva,r.ventotal from spscalculopagocartera(r.prestamoid,pfechacal);

     return next r;
     
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    


    

