CREATE OR REPLACE FUNCTION spstasastipoprestamo(character, numeric, integer, character) RETURNS SETOF ttasastipoprestamo
    AS $_$
declare
  ptipoprestamoid alias for $1;
  pmontoprestamo alias for $2;
  psocioid alias for $3;
  preferenciaprestamo alias for $4;
  r ttasastipoprestamo%rowtype;


  nsumaprestamos numeric; --sumar monto_garantia de creditos vigentes 
  nreciprocidad numeric;
  ntasanormal numeric;
  ntasamoratoria numeric;
  ntasanormaltasa numeric;
  ntasamoratoriatasa numeric;
  nsaldoinversion numeric;
  stipomovimientoid char(2);

begin

   select sum(monto_garantia)
     into nsumaprestamos
     from prestamos
    where socioid=psocioid and
          claveestadocredito='001' and
          saldoprestamo > 0 and
	  clavegarantia='02' and
          referenciaprestamo <> preferenciaprestamo and tipoprestamoid not in ('N7');

   nsumaprestamos:=coalesce(nsumaprestamos,0);
--   nsumaprestamos:=nsumaprestamos+pmontoprestamo;

   select tasa_normal,tasa_mora,tipomovimientoid
     into ntasanormal,ntasamoratoria,stipomovimientoid
     from tipoprestamo
    where tipoprestamoid=ptipoprestamoid;


    SELECT sum(saldo) into nreciprocidad FROM spssaldosmov(psocioid) where tipomovimientoid in ('AA','P3');
	raise notice 'nreciprocidad: %',nreciprocidad;
	select coalesce(SUM((case when mp.cuentaid=t.cuentapasivo then mp.haber-mp.debe else 0 end)),0) into nsaldoinversion from polizas p, movicaja m, movipolizas mp, inversion i,tipoinversion t where i.socioid=psocioid and i.fechainversion<=current_date and m.inversionid = i.inversionid and p.polizaid = m.polizaid and p.fechapoliza <= CURRENT_DATE and t.tipoinversionid = i.tipoinversionid and mp.polizaid = p.polizaid and i.tipoinversionid in ('PSO','PSV');	
	raise notice 'nsaldoinversion: %',nsaldoinversion;
   nreciprocidad := coalesce (nreciprocidad,0)+nsaldoinversion;
	raise notice 'reciprocidad: %',nreciprocidad;	
   -- raise notice ' antes reciprocidad %  montoprestamo %  tasa % ',nreciprocidad,nsumaprestamos,ntasanormal;
--   raise notice 'Saldo ahorro: %, Montoprestamos: % ',nreciprocidad,nsumaprestamos;

   if (select count(*) from tasastipoprestamo where tipoprestamoid=ptipoprestamoid)>0 then

           nreciprocidad:= round(((nreciprocidad-nsumaprestamos) / pmontoprestamo) * 100,2);
--raise notice 'Saldo porce: %',nreciprocidad;	
	if nreciprocidad>100 then
	   nreciprocidad:=100;
	end if;
	if nreciprocidad<0 then
	   nreciprocidad:=0;
	end if;

           select tasanormal,tasamoratoria
             into ntasanormaltasa,ntasamoratoriatasa
             from tasastipoprestamo
            where tipoprestamoid=ptipoprestamoid and
                  nreciprocidad between reciprocidadinicial and reciprocidadfinal;

           ntasanormal := coalesce(ntasanormaltasa,ntasanormal);
           ntasamoratoria := coalesce(ntasamoratoriatasa,ntasamoratoria);
    
   end if;

   --raise notice ' despues reciprocidad %  montoprestamo % tasa % ',nreciprocidad,nsumaprestamos,ntasanormal;

   r.tasanormal   := ntasanormal;
   r.tasamoratoria:= ntasamoratoria;

   return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;