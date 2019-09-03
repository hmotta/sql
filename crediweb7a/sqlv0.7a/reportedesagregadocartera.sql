
drop TYPE rdesagregadoprestamo cascade;
CREATE TYPE rdesagregadoprestamo AS (
	fechacierre date,
	referenciaprestamo character(18),
        diasvencidos integer,
        devengadovigente numeric,
	devengadovencido numeric,
        interesdevengadomenoravencido numeric,
	interesdevengadomayoravencido numeric,
	reservacalculada numeric,
        reservacubierta numeric        
);



CREATE or replace FUNCTION  movimientosprecierre(integer) RETURNS SETOF rdesagregadoprestamo
    AS $_$
declare
  pprestamoid alias for $1;
    
  r rdesagregadoprestamo%rowtype;
   
begin

   for r in select p.fechacierre,pr.referenciaprestamo,diasvencidos,saldovencidomenoravencido,saldovencidomayoravencido,(case when  p.diasvencidos <= p.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as devengadovigente,(case when  p.diasvencidos > p.diastraspasoavencida then interesdevengadomenoravencido+interesdevmormenor else 0 end) as devengadovencido,reservacalculada,round(reservacalculada*factoraplicado,2) as reservacubierta from precorte p, prestamos pr where p.prestamoid=pprestamoid and p.prestamoid=pr.prestamoid order by p.fechacierre
   loop 
     return next r;
   end loop;  

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
