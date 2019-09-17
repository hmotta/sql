CREATE OR REPLACE FUNCTION spiprestamos(bpchar, numeric, numeric, int4, date, date, bpchar, numeric, numeric, int4, int4, int4, int4, date, bpchar, numeric, bpchar, int4, int4, int4, int4, int4, int4, numeric)
  RETURNS pg_catalog.int4 AS $BODY$
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
 pautorizaprestamo   alias for $17; 
 pcalculonormalid    alias for $18;
 pcalculomoratorioid alias for $19;
 psolicitudprestamoid alias for $20;
 pnorenovaciones     alias for $21;
 pclavefinalidad alias for $22;
 ptipoacreditadoid   alias for $23;
 pahorrocompromiso alias for $24;
 
 ahorro numeric;
 
 prestamossocio integer;
 itantos integer;
 
 stipomovimientoid char(2);
 sreferenciaprestamo char(18);

 lgenero int4;

 sclavesocioint char(15);
 stiposocioid char(2);

 iestatussocio int4; 
 --icondicionid int4;
 iclasificacioncreditoid int4;
 

-- Validaciones creditos
   iprestamosgenerados integer;
   fsaldopa numeric;
   
   nrenovado integer;
   sreferenciaorigen  char(18);
   ndiasmoraorigen integer;
   
   ncat_cuentasid integer;
   nprestamoid integer;
   ndictaminaid integer;
begin
 --icondicionid:=pcondicionid;
 iclasificacioncreditoid:=pclasificacioncreditoid;
  select clavesocioint,tiposocioid,estatussocio
    into sclavesocioint,stiposocioid,iestatussocio
    from socio
   where socioid=psocioid;


   --if pnumero_de_amor=1 and ptipoprestamoid <> 'P1' and ptipoprestamoid <> 'P4' and ptipoprestamoid <>'N16' then
     -- raise exception 'El tipo P1 es el unico que puede ser de 1 amortizacion!';
   --else
     -- if ptipoprestamoid = 'P4' then
--raise exception 'El tipo P4 patmir debe ser de pago al vencimiento (1 amortizacion)!';
  --end if;
   --end if;
   
    
   if iestatussocio=2 then
	   raise exception 'No se pueden otorgar prestamos a socios dados de baja !';
   end if;

   if NOT FOUND then
     raise exception 'Clave de socio no encontrada, Verifique este correcta !';
   end if;

   if stiposocioid='01' then
     raise exception 'El socio menor no puede realizar este tipo de movimiento.';
   end if;
---- Validar que el socio tenga su parte social completa (se valida en el primer movimiento de caja)

     --SELECT coalesce(sum(saldo),0) into fsaldopa FROM spssaldosmov(psocioid) where tipomovimientoid in ('PA');
  --if fsaldopa<500 then
  --raise exception 'El socio no tiene completa su parte social, verifique!\nSaldo en PA: %',fsaldopa;
  --end if;

--raise notice 'Saldo en ahorro: %',coalesce(fsaldoahorro,0);

  --raise notice 'Encontrados: %, %.',ptasanormal1,ptasa_moratoria1;
--  select tasanormal,tasamoratoria into ptasanormal1,ptasa_moratoria1 from spstasastipoprestamo(ptipoprestamoid,pmontoprestamo,psocioid,preferenciaprestamo);
  --raise notice 'Encontrados: %, %.',ptasanormal1,ptasa_moratoria1;
--raise exception 'De aqui no pasa!!!';
---

  
   
-- Validar duplicidad de generacion de crédito
   select count(*) into iprestamosgenerados from prestamos where claveestadocredito<>'008' and solicitudprestamoid=psolicitudprestamoid and tipoprestamoid=ptipoprestamoid;
raise notice 'Encontrados %.',iprestamosgenerados;
if iprestamosgenerados>0 then
      --raise exception 'Solicitud de prestamo con credito duplicado!!!';
    raise exception 'Ya se ha generado un crédito con esta solicitud, verifique!';
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

  --if pessobreprestamo=0 then

    -- Verificar la reciprocidad del prestamo
