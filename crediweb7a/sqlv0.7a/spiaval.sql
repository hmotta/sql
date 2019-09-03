
alter table avales add clavesocioint character(15);

update avales set clavesocioint=(select clavesocioint from socio where socioid=avales.socioid) where socioid is not null;


CREATE or replace FUNCTION spiaval(integer, integer, integer, numeric, character varying, integer, integer, integer,character) RETURNS integer
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
  pclavesocioint alias for $9;
  

  avala integer;

  preferenciaprestamo char(18);
  lsocioid int4;

  iavalesc int4;

  snombre char(40);
  spaterno char(20);
  smaterno char(20);
  srfc char(16);


  inoavalesxprestamo int4;
  lavalid int4;

  laval int4;

begin

   select noavalesxprestamo
     into inoavalesxprestamo
    from empresa where empresaid=1;

-- Validar que el aval no se encuentre en mas de 2 prestamos activos

   select count(*) into avala
     from prestamos p,avales a
    where a.sujetoid = psujetoid and
          p.prestamoid = a.prestamoid and
          p.saldoprestamo>0 and
          p.claveestadocredito='001';

   -- Ojo no tomo sobreprestamos
   if pessobreprestamo=0 then   
     avala := coalesce(avala,0);
     if avala>=inoavalesxprestamo then
       raise exception 'El Aval ya avala a % prestamos activos, no se puede ser aval de otro prestamo.',avala;
     end if;

     -- Checar en las demas sucursales
     select nombre,paterno,materno,rfc
       into snombre,spaterno,smaterno,srfc
       from sujeto
      where sujetoid = psujetoid;

     select count(*)
     into iavalesc
     from spsavala(snombre,spaterno,smaterno,srfc);

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
                        solicitudprestamoid,clavesocioint)
        values( pprestamoid,
              lsocioid,
              psujetoid,
              pporcentajeavala,
              prelacionconsocio,
              pnoaval,
              psolicitudprestamoid,pclavesocioint);
     else
       insert into avales(prestamoid,
                        socioid,
                        sujetoid,
                        porcentajeavala,
                        relacionconsocio,
                        noaval,
                        solicitudprestamoid,clavesocioint)
        values( pprestamoid,
              psocioid,
              psujetoid,
              pporcentajeavala,
              prelacionconsocio,
              pnoaval,
              psolicitudprestamoid,pclavesocioint);
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
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE or replace FUNCTION spsavalessolicitud(integer) RETURNS SETOF avales
    AS $_$
declare
  r avales%rowtype;
  pclave alias for $1;
begin


  for r in
    select avalid,prestamoid,socioid,sujetoid,porcentajeavala,relacionconsocio,noaval,
           solicitudprestamoid,clavesocioint
      from avales where solicitudprestamoid=pclave
  loop
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
