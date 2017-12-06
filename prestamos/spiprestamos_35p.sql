CREATE or replace FUNCTION spiprestamos(character, numeric, numeric, integer, date, date, character, numeric, numeric, integer, integer, integer, integer, date, character, numeric, character, character, character, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, date, character, numeric, integer, numeric, integer) RETURNS integer
    AS $_$
declare

 preferenciaprestamo alias for $1;
 pmontoprestamo      alias for $2;
 psaldoprestamo      alias for $3;
 pnumero_de_amor     alias for $4;
 pfecha_otorga       alias for $5;
 pfecha_vencimiento  alias for $6;
 ptipoprestamoid     alias for $7;
 ptasanormal         alias for $8;
 ptasa_moratoria     alias for $9;
 psocioid            alias for $10;
 pdias_de_cobro      alias for $11;
 pmeses_de_cobro     alias for $12;
 pdia_mes_cobro      alias for $13;
 pfecha_1er_pago     alias for $14;
 pclavegarantia      alias for $15;
 pmonto_garantia     alias for $16;
 pclaveestadocredito alias for $17;
 pautorizaprestamo   alias for $18;
 pfinalidadprestamo  alias for $19;
 pcalculonormalid    alias for $20;
 pcalculomoratorioid alias for $21;
 pessobreprestamo    alias for $22;
 psolicitudprestamoid alias for $23;
 pnorenovaciones     alias for $24;
 pformalizado        alias for $25;
 pcondicionid        alias for $26;
 pclasificacioncreditoid alias for $27;
 psujetoid           alias for $28;
 ptipoacreditadoid   alias for $29;
 pfechavaluaciongarantia alias for $30;
 pprestamodescontado alias for $31;
 pcomision alias for $32;
 ptipocobrocomision alias for $33;
 pahorrocompromiso alias for $34;
 pinteresanticipado alias for $35;
 
 ahorro numeric;
 ahorromin varchar;
 
 prestamossocio integer;
 itantos integer;
 
 stipomovimientoid char(2);
 sreferenciaprestamo char(18);

 lgenero int4;

 sclavesocioint char(15);
 stiposocioid char(2);

 iestatussocio int4; 

 ptasanormal1 numeric;
 ptasa_moratoria1 numeric;

-- Validaciones creditos
   iprestamosgenerados integer;
   fsaldopa numeric;
 
begin

  select clavesocioint,tiposocioid,estatussocio
    into sclavesocioint,stiposocioid,iestatussocio
    from socio
   where socioid=psocioid;


   if pnumero_de_amor=1 and ptipoprestamoid <> 'P1' and ptipoprestamoid <> 'P4' then
      raise exception 'El tipo P1 es el unico que puede ser de 1 amortizacion!';
   end if;

   if iestatussocio=2 then
     raise exception 'No se pueden otorgar prestamos a socios dados de baja !';
   end if;

   if NOT FOUND then
     raise exception 'Clave de socio no encontrada, Verifique este correcta !';
   end if;

   if stiposocioid='01' then
     raise exception 'El socio menor no puede realizar este tipo de movimiento.';
   end if;
---- Validar que el socio tenga su parte social completa

     SELECT coalesce(sum(saldo),0) into fsaldopa FROM spssaldosmov(psocioid) where tipomovimientoid in ('PA');
  if fsaldopa<500 then
  raise exception 'El socio no tiene completa su parte social, verifique!\nSaldo en PA: %',fsaldopa;	
  end if;

--  raise notice 'Solicitud de prestamo con credito duplicado!!!';
--    raise exception 'Ya se ha generado un cr�dito con esta solicitud, verifique!';
--  end if;

	--raise notice 'Saldo en ahorro: %',coalesce(fsaldoahorro,0);

  --raise notice 'Encontrados: %, %.',ptasanormal1,ptasa_moratoria1;
--  select tasanormal,tasamoratoria into ptasanormal1,ptasa_moratoria1 from spstasastipoprestamo(ptipoprestamoid,pmontoprestamo,psocioid,preferenciaprestamo);
  --raise notice 'Encontrados: %, %.',ptasanormal1,ptasa_moratoria1;
--raise exception 'De aqui no pasa!!!';
---

-- Validar duplicidad de generacion de cr�dito
   select count(*) into iprestamosgenerados from prestamos where claveestadocredito<>'008' and solicitudprestamoid=psolicitudprestamoid and tipoprestamoid=ptipoprestamoid;
raise notice 'Encontrados %.',iprestamosgenerados;
  if iprestamosgenerados>0 then
  raise exception 'Solicitud de prestamo con credito duplicado!!!';
--    raise exception 'Ya se ha generado un cr�dito con esta solicitud, verifique!';
  end if;