--    if (ahorro*itantos)<pmontoprestamo and itantos>0 then
  --    ahorro := ahorro - 10;
    --  raise exception 'No cumple con la reciprocidad: Socio=% Ahorro %  Tantos %  Monto=%',sclavesocioint,ahorro,itantos,pmontoprestamo;
    --end if;
    
    -- Validar que no tenga mas de 2 presamos activos y que no sean
    select count(*) into prestamossocio
      from prestamos
     where socioid=psocioid and
           saldoprestamo>0 and
           claveestadocredito<>'008';
  -- else
--if  pnumero_de_amor=1 then
--icondicionid=1;
--elseif pnumero_de_amor>1 then
--icondicionid=3;
--end if;
--if ptipoprestamoid in ('T1','T2','T3') then
--iclasificacioncreditoid:=3;
--elseif ptipoprestamoid in ('R1','R2','R3') then
--iclasificacioncreditoid:=2;
--end if;
  --end if;

  prestamossocio := coalesce(prestamossocio,0);

 -- if pessobreprestamo=0 then
    if prestamossocio>=5 then
      raise exception 'El socio tiene % prestamos activos, no se puede otorgar otro prestamo.',prestamossocio;
    end if;
  --end if;
   
   -- Obtenemos los parametros de [renovado,referenciaorigen,diasmoraorigen] de la solicitud
   select  renovado,trim(referenciaprestamoorigen),diasmoraorigen into nrenovado,sreferenciaorigen,ndiasmoraorigen from solicitudprestamo where solicitudprestamoid=psolicitudprestamoid;
   
   --Obtenemos las cuentas contables del prestamos que utilizará dependiendo de:
   --[tipoprestamoid,renovado,clasificacion]
   select cat_cuentasid into ncat_cuentasid from cat_cuentas_tipoprestamo where tipoprestamoid=ptipoprestamoid and renovado=nrenovado and clavefinalidad=pclavefinalidad;
   
   insert into prestamos(referenciaprestamo,montoprestamo,saldoprestamo,numero_de_amor,fecha_otorga,fecha_vencimiento,tipoprestamoid,tasanormal,tasa_moratoria,socioid,dias_de_cobro,meses_de_cobro,dia_mes_cobro,fecha_1er_pago,clavegarantia,monto_garantia,usuarioid,calculonormalid,calculomoratorioid,solicitudprestamoid,norenovaciones,clasificacioncreditoid,tipoacreditadoid,ahorrocompromiso,claveestadocredito,clavefinalidad,fechaultimopago,renovado,referenciaprestamoorigen,diasmoraorigen,cat_cuentasid)
    values( preferenciaprestamo,pmontoprestamo,psaldoprestamo,pnumero_de_amor,pfecha_otorga,pfecha_vencimiento,ptipoprestamoid,ptasanormal,ptasa_moratoria,psocioid,pdias_de_cobro,pmeses_de_cobro,pdia_mes_cobro,pfecha_1er_pago,pclavegarantia,pmonto_garantia,pautorizaprestamo,pcalculonormalid,pcalculomoratorioid,psolicitudprestamoid,pnorenovaciones,pclasificacioncreditoid,ptipoacreditadoid,pahorrocompromiso,'001',pclavefinalidad,pfecha_otorga,nrenovado,sreferenciaorigen,ndiasmoraorigen,ncat_cuentasid);
    
	nprestamoid:=currval('prestamos_prestamoid_seq');
	
	--Updeteamos Avales
	update avales set prestamoid = nprestamoid   where solicitudprestamoid = psolicitudprestamoid;
	--Updeteamos Garantias
	update garantiaprendaria  set prestamoid=nprestamoid where solicitudprestamoid=psolicitudprestamoid and aceptada=1;
	update garantiahipotecaria  set prestamoid=nprestamoid  where solicitudprestamoid=psolicitudprestamoid;
	--Updeteamos si tiene liquidacion con otro prestamo
	if nrenovado=1 then
		select dicatminaid into ndictaminaid from dictaminacredito where solicitudprestamoid=psolicitudprestamoid;
		update liquidaconrenovado set nuevoprestamoid=nprestamoid where dictaminaid=ndictaminaid;
	end if;
	
       
return nprestamoid;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER