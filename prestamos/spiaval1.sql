CREATE or replace FUNCTION spiaval(integer, integer, integer, numeric, character varying, integer, integer, integer) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  psocioid alias for $2;
  psujetoid alias for $3;
  pporcentajeavala alias for $4;
  prelacionconsocio alias for $5;
  pessobreprestamo alias for $6;
  pnoaval alias for $7;
  psolicitudprestamoid alias for $8;

  avala integer;

  preferenciaprestamo char(18);
  lsocioid int4;

  iavalesc int4;
  nocreditos int4;
  mayoratres int4;
  diasmora int4;
 avalados   int4;

  snombre char(40);
  spaterno char(20);
  smaterno char(20);
  srfc char(16);
  numeroaval int4;
  
  inoavalesxprestamo int4;
  lavalid int4;

  laval int4;
  r record;
  
begin

----valida que el aval no tenga dias mora en sus prestamos
	for r in 
		select p.prestamoid    
		       from prestamos p,socio s
		       where s.sujetoid =psujetoid and
			  p.socioid = s.socioid and
			  p.saldoprestamo>0 and
			  p.claveestadocredito='001'
	loop
		select current_date -min(fechadepago) into diasmora from amortizaciones where abonopagado<>importeamortizacion and prestamoid=r.prestamoid;
   		diasmora := coalesce(diasmora,0);
			if diasmora>=1 then
          			raise exception 'El Aval % no se acepta por que tiene un prestamo con % dias de Mora.',pnoaval,diasmora;
     			end if;
	end loop;
---FIN valida que el aval no tenga dias mora en sus prestamos
	diasmora :=0;
----validad que los  avalados del aval no tenga dias mora en sus prestamos
   	for r in 
		select p.prestamoid
		     from prestamos p,avales a
		     where a.sujetoid =psujetoid  and
			  p.prestamoid = a.prestamoid and
			  p.saldoprestamo>0 and
			  p.claveestadocredito='001'
        loop
		select current_date -min(fechadepago) into diasmora from amortizaciones where abonopagado<>importeamortizacion and prestamoid=r.prestamoid;
   		diasmora := coalesce(diasmora,0);
			if diasmora>=1 then
          			raise exception 'El Aval % no se acepta ya que tambien avala a otro credito con % dias de mora.',pnoaval,diasmora;
     			end if;
   	end loop;

--- FIN validad que los  avalados del aval no tenga dias mora en sus prestamos

-- Validar que el aval solo tenga un credito activo
	select count(*) into nocreditos          
		from prestamos p,socio s
  	  	where s.sujetoid =psujetoid and
		  p.socioid = s.socioid and
		  p.saldoprestamo>0 and
		  p.claveestadocredito='001'and p.tipoprestamoid NOT IN ('N5','N53','N54');
		  nocreditos := coalesce(nocreditos,0);
		  --validar si tiene mas de un prestamo activo
		if nocreditos>0 then
			
		raise notice 'sujeto % .',psujetoid;  
		     select count(*) into avalados 
			from avales a, prestamos p
			 where a.sujetoid=psujetoid and 
			p.prestamoid=a.prestamoid and 
			claveestadocredito='001';
				avalados := coalesce(avalados,0);   
		raise notice 'valor de avalados % .',avalados;       
     		--validar si solo tiene un prestamo activo y solo avala a un prestamo
          	    if avalados>0 then
          		raise exception 'El Aval % tiene un prestamo activo y tambien avala ya a un prestamo. No puede avalar mas.',pnoaval;
     		    end if;
     		end if;
--validar que el aval no avale mas de 3 prestamos activos cuando el no cuente con ningun prestamo
	  select count(*) into avala
	     from prestamos p,avales a
	    where a.sujetoid = psujetoid and
		  p.prestamoid = a.prestamoid and
		  p.saldoprestamo>0 and
		  p.claveestadocredito='001';
		  avala := coalesce(avala,0);

 	if avala>=3 then
          	raise exception 'El Aval % ya esta avalando a 3 Prestamos,  no se puede ser aval de otro prestamo.',pnoaval;
     		end if;

--fin de validar que el aval no avale mas de 3 prestamos activos cuando el no cuente con ningun prestamo


    
--validacion del proveedor del sistema------------------------------------------------------------------------------------  
   
   select noavalesxprestamo
     into inoavalesxprestamo
    from empresa where empresaid=1;

-- Validar que el aval no se encuentre en mas de 2 prestamos activos

       	
          

   -- Ojo no tomo sobreprestamos
   if pessobreprestamo=0 then   
     
     if avala>=inoavalesxprestamo then
       raise exception 'El Aval ya avala a % prestamos activos, no se puede ser aval de otro prestamo.',avala;
     end if;

     -- Checar en las demas sucursales
     select nombre,paterno,materno,rfc
       into snombre,spaterno,smaterno,srfc
       from sujeto
      where sujetoid = psujetoid;
--     select count(*)
--       into iavalesc
--       from spsavalac(snombre,spaterno,smaterno,srfc);

     iavalesc:=coalesce(iavalesc,0);

     if iavalesc>=inoavalesxprestamo then
       raise exception 'El Aval ya avala a % prestamos activos, no se puede ser aval de otro prestamo.',iavalesc;
     end if;         

   end if;

   if psocioid is null then
     select socioid
       into lsocioid
       from socio
      where sujetoid = psujetoid;
 
     lsocioid := coalesce(lsocioid,0);
   else
     lsocioid := psocioid;     
   end if;

        
   if psolicitudprestamoid is not null then
   select avalid into laval
     from avales where solicitudprestamoid=psolicitudprestamoid and sujetoid=psujetoid;
   else
     select avalid into laval
     from avales where prestamoid=pprestamoid and sujetoid=psujetoid;
   end if;
   laval:=coalesce(laval,0);

   if laval=0 then

     if lsocioid>0 then
       insert into avales(prestamoid,
                        socioid,
                        sujetoid,
                        porcentajeavala,
                        relacionconsocio,
                        noaval,
                        solicitudprestamoid)
        values( pprestamoid,
              lsocioid,
              psujetoid,
              pporcentajeavala,
              prelacionconsocio,
              pnoaval,
              psolicitudprestamoid);
     else
       insert into avales(prestamoid,
                        socioid,
                        sujetoid,
                        porcentajeavala,
                        relacionconsocio,
                        noaval,
                        solicitudprestamoid)
        values( pprestamoid,
              psocioid,
              psujetoid,
              pporcentajeavala,
              prelacionconsocio,
              pnoaval,
              psolicitudprestamoid);
     end if;
     return currval('avales_avalid_seq');
   else

     
     update avales
        set prestamoid=pprestamoid,
            porcentajeavala=pporcentajeavala,
            relacionconsocio=prelacionconsocio,
            noaval=pnoaval
      where avalid=laval;

      lavalid:=laval;
   end if;


return lavalid;
end
---fin de validacion del proveedor del sistema-------------------------------------------------------------------------------
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.spiaval(integer, integer, integer, numeric, character varying, integer, integer, integer) OWNER TO sistema;