---

  -- Validar la reciprocidad antes de dar de alta el prestamo

  select referenciaprestamo
    into sreferenciaprestamo
    from prestamos
   where referenciaprestamo=preferenciaprestamo;

  if FOUND then
    raise exception 'Un prestamo con igual referencia ya fue dado de alta, verifique !';
  end if;

  select tantos,tipomovimientoid into itantos,stipomovimientoid
    from tipoprestamo
   where tipoprestamoid=ptipoprestamoid;

  select sum(mp.debe)-sum(mp.haber) into ahorro
    from movicaja mc, movipolizas mp
   where mc.socioid=psocioid and
         mp.movipolizaid=mc.movipolizaid and
         mc.tipomovimientoid=stipomovimientoid;

  ahorro := coalesce(round(ahorro,2),0);

  -- Restar la reciprocidad de prestamos anteriores activos
  -- Pendiente

  ahorro := ahorro - recicreditos(psocioid,stipomovimientoid) + 10;

  if pessobreprestamo=0 then

    -- Verificar la reciprocidad del prestamo
    if (ahorro*itantos)<pmontoprestamo and itantos>0 then
      ahorro := ahorro - 10;
      raise exception 'No cumple con la reciprocidad: Socio=% Ahorro %  Tantos %  Monto=%',sclavesocioint,ahorro,itantos,pmontoprestamo;
    end if;
    
    -- Validar que no tenga mas de 2 presamos activos y que no sean
    select count(*) into prestamossocio
      from prestamos
     where socioid=psocioid and
           saldoprestamo>0 and
           claveestadocredito<>'008';
  end if;

  prestamossocio := coalesce(prestamossocio,0);

  if pessobreprestamo=0 then
    if prestamossocio>=5 then
      raise exception 'El socio tiene % prestamos activos, no se puede otorgar otro prestamo.',prestamossocio;
    end if;
  end if;

  select tasanormal,tasamoratoria into ptasanormal1,ptasa_moratoria1 from spstasastipoprestamo(ptipoprestamoid,pmontoprestamo,psocioid,preferenciaprestamo);
  
  raise notice 'Tasa Normal en funcion Spiprestamos = % %',ptasanormal1,ptasanormal;
  
  ptasanormal1:=coalesce(ptasanormal1,ptasanormal);
  ptasa_moratoria1:=coalesce(ptasa_moratoria1,ptasa_moratoria);

  raise notice 'Tasa Normal en funcion Spiprestamos = % %',ptasanormal1,ptasanormal;
  
if psujetoid>0 then

   insert into prestamos(referenciaprestamo, montoprestamo, saldoprestamo, numero_de_amor, fecha_otorga, fecha_vencimiento, tipoprestamoid, tasanormal, tasa_moratoria, socioid, dias_de_cobro, meses_de_cobro, dia_mes_cobro, fecha_1er_pago, clavegarantia, monto_garantia, claveestadocredito, usuarioid, clavefinalidad, calculonormalid, calculomoratorioid, fechaultimopago,solicitudprestamoid,norenovaciones,formalizado,condicionid,clasificacioncreditoid,sujetoid,tipoacreditadoid,fechavaluaciongarantia,prestamodescontado,comision,tipocobrocomision,ahorrocompromiso,interesanticipado)
    values( preferenciaprestamo,pmontoprestamo, pmontoprestamo, pnumero_de_amor, pfecha_otorga, pfecha_vencimiento, ptipoprestamoid, ptasanormal1, ptasa_moratoria1, psocioid, pdias_de_cobro, pmeses_de_cobro, pdia_mes_cobro, pfecha_1er_pago, pclavegarantia, pmonto_garantia, '001', pautorizaprestamo, pfinalidadprestamo, pcalculonormalid, pcalculomoratorioid, pfecha_otorga,psolicitudprestamoid,pnorenovaciones,pformalizado,pcondicionid,pclasificacioncreditoid,psujetoid,ptipoacreditadoid,pfecha_otorga,pprestamodescontado,pcomision,ptipocobrocomision,pahorrocompromiso,pinteresanticipado);
    
else

   insert into prestamos(referenciaprestamo, montoprestamo, saldoprestamo, numero_de_amor, fecha_otorga, fecha_vencimiento, tipoprestamoid, tasanormal, tasa_moratoria, socioid, dias_de_cobro, meses_de_cobro, dia_mes_cobro, fecha_1er_pago, clavegarantia, monto_garantia, claveestadocredito, usuarioid, clavefinalidad, calculonormalid, calculomoratorioid, fechaultimopago,solicitudprestamoid,norenovaciones,formalizado,condicionid,clasificacioncreditoid,sujetoid,tipoacreditadoid,fechavaluaciongarantia,prestamodescontado,comision,tipocobrocomision,ahorrocompromiso,interesanticipado)
    values( preferenciaprestamo,pmontoprestamo, pmontoprestamo, pnumero_de_amor, pfecha_otorga, pfecha_vencimiento, ptipoprestamoid, ptasanormal1, ptasa_moratoria1, psocioid, pdias_de_cobro, pmeses_de_cobro, pdia_mes_cobro, pfecha_1er_pago, pclavegarantia, pmonto_garantia, '001', pautorizaprestamo, pfinalidadprestamo, pcalculonormalid, pcalculomoratorioid, pfecha_otorga,psolicitudprestamoid,pnorenovaciones,pformalizado,pcondicionid,pclasificacioncreditoid,NULL,ptipoacreditadoid,pfecha_otorga,pprestamodescontado,pcomision,ptipocobrocomision,pahorrocompromiso,pinteresanticipado);
    
end if;
  
  -- Generar las amortizaciones aqui
  select * into lgenero from generaramortizaciones(preferenciaprestamo,0,pfecha_otorga);

--  if psolicitudprestamoid is not null then
   if psolicitudprestamoid>0 then
     update avales
        set prestamoid = (select prestamoid from prestamos where referenciaprestamo=preferenciaprestamo)
      where solicitudprestamoid = psolicitudprestamoid;
   end if;
--  end if;

 --  raise exception 'Llega bien al alta';         
return currval('prestamos_prestamoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;