CREATE OR REPLACE FUNCTION spuprestamos(character, numeric, numeric, integer, date, date, character, numeric, numeric, integer, integer, integer, integer, date, character, numeric, character, character, character, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, date, character, numeric, integer, numeric, integer) RETURNS integer
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
 poperacion          alias for $20;
 pcalculonormalid    alias for $21;
 pcalculomoratorioid alias for $22;
 psolicitudprestamoid alias for $23;
 pnorenovaciones     alias for $24;
 pformalizado        alias for $25;
 pcondicionid        alias for $26;
 pclasificacioncreditoid alias for $27;
 psujetoid            alias for $28;
 ptipoacreditadoid   alias for $29;
 pfechavaluaciongarantia alias for $30;
 pprestamodescontado alias for $31;
 pcomision alias for $32;
 ptipocobrocomision alias for $33;
 pahorrocompromiso alias for $34;
 pinteresanticipado alias for $35;      
 
lamornegativa numeric; 
lamormayorpmonto numeric;
lgenero int4;
 nmontosolicitado numeric;

 ptasanormal1 numeric;
 ptasa_moratoria1 numeric;

 cestadoanterior character(3);
 icontapermis integer;

ngarantiaactual numeric;
ngarantiarequerida numeric;
nsaldoinversion numeric;
 
begin

   -- Validar que ya no se pueda modificar si tiene movimientos
   select count(*)
     into lgenero
     from movicaja
    where prestamoid = poperacion and estatusmovicaja='A';
   

  ----- >> Validar que tenga permiso para cambiar el estado de credito
    select claveestadocredito into cestadoanterior from prestamos where prestamoid=poperacion;
    select count(*) into icontapermis from permisosmodulos where clavemodulo='CEDOCRED' and permiso='S' and usuarioid=pautorizaprestamo;
--    raise notice '-------------Permisos: %, edoant %, edonew %',icontapermis,cestadoanterior,pclaveestadocredito;
    if icontapermis=0 and cestadoanterior <> pclaveestadocredito then 
         raise exception 'No tiene permiso para cambiar el estado del credito!!';
    end if;
  ----- << Validar que tenga permiso para cambiar el estado de credito

   select montosolicitado into nmontosolicitado from solicitudprestamo where solicitudprestamoid=psolicitudprestamoid;

   if nmontosolicitado <> pmontoprestamo and ptipoprestamoid not in ('T1','T2','T3','R1','R2','R3') then
     raise exception 'No se puede realizar cambio en el monto autorizado';
   end if;

   ------- >> Validar la finalidad del prestamo acorde con el tipo de producto [consumo, comercial, vivienda]
   if pfinalidadprestamo='001' then--Comercial
		if ptipoprestamoid not in ('R1','C1','C4','C9','T1') then
			raise exception 'Este tipo de credito no puede ser Comercial';
		end if;
   elseif pfinalidadprestamo='002' then--Consumo
		if ptipoprestamoid not in ('CAS','P4','N8','N20','R2','T2','N1','N4','N15','N21','N9','N16','P1','N13','N14','N7','N22','N5','N53','N54','CF') then
			raise exception 'Este tipo de credito no puede Consumo';
		end if;
   else --vivienda
			raise exception 'Este tipo de credito no puede a la Vivienda';
   end if;
   ------- <<
   
---------- validando garantia este paso se omite debido a que se verificará al momento de la autorizacion del credito.
	raise notice 'validando garantia x';
        select coalesce(sum(saldo),0) into ngarantiaactual from spssaldosmov(psocioid) where tipomovimientoid in ('P3','AA');
		select coalesce(SUM((case when mp.cuentaid=t.cuentapasivo then mp.haber-mp.debe else 0 end)),0) into nsaldoinversion from polizas p, movicaja m, movipolizas mp, inversion i,tipoinversion t where i.socioid=psocioid and i.fechainversion<=current_date and m.inversionid = i.inversionid and p.polizaid = m.polizaid and p.fechapoliza <= CURRENT_DATE and t.tipoinversionid = i.tipoinversionid and mp.polizaid = p.polizaid and i.tipoinversionid in ('PSO','PSV');
		
        select coalesce(sum(monto_garantia),0) into ngarantiarequerida from prestamos where claveestadocredito='001' and clavegarantia='02' and socioid=psocioid;
		raise notice 'Garantia De P3 y AA: %',ngarantiaactual;
		raise notice 'Garantia De PSO: %',nsaldoinversion;
		ngarantiaactual:=ngarantiaactual+nsaldoinversion;
		
        if (pmonto_garantia>(ngarantiaactual-ngarantiarequerida)) and ptipoprestamoid not in ('T1','T2','T3','R1','R2','R3') then
           raise exception 'El saldo en garantia es insuficiente, verifique! Saldo disponible: %',round(ngarantiaactual-ngarantiarequerida,2);
        end if;
