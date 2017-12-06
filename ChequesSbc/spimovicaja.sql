CREATE OR REPLACE FUNCTION spimovicaja(integer, character, integer, integer, character, integer, integer, character, integer, integer, numeric)
  RETURNS integer AS
$BODY$
declare
   psocioid          alias for $1;	
   ptipomovimientoid alias for $2;
   ppolizaid         alias for $3;
   preferenciacaja   alias for $4;
   pseriecaja        alias for $5;
   pmovipolizaid     alias for $6;
   pprestamoid       alias for $7;
   pestatusmovicaja  alias for $8;
   pinversionid      alias for $9;
   pcontratoid       alias for $10;
   pautorizacionid   alias for $11;

 
   fprestamos numeric;
   fretiro numeric;
   fdeposito numeric;
   fsaldo  numeric;

   iestatussocio int;

   saplicasaldo char(1);
   saceptadeposito char(1);
   saceptaretiro   char(1);

   stiposocioid char(2);

   fmontopartesocial numeric;
   fsaldopa numeric;
   ipartesocialcompleta int4;
  
   lsocioid int4;

   irepetido int4;

-- IDE

   isabana integer;
   susuarioid char(20);
      

   fsumaefectivo numeric;
   psaldo numeric;
   pefectivo integer;

   pfecha date;

   scuentacaja char(24);
   scuentadeposito char(24);

   pnumero_poliza int4;
   preferencia int4;

   lreferenciacaja int4;

   ppolizaid1 int4;
   pmovipolizaid1 int4;
   pmovipolizaid2 int4;
   fideexento numeric;
   fporide numeric;

   fdepositoefectivo numeric;
   fretiroefectivo numeric;
   fsaldoformacion numeric;
   ptipomovimientoret char(2);
   fdepaplicar numeric;
   iautorizacionid integer;
   imovicajaid integer;
   lExisteRMoCH numeric;
   lMontoPrestamo numeric;
   lExisteIDE numeric;
   lNuevoIDE numeric;
   lCountIDE integer;
   lSumIDE numeric;
   lNumPoliza integer;
   lSumDeposito numeric;
   rmov record;

   --Bancos
   snocta char(20);
   scuentabanco char(24);
   sno_cuenta char(20);

   
begin



-- if (select lastupdate from solicitudingreso where socioid=psocioid) < (current_date - 180 ) then
--   raise exception 'Verifique el expediente del socio, tiene 6 meses sin actualizar.';
-- end if;


   if ptipomovimientoid='00' then
     -- Validar que el prestamo corresponda al socio

     select socioid into lsocioid
       from prestamos where prestamoid=pprestamoid;
     if lsocioid<>psocioid then
       raise exception 'Verifique el prestamo no corresponde al socio !!!';
     end if;
   end if;


   if ptipomovimientoid='IN' then
     -- Validar que la inversion corresponda al socio

     select socioid into lsocioid
       from inversion where inversionid=pinversionid;
     if lsocioid<>psocioid then
       raise exception 'Verifique la inversion no corresponde al socio !!!';
     end if;

   end if;

   select estatussocio,tiposocioid into iestatussocio,stiposocioid
     from socio
    where socioid=psocioid;

  select montopartesocial,partesocialcompleta,ideexento,poride
       into fmontopartesocial,ipartesocialcompleta,fideexento,fporide
       from empresa where empresaid=1;

   if stiposocioid='02' and
      (ptipomovimientoid<>'00' and ptipomovimientoid<>'PA' and
       ptipomovimientoid<>'RE' and ptipomovimientoid<>'CH' and
       ptipomovimientoid<>'MG' and ptipomovimientoid<>'BS') then


     if ipartesocialcompleta=1 then
       -- Validar que tenga la parte social
       select sum(mp.debe)-sum(mp.haber) into fsaldopa
         from movicaja mc, movipolizas mp
        where mc.socioid=psocioid and
              mc.tipomovimientoid='PA' and
              mp.movipolizaid=mc.movipolizaid;
       fsaldopa:=coalesce(fsaldopa,0);

       if fsaldopa<fmontopartesocial then
         raise exception 'El socio no tiene cubierta su parte social';
       end if;
     end if;
   end if;

   select aplicasaldo,aceptadeposito,aceptaretiro
     into saplicasaldo,saceptadeposito,saceptaretiro
     from tipomovimiento where tipomovimientoid=ptipomovimientoid;


   if stiposocioid='01' and
      (ptipomovimientoid='00') then
       raise exception 'El socio menor no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   if stiposocioid='03' and
      (ptipomovimientoid<>'AS') then
       raise exception 'El socio aspirante no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   select sum(p.saldoprestamo/tp.tantos) into fprestamos
    from prestamos p, tipoprestamo tp
   where p.socioid = psocioid and
         p.saldoprestamo>0 and
         tp.tipoprestamoid = p.tipoprestamoid and
         tp.tipomovimientoid = ptipomovimientoid and
         tp.tantos>0 and
         p.claveestadocredito<>'008';

   select debe,haber into fdeposito,fretiro
    from movipolizas
   where movipolizaid=pmovipolizaid;

