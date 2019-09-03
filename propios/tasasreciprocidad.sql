--Actualizado en sucursales 07-Ago-2009 9:00 hrs

CREATE or replace FUNCTION spstasastipoprestamo(character, numeric, integer, character) RETURNS SETOF ttasastipoprestamo
    AS '
declare
  ptipoprestamoid alias for $1;
  pmontoprestamo alias for $2;
  psocioid alias for $3;
  preferenciaprestamo alias for $4;
  r ttasastipoprestamo%rowtype;


  nsumaprestamos numeric;
  nreciprocidad numeric;
  ntasanormal numeric;
  ntasamoratoria numeric;
  ntasanormaltasa numeric;
  ntasamoratoriatasa numeric;
  stipomovimientoid char(2);

begin

   select sum(montoprestamo)
     into nsumaprestamos
     from prestamos
    where socioid=psocioid and
          claveestadocredito=''001'' and
          saldoprestamo > 0 and
          referenciaprestamo <> preferenciaprestamo and tipoprestamoid <> ''N7'';



   nsumaprestamos:=coalesce(nsumaprestamos,0);
   nsumaprestamos:=nsumaprestamos+pmontoprestamo;

   select tasa_normal,tasa_mora,tipomovimientoid
     into ntasanormal,ntasamoratoria,stipomovimientoid
     from tipoprestamo
    where tipoprestamoid=ptipoprestamoid;

   select sum(debe)-sum(haber)
     into nreciprocidad
     from movicaja mc, movipolizas mp
    where mc.socioid=psocioid and
          mc.tipomovimientoid in (stipomovimientoid,''AA'') and
          mc.movipolizaid = mp.movipolizaid;

   nreciprocidad := coalesce (nreciprocidad,0);
 
   -- raise notice '' antes reciprocidad %  montoprestamo %  tasa % '',nreciprocidad,nsumaprestamos,ntasanormal;

   if nsumaprestamos <> 0 or (select count(*) from tasastipoprestamo where tipoprestamoid=ptipoprestamoid)>0 then

           nreciprocidad:= nreciprocidad / nsumaprestamos * 100;

           select tasanormal,tasamoratoria
             into ntasanormaltasa,ntasamoratoriatasa
             from tasastipoprestamo
            where tipoprestamoid=ptipoprestamoid and
                  reciprocidadinicial<=nreciprocidad and reciprocidadfinal > nreciprocidad;

           ntasanormal := coalesce(ntasanormaltasa,ntasanormal);
           ntasamoratoria := coalesce(ntasamoratoriatasa,ntasamoratoria);
    
   end if;

   --raise notice '' despues reciprocidad %  montoprestamo % tasa % '',nreciprocidad,nsumaprestamos,ntasanormal;

   r.tasanormal   := ntasanormal;
   r.tasamoratoria:= ntasamoratoria;

   return next r;

return;
end
'
    LANGUAGE plpgsql SECURITY DEFINER;

