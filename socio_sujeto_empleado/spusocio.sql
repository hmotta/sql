drop function spusocio(integer, integer, character, character, date, date, integer, integer, integer);
CREATE FUNCTION spusocio(integer, integer, character, character, date, date, integer, integer, integer) RETURNS integer
    AS $_$
declare

  psocioid alias for $1;
  psujetoid alias for $2;
  ptiposocioid alias for $3;
  pclavesocioint alias for $4;
  pfechaalta alias for $5;
  pfechabaja alias for $6;
  pestatussocio    alias for $7;
  psolicitudingresoid alias for $8;
  pmotivobajaid alias for $9;

  oldestatus int4;
  lsaldo numeric;
  lsaldop numeric;
  itiposocioid int4;

  fsaldoaval numeric;
begin

   select estatussocio,tiposocioid
     into oldestatus,itiposocioid
     from socio
    where socioid=psocioid;

   if oldestatus=1 and pestatussocio=2 and itiposocioid=2 then
     -- Validar que no tenga ni prestamos ni saldos en movimientos
     select saldo into lsaldo
       from spssaldosmov(psocioid)
      where tipomovimientoid<>'PA';

     lsaldo:=coalesce(lsaldo,0);

     if lsaldo>0 then
       raise exception 'El socio debe tener saldos de 0 para poder realizar la BAJA, excepto en Parte Social.';
     end if;

     select sum(saldoprestamo) into lsaldop
       from prestamos
      where socioid=psocioid and claveestadocredito='001' and saldoprestamo>0 and tipoprestamoid<>'CAS';

     lsaldop := coalesce(lsaldop,0);

     if lsaldop>0 then
       raise exception 'El socio no debe tener adeudos de prestamos para realizar la BAJA, Verifiquelo !!!';
     end if;

     fsaldoaval:=0;

     select sum(p.saldoprestamo)
       into fsaldoaval
       from prestamos p, avales a
      where a.socioid=psocioid and
            a.prestamoid is not null and
            p.prestamoid=a.prestamoid and
            p.saldoprestamo>0 and
            p.claveestadocredito<>'008' and
            p.claveestadocredito<>'002';

     fsaldoaval:=coalesce(fsaldoaval,0);
     if fsaldoaval>0 then
        raise exception 'El socio es AVAL de prestamos no liquidados, Verifiquelo !';
     end if;

   end if;


   update socio
    set tiposocioid = ptiposocioid,
        clavesocioint = pclavesocioint,
        fechaalta = pfechaalta,
        fechabaja = pfechabaja,
        estatussocio = pestatussocio,
        --solicitudingresoid = psolicitudingresoid,
        motivobajaid = pmotivobajaid
   where socioid = psocioid;     

return psocioid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;