--   if iestatussocio=1 and ptipomovimientoid='PA' and fretiro>0 then
--     raise exception 'El socio debe pasar primeramente a informaciÃ?Â³n a realizar su BAJA Antes de realizar el retiro de su PARTE SOCIAL';
--   end if;

   fdeposito := coalesce(fdeposito,0);
   fretiro := coalesce(fretiro,0);

   fprestamos := coalesce(fprestamos,0);

   -- Validar que el tipo de movimiento acepte el deposito o el retiro
   if fdeposito>0 and saceptadeposito='N' then
     raise exception 'En este tipo de movimiento % no se pueden realizar depositos.',ptipomovimientoid;
   end if;
   if fretiro>0 and saceptaretiro='N' then
     raise exception 'En el tipo de movimiento % no se pueden realizar retiros.',ptipomovimientoid;
   end if;


   -- Validar que no retire mas de lo que tiene en Saldo
   select sum(mp.debe)-sum(mp.haber) into fsaldo
     from movicaja mc, movipolizas mp
    where mc.socioid=psocioid and
          mc.tipomovimientoid=ptipomovimientoid and
          mp.movipolizaid=mc.movipolizaid;

   fsaldo:=coalesce(fsaldo,0);

   if saplicasaldo='S' and
      fretiro>fsaldo and
      ptipomovimientoid<>'IN' and
      ptipomovimientoid<>'RM' and
      ptipomovimientoid<>'RE' then
      raise exception 'El socio no puede retirar mas de su Saldo.';
   end if; 

  
   --- Validaciones Calero

      select sum(mp.debe)-sum(mp.haber) into fsaldopa
         from movicaja mc, movipolizas mp
        where mc.socioid=psocioid and
              mc.tipomovimientoid='PA' and
              mp.movipolizaid=mc.movipolizaid;
       fsaldopa:=coalesce(fsaldopa,0);

  if fretiro>0 and ptipomovimientoid='PA' and psocioid in (select socioid from prestamos where socioid=psocioid and claveestadocredito='001') then 
       raise exception 'No se pueden hacer Retiros de Parte Social a socios con prestamos activos';
  end if;

  if ptipomovimientoid='PA' and fsaldopa + fdeposito > fmontopartesocial then
       raise exception 'No se pueden depositar mas de lo establecido en Parte Social';
    end if;
    
   -- Validar la promocion
   if not validapromocion(psocioid,ptipomovimientoid,fretiro) then
     raise exception 'El socio no pude realizar retiro por que esta en una promociÃ?Â?Ã?Â³n';
   end if;

   if iestatussocio=2 and ptipomovimientoid<>'PA' and fsaldo = 0 then
     raise exception 'No se pueden realizar movimientos en socios dados de BAJA.';
   end if;

   if stiposocioid='01' and (ptipomovimientoid='AA'  or  ptipomovimientoid='PA' or ptipomovimientoid='CU') then
     raise exception 'El socio menor no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   if stiposocioid='02' and ptipomovimientoid='AM' then
     raise exception 'El socio mayor no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   if stiposocioid='03' and (ptipomovimientoid='AM' or ptipomovimientoid='AA') then
     raise exception 'El socio aspirante no puede realizar el tipo de movimiento %',ptipomovimientoid;
   end if;

   -- Verificar el retiro de interes al ahorro
   if ptipomovimientoid='IA' and fretiro>0 and fretiro<>fsaldo then
     raise exception 'El interes al ahorro debe ser retirado en su totalidad.';
   end if;

   if fprestamos>0 and fretiro>0 then

     if fretiro>fsaldo-fprestamos and ptipomovimientoid<>'IN' and ptipomovimientoid<>'RM' then
        fprestamos:=round(fprestamos,2);
        raise exception 'El socio no puede realizar este tipo de movimiento
        Es garantia de algÃ?Âºn prestamo del socio.  Reciprocidad=%',fprestamos;
     end if;
     
   end if;

