CREATE or replace FUNCTION spimovibanco(character, integer, character, integer, integer, character, character, character, character, character, date, character, integer, integer) RETURNS integer
    AS $_$
declare
   ptipomovibancoid alias for $1;
   pprestamoid      alias for $2;
   pno_cuenta       alias for $3;
   ppolizaid        alias for $4;
   pconsecutivo     alias for $5;
   pserie	    alias for $6;
   preferenciamovi  alias for $7;
   pconcepto	    alias for $8;
   pbeneficiario    alias for $9;
   pconciliado      alias for $10;
   pfecha_pen       alias for $11;
   ppostfechado     alias for $12;
   pmovipolizaid    alias for $13;
   pprocampoid      alias for $14;

   lconsecutivo integer;
   ldebe numeric;
   lhaber numeric;
   sreferenciaprestamo char(18);
   fmontoprestamo numeric;
   ftipoprestamo  char(3);
   activoprestamo numeric;

   l integer;

   irepetido int4;

begin


   if ptipomovibancoid='02' then    

     -- Incrementar Consecutivo de cheque
     update bancos
        set nocheque=nocheque+1
      where no_cuenta=pno_cuenta;

   end if;

     -- Verificar que no hay sido retirado con RM

     select count(p.*) into irepetido
       from movicaja m, polizas p
      where m.prestamoid=pprestamoid and
            m.tipomovimientoid='RM' and
            p.polizaid=m.polizaid and
            substr(p.concepto_poliza,1,9)<>'CANCELADO';

     irepetido:=coalesce(irepetido,0);

     if irepetido>0 then
       raise exception 'El prestamo ya fue retirado en caja';
     end if;


   select coalesce(max(consecutivo)+1,1)
     into lconsecutivo
     from movibanco
    where serie=pserie;

   insert into movibanco(tipomovibancoid,prestamoid,no_cuenta,polizaid,consecutivo,
                         serie,referenciamovi,concepto,beneficiario,conciliado,
                         fecha_pen,postfechado,movipolizaid,procampoid)
    values(ptipomovibancoid,pprestamoid,pno_cuenta,ppolizaid,lconsecutivo,
           pserie,preferenciamovi,pconcepto,pbeneficiario,pconciliado,
           pfecha_pen,ppostfechado,pmovipolizaid,pprocampoid);

   -- Actualizar el saldo del banco
   -- Recalculandolo completamente
   --select recalculasaldo(pno_cuenta) into l;

   select debe,haber
     into ldebe,lhaber
     from movipolizas where movipolizaid=pmovipolizaid;

   update bancos
      set saldo_actual = saldo_actual + ldebe - lhaber
    where no_cuenta=pno_cuenta;

   -- Validar el total del activo prestamo

   if pprestamoid is not null then

     select referenciaprestamo,montoprestamo,trim(tipoprestamoid) into sreferenciaprestamo,fmontoprestamo,ftipoprestamo from prestamos where prestamoid=pprestamoid;

     select sumaactivoprestamo into activoprestamo from sumaactivoprestamo(sreferenciaprestamo );

     raise notice ' %   %   ',activoprestamo,fmontoprestamo;

     if  activoprestamo > fmontoprestamo then 
		if ftipoprestamo<>'LN' then
			raise exception 'La suma del registro en activo es > monto del prestamo';
		end if;
     end if;

   end if;

return currval('movibanco_movibancoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;