---------
	
	if ptipoprestamoid in ('T1','T2','T3') then
		if pclasificacioncreditoid<>3 then	
			raise exception 'La clasifiacion de credito debe ser REESTRUCTURADO';
		end if;
	elseif ptipoprestamoid in ('R1','R2','R3') then
		if pclasificacioncreditoid<>2 then	
			raise exception 'La clasifiacion de credito debe ser RENOVADO';
		end if;
	end if;

   lgenero := coalesce(lgenero,0);
   if lgenero>0 then
     raise exception 'No se pueden realizar cambios en un prestamo que ya realizo movimientos en caja';
   end if;

   if pcalculonormalid in (2,3) then
     raise exception 'No se puede elegir formula: %, verifique!!',(select descripcioncalculo from calculo where calculoid=pcalculonormalid);
   end if;

   select tasanormal,tasamoratoria into ptasanormal1,ptasa_moratoria1 from spstasastipoprestamo(ptipoprestamoid,pmontoprestamo,psocioid,preferenciaprestamo);

   --ptasanormal1:=coalesce(ptasanormal1,ptasanormal);
   --ptasa_moratoria1:=coalesce(ptasa_moratoria1,ptasa_moratoria);



  if psujetoid>0 then
  raise notice 'Updateando referencia %',preferenciaprestamo;
   update prestamos
      set referenciaprestamo = preferenciaprestamo,
          montoprestamo      = pmontoprestamo,
          saldoprestamo      = psaldoprestamo,
          numero_de_amor     = pnumero_de_amor,
          fecha_otorga       = pfecha_otorga,
          fechaultimopago    = pfecha_otorga,
          fecha_vencimiento  = pfecha_vencimiento,     
          tipoprestamoid     = ptipoprestamoid,
          tasanormal         = ptasanormal1,
          tasa_moratoria     = ptasa_moratoria1,
          socioid            = psocioid,
          dias_de_cobro      = pdias_de_cobro,
          meses_de_cobro     = pmeses_de_cobro,
          dia_mes_cobro      = pdia_mes_cobro,
          fecha_1er_pago     = pfecha_1er_pago,
          clavegarantia      = pclavegarantia,
          monto_garantia     = pmonto_garantia,
          claveestadocredito = pclaveestadocredito,
          usuarioid          = pautorizaprestamo,
          clavefinalidad     = pfinalidadprestamo,
          calculonormalid    = pcalculonormalid,
          calculomoratorioid = pcalculomoratorioid,
          solicitudprestamoid = psolicitudprestamoid,
          norenovaciones     = pnorenovaciones,
          formalizado        = pformalizado,
          condicionid        = pcondicionid,
          clasificacioncreditoid = pclasificacioncreditoid,
          sujetoid           = psujetoid,
          tipoacreditadoid   = ptipoacreditadoid,
          fechavaluaciongarantia = pfechavaluaciongarantia,
          prestamodescontado = pprestamodescontado,
          comision = pcomision,
          tipocobrocomision = ptipocobrocomision,
          ahorrocompromiso = pahorrocompromiso,
          interesanticipado = pinteresanticipado

 where prestamoid = poperacion;
  else
  raise notice 'Updateando referencia % nosu',preferenciaprestamo;
   update prestamos
      set referenciaprestamo = preferenciaprestamo,
          montoprestamo      = pmontoprestamo,
          saldoprestamo      = psaldoprestamo,
          numero_de_amor     = pnumero_de_amor,
          fecha_otorga       = pfecha_otorga,
          fechaultimopago    = pfecha_otorga,
          fecha_vencimiento  = pfecha_vencimiento,     
          tipoprestamoid     = ptipoprestamoid,
          tasanormal         = ptasanormal1,
          tasa_moratoria     = ptasa_moratoria1,
          socioid            = psocioid,
          dias_de_cobro      = pdias_de_cobro,
          meses_de_cobro     = pmeses_de_cobro,
          dia_mes_cobro      = pdia_mes_cobro,
          fecha_1er_pago     = pfecha_1er_pago,
          clavegarantia      = pclavegarantia,
          monto_garantia     = pmonto_garantia,
          claveestadocredito = pclaveestadocredito,
          usuarioid          = pautorizaprestamo,
          clavefinalidad     = pfinalidadprestamo,
          calculonormalid    = pcalculonormalid,
          calculomoratorioid = pcalculomoratorioid,
          solicitudprestamoid = psolicitudprestamoid,
          norenovaciones     = pnorenovaciones,
          formalizado        = pformalizado,
          condicionid        = pcondicionid,
          clasificacioncreditoid = pclasificacioncreditoid,
--          sujetoid           = psujetoid,
          tipoacreditadoid   = ptipoacreditadoid,
          fechavaluaciongarantia = pfechavaluaciongarantia,
          prestamodescontado = pprestamodescontado,
          comision = pcomision,
          tipocobrocomision = ptipocobrocomision,
          ahorrocompromiso = pahorrocompromiso,
          interesanticipado= pinteresanticipado
          
 where prestamoid = poperacion;

  end if;

    delete from amortizaciones where prestamoid=poperacion;
    -- Generar las amortizaciones aqui
    select * INTO lgenero
      from generaramortizacionescalculo(preferenciaprestamo,0,pfecha_otorga,pcalculonormalid);
---validar amortizaciones menores a cero
 select importeamortizacion  into lamornegativa from amortizaciones where importeamortizacion<0 and  prestamoid=poperacion;
	   if lamornegativa<0 then 
		raise exception 'El calculo de las amortizaciones tiene valor Negativo!!';
	    end if;
   select sum(importeamortizacion) into lamormayorpmonto from amortizaciones where prestamoid=poperacion;
 	if lamormayorpmonto>pmontoprestamo then 
		raise exception 'El calculo de las amortizaciones no coincide con el total del crédito!!';
    	end if;


    update prestamos set fecha_vencimiento=(select max(am.fechadepago) from amortizaciones am, prestamos pr where pr.prestamoid=am.prestamoid and pr.referenciaprestamo=preferenciaprestamo) where referenciaprestamo=preferenciaprestamo;


return poperacion;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