if fsaldo - fretiro < 100 and ptipomovimientoid = 'AA' and iestatussocio=1 and fretiro > 0 then
     raise exception 'El saldo minimo en Ahorro es de 100 pesos, debe darse de baja el socio 
                       Antes de realizar el retiro Total de Ahorro';
end if;

if fsaldo - fretiro < 50 and ptipomovimientoid = 'AM' and iestatussocio=1 and fretiro > 0 then
     raise exception 'El saldo minimo en Ahorro Menor es de 50 pesos, debe darse de baja el socio 
                       Antes de realizar el retiro Total de Ahorro';
end if;

if fsaldo + fdeposito > 6000000 and ptipomovimientoid = 'AA' and iestatussocio=1 then
     raise exception 'Los depositos de Ahorro no pueden ser mayores al 3% de del total de deposito '; 
end if;

if fsaldo + fdeposito > 6000000 and ptipomovimientoid = 'CU' and iestatussocio=1 then
     raise exception 'Los depositos de Cuenta Corriente no pueden ser mayores al 3% del total de deposito '; 
end if;


if fsaldo + fdeposito > 6000000 and ptipomovimientoid = 'AM' and iestatussocio=1 then
     raise exception 'Los depositos de Ahorro Menor no pueden ser mayores al 3% de del total de deposito '; 
end if;

---


   -- Validar que registren la sabana

   select coalesce(count(sabanaid),0) into isabana from sabana where referenciacaja=preferenciacaja and seriecaja = pseriecaja;

   
   if isabana =0 and ptipomovimientoid<>'IN' then   
   --   raise exception 'No se permite registrar movimientos sin llenar la sabana, repita la operacion';
   end if;

   raise notice ' isabana % ',isabana;
   
    --[CONOCER SI SE PAGO CON EFECTIVO]
    IF (fdeposito > 0) THEN
        --Es Deposito
        SELECT ROUND(SUM(valor), 2) INTO fdepositoefectivo
        FROM sabana
        WHERE referenciacaja=preferenciacaja AND 
            seriecaja = pseriecaja AND 
            entradasalida=0 AND 
            denominacionid IN (SELECT denominacionid FROM denominacion WHERE efectivo=1);
        IF (fdepositoefectivo >= fdeposito) THEN
            --Pago con Efectivo
            pefectivo:=1;
        ELSE
            --Pago con cheque y/o transferencia
            pefectivo:=0;
        END IF;
    ELSIF (fretiro > 0) THEN
        --Es Retiro
        SELECT ROUND(SUM(valor), 2) INTO fretiroefectivo
        FROM sabana
        WHERE referenciacaja=preferenciacaja AND 
            seriecaja = pseriecaja AND 
            entradasalida=1 AND 
            denominacionid IN (SELECT denominacionid FROM denominacion WHERE efectivo=1);
        IF (fretiroefectivo >= fretiro) THEN
            --Pago con Efectivo
            pefectivo:=1;
        ELSE
            --Pago con cheque y/o transferencia
            pefectivo:=0;
        END IF;
    END IF;

   insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo,fechahora,contratoid)
   values(psocioid,ptipomovimientoid,ppolizaid,preferenciacaja,pseriecaja,pmovipolizaid,pprestamoid,pestatusmovicaja,pinversionid,fsaldo,pefectivo,current_timestamp,pcontratoid);

   if ptipomovimientoid='SB' then
      if fdeposito > 0 then
         select cuentadeposito into scuentabanco from tipomovimiento where tipomovimientoid='SB';
      else         
         select cuentaretiro into scuentabanco from tipomovimiento where tipomovimientoid='SB';
      end if;      
      update movipolizas set cuentaid=scuentabanco where movipolizaid=pmovipolizaid;

   end if;
    
  
   insert into bitacoraaccesos(clavemodulo,descripcionmodulos,usuarioid,fecha,fechahora,acceso,tipomovimientoid,deposito,retiro)
   values ('CAJA',ptipomovimientoid,susuarioid,current_date,current_timestamp,'S',ptipomovimientoid,fdeposito,fretiro);

   --Movimientos de Bancos.
   if ptipomovimientoid<>'SB' then
     select TRIM(nocta) into snocta from sabana where referenciacaja=preferenciacaja and seriecaja = pseriecaja and denominacionid=16;
     select TRIM(no_cuenta) into sno_cuenta from bancos where no_cuenta=snocta;
     if snocta=sno_cuenta then
	select cuentaid into scuentabanco from bancos where no_cuenta=snocta;
	select cuentacaja into scuentacaja from parametros where serie_user=pseriecaja;
	update movipolizas set cuentaid=scuentabanco where polizaid=ppolizaid and cuentaid=scuentacaja;

     end if;
   end if;
   
   imovicajaid:=currval('movicaja_movicajaid_seq');
   iautorizacionid:=trunc(pautorizacionid);
   update autorizabonificacion set movicajaid=imovicajaid,aplicado=1 where autorizacionid=iautorizacionid;
   
------------------------------------------
    -- Impuesto Deposito en efectivo
    RAISE NOTICE ' Voy a efectuar el ide ';
    -- if saplicasaldo='S' and ptipomovimientoid<>'IN' and ptipomovimientoid<>'RM' and ptipomovimientoid<>'RE' and ptipomovimientoid<>'IP'  and  pefectivo=1 then
    IF ptipomovimientoid IN ((SELECT tipomovimientoid from tipomovimiento where tipomovimientoid NOT IN ('RM','CI','IP','RE') AND aplicasaldo='S') UNION (SELECT (CASE WHEN EXISTS (SELECT socioid FROM datosfiscales WHERE socioid=psocioid) THEN '**' ELSE '**' END) )) AND (pefectivo = 1 OR fdepositoefectivo > 0) AND (fdeposito>0 AND fretiro=0) THEN
    
        --[PENDIENTE]
        --Cancelar polizas IDE cuando se cancelen movimientos de deposito, solo de ser necesario.
        
        --[COMPROBAR SI YA SE COBRO IDE]
        SELECT COALESCE(SUM(mp.debe),0), COUNT(movicajaid)+1 INTO lExisteIDE, lCountIDE
        FROM movicaja mc INNER JOIN movipolizas mp ON mc.movipolizaid=mp.movipolizaid
        WHERE mc.referenciacaja = preferenciacaja AND mc.seriecaja = pseriecaja AND mc.tipomovimientoid = 'ID';
        
        --[OBTENER EL TOTAL DEL DEPOSITO EN EL FOLIO SIN IMPORTAR SI ES EFECTIVO O NO]
        SELECT COALESCE(SUM(mp.debe),0) INTO lSumDeposito
        FROM movicaja mc INNER JOIN movipolizas mp ON mc.movipolizaid=mp.movipolizaid
        WHERE mc.referenciacaja = preferenciacaja AND mc.seriecaja = pseriecaja AND mc.tipomovimientoid NOT IN ('ID','CI','IP','RE');
        
        RAISE NOTICE 'Existe IDE anterior?: $%, En Cuantos Registros?: %, Total en Deposito? %, Por Efectivo? %', lExisteIDE, lCountIDE-1, lSumDeposito, fdepositoefectivo;
        lSumIDE := 0.00;
        IF lExisteIDE > 0 THEN
            FOR rmov IN
                SELECT *
                FROM movicaja mc INNER JOIN movipolizas mp ON mc.movipolizaid=mp.movipolizaid AND mp.debe > 0
                WHERE mc.referenciacaja = preferenciacaja AND mc.seriecaja = pseriecaja AND mc.tipomovimientoid NOT IN ('ID','CI','IP','RE')
                ORDER BY mc.movicajaid
            LOOP
                lNuevoIDE := ROUND(lExisteIDE * (rmov.debe / lSumDeposito), 2);
                RAISE NOTICE 'Movimiento ''%'' con deposito de $% se calcula retenciÃ?Â³n de $%', rmov.tipomovimientoid, rmov.debe, lNuevoIDE;
                
                UPDATE movipolizas 
                SET debe = lNuevoIDE, haber = 0.00 
                WHERE movipolizaid = (SELECT movipolizaid FROM movicaja WHERE movicajaid = rmov.movicajaid + 1) + 0;
                UPDATE movipolizas 
                SET debe = 0.00, haber = lNuevoIDE
                WHERE movipolizaid = (SELECT movipolizaid FROM movicaja WHERE movicajaid = rmov.movicajaid + 1) + 1;
                UPDATE movipolizas 
                SET debe = 0.00, haber = lNuevoIDE
                WHERE movipolizaid = (SELECT movipolizaid FROM movicaja WHERE movicajaid = rmov.movicajaid + 1) + 2;
                UPDATE movipolizas 
                SET debe = lNuevoIDE, haber = 0.00 
                WHERE movipolizaid = (SELECT movipolizaid FROM movicaja WHERE movicajaid = rmov.movicajaid + 1) + 3;
                
                lSumIDE := lSumIDE + lNuevoIDE;
            END LOOP;
        ELSE
            lNuevoIDE := 0.00;
        END IF;
    
        select fechapoliza into pfecha from polizas where polizaid=ppolizaid;
        select cuentacaja into scuentacaja from parametros where serie_user=pseriecaja;
        select sumadepositos into fsumaefectivo from sumadepositos(ptipomovimientoid,pfecha,psocioid);
     
        if fsumaefectivo > fideexento then
            psaldo := 0.00;
            --if fsumaefectivo-fdeposito > fideexento then 
            IF fsumaefectivo-fdepositoefectivo > fideexento THEN
                --psaldo := fdeposito * fporide;
                psaldo := ROUND(fdepositoefectivo * fporide, 2);
            ELSE
                psaldo := ROUND((fsumaefectivo-fideexento) * fporide, 2);
            END IF;

            IF lNuevoIDE > 0 THEN
                IF lSumIDE = lExisteIDE THEN
                    psaldo := lNuevoIDE;
                ELSE
                    psaldo := lNuevoIDE + (lExisteIDE - lSumIDE);
                END IF;
            ELSE
                RAISE NOTICE 'IDE Calculado en Todo el Folio: $%', psaldo;
            END IF;

            --
            -- Dar de alta la poliza contable para el IDE
            --
            select fechapoliza into pfecha from polizas where polizaid=ppolizaid;
            select cuentacaja into scuentacaja from parametros where serie_user=pseriecaja;
            select cuentadeposito into scuentadeposito from tipomovimiento where tipomovimientoid='ID';

            select *
            into pnumero_poliza,preferencia
            from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pseriecaja,'A');

            -- Encabezado de la poliza
            select * 
            into ppolizaid1
            from spipolizasfecha(preferencia,pseriecaja,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','IMPUESTO DEPOSITOS EN EFECTIVO',pfecha);

            -- Detalle de la poliza
            select *
            into pmovipolizaid1
            from spimovipoliza(ppolizaid1,scuentacaja,' ','C',psaldo,0,' ',' ','IDE');

            select *
            into pmovipolizaid2
            from spimovipoliza(ppolizaid1,scuentadeposito,' ','A',0,psaldo,' ',' ','IDE');

            insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo)
            values(psocioid,'ID',ppolizaid1,preferenciacaja,pseriecaja,pmovipolizaid1,NULL,pestatusmovicaja,NULL,0,1);

            --
            -- Dar de alta la poliza retiro de caja para el IDE
            --
            IF ptipomovimientoid <> '00' THEN
                SELECT cuentaretiro INTO scuentadeposito FROM tipomovimiento WHERE tipomovimientoid=ptipomovimientoid;
                ptipomovimientoret:=ptipomovimientoid;
            ELSE
                SELECT cuentaretiro,tipomovimientoid INTO scuentadeposito,ptipomovimientoret
                FROM tipomovimiento
                WHERE tipomovimientoid IN 
                     (SELECT tp.tipomovimientoid FROM prestamos p, tipoprestamo tp WHERE p.prestamoid=pprestamoid AND p.tipoprestamoid=tp.tipoprestamoid);
            END IF;
            RAISE NOTICE ' cuenta retiro %  sumadepositos %  ide % ',scuentadeposito,fsumaefectivo,psaldo;

            select *
            into pnumero_poliza,preferencia
            from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pseriecaja,'A');

            -- Encabezado de la poliza
            select * 
            into ppolizaid1
            from spipolizasfecha(preferencia,pseriecaja,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','IMPUESTO DEPOSITOS EN EFECTIVO',pfecha);

            -- Detalle de la poliza
            select *
            into pmovipolizaid1
            from spimovipoliza(ppolizaid1,scuentacaja,' ','A',0,psaldo,' ',' ','IDE');

            select *
            into pmovipolizaid2
            from spimovipoliza(ppolizaid1,scuentadeposito,' ','C',psaldo,0,' ',' ','IDE');

            insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo)
            values(psocioid,ptipomovimientoret,ppolizaid1,preferenciacaja,pseriecaja,pmovipolizaid1,NULL,pestatusmovicaja,NULL,0,1);
        END IF;
    END IF;
   
RETURN CURRVAL('movicaja_movicajaid_seq');


end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
