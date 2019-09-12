CREATE or replace FUNCTION spiprestamoscas(character, numeric, numeric, integer, date, date, character, numeric, numeric, integer, integer, integer, integer, date, character, numeric, character, character, character, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, date, character, numeric, integer, numeric, integer) RETURNS integer
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

 ftotalreci numeric;
 recipro numeric;
 
begin

  select clavesocioint,tiposocioid,estatussocio
    into sclavesocioint,stiposocioid,iestatussocio
    from socio
   where socioid=psocioid; 

if psujetoid>0 then
   insert into prestamos(referenciaprestamo, montoprestamo, saldoprestamo, numero_de_amor, fecha_otorga, fecha_vencimiento, tipoprestamoid, tasanormal, tasa_moratoria, socioid, dias_de_cobro, meses_de_cobro, dia_mes_cobro, fecha_1er_pago, clavegarantia, monto_garantia, claveestadocredito, usuarioid, clavefinalidad, calculonormalid, calculomoratorioid, fechaultimopago,solicitudprestamoid,norenovaciones,clasificacioncreditoid,tipoacreditadoid,ahorrocompromiso)
    values( preferenciaprestamo,pmontoprestamo, pmontoprestamo, pnumero_de_amor, pfecha_otorga, pfecha_vencimiento, ptipoprestamoid, ptasanormal, ptasa_moratoria, psocioid, pdias_de_cobro, pmeses_de_cobro, pdia_mes_cobro, pfecha_1er_pago, pclavegarantia, pmonto_garantia, '001', pautorizaprestamo, pfinalidadprestamo, pcalculonormalid, pcalculomoratorioid, pfecha_otorga,psolicitudprestamoid,pnorenovaciones,pclasificacioncreditoid,ptipoacreditadoid,pahorrocompromiso);
else
   insert into prestamos(referenciaprestamo, montoprestamo, saldoprestamo, numero_de_amor, fecha_otorga, fecha_vencimiento, tipoprestamoid, tasanormal, tasa_moratoria, socioid, dias_de_cobro, meses_de_cobro, dia_mes_cobro, fecha_1er_pago, clavegarantia, monto_garantia, claveestadocredito, usuarioid, clavefinalidad, calculonormalid, calculomoratorioid, fechaultimopago,solicitudprestamoid,norenovaciones,clasificacioncreditoid,tipoacreditadoid,ahorrocompromiso)
    values( preferenciaprestamo,pmontoprestamo, pmontoprestamo, pnumero_de_amor, pfecha_otorga, pfecha_vencimiento, ptipoprestamoid, ptasanormal, ptasa_moratoria, psocioid, pdias_de_cobro, pmeses_de_cobro, pdia_mes_cobro, pfecha_1er_pago, pclavegarantia, pmonto_garantia, '001', pautorizaprestamo, pfinalidadprestamo, pcalculonormalid, pcalculomoratorioid, pfecha_otorga,psolicitudprestamoid,pnorenovaciones,pclasificacioncreditoid,ptipoacreditadoid,pahorrocompromiso);
end if;

 --  raise exception 'Llega bien al alta';         
return currval('prestamos_prestamoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;