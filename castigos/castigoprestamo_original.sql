alter table autorizabonificacion add referenciaprestamo character(18);

CREATE or replace FUNCTION  castigoprestamo(integer,character) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  pusuarioid alias for $2;
  
  r record;
  f record;
    
  fcapital numeric;
  pfecha date;
  pnumero_poliza int4;
  preferencia int4;
  pserie_user char(2);
  sreferenciaprestamo char(18);
  scuentaactivo char(24);
  scuentariesgocred char(24);
  scuentaactivovencida char(24);
  scuentaintnormal char(24);
  scuentaintmora char(24);
  scuentaiva char(24);
  scuentadeudornormal char(24);
  scuentaacrenormal char(24);
  scuentadeudormora char(24);
  scuentaacremora char(24);
  
  
  stipoprestamoid char(3);
  ispiprestamoscas integer;

  ppolizaid int4;
  pmovipolizaid int4;
  pmovipolizaid2 int4;
  pmovipolizaid3 int4;
  pmovipolizaid4 int4;
  pmovipolizaid5 int4;
  pmovipolizaid6 int4;
  pmovipolizaid7 int4;
  pmovipolizaid8 int4;
  pmovipolizaid9 int4;
  
  lreferenciacaja integer;
  pmovicajaid int4;
  lsocioid integer;
  dfechaultimopago date;
  pmontoprestamo numeric;
  pcapitalpagado numeric;  

  veint integer;
  veamo integer;

  sreferenciaprestamocas  char(18);

  fcapitalsaldo numeric;
  finteres numeric;
  fiva numeric;
  fmoratorio numeric;
  finormal numeric;
  fimoratorio numeric;
  giva numeric;
   

begin

  select iva into giva from empresa;
  
  pfecha:=current_date;
  
  select  p.montoprestamo-sum(m.haber) into fcapital  from prestamos p, tipoprestamo tp, movicaja mc, movipolizas m where p.prestamoid = pprestamoid and tp.tipoprestamoid = p.tipoprestamoid and mc.prestamoid = p.prestamoid and m.polizaid = mc.polizaid and m.cuentaid = tp.cuentaactivo group by p.saldoprestamo,p.montoprestamo;

  fcapital:=coalesce(fcapital,(select montoprestamo from prestamos where prestamoid = pprestamoid));
  
  select interes,moratorio,iva into finteres,fmoratorio,fiva from spscalculopago(pprestamoid);
 
  if fcapital=0 then
     raise exception 'El crédito no tiene adeudo de capital';
  end if;
        
  select referenciaprestamo,tipoprestamoid,socioid,fechaultimopago,montoprestamo into sreferenciaprestamo,stipoprestamoid,lsocioid,dfechaultimopago,pmontoprestamo from prestamos where prestamoid=pprestamoid;

  pcapitalpagado:=pmontoprestamo-fcapital;
  
  select cuentaactivo,cuentariesgocred,cuentaintnormal,cuentaintmora,cuentaiva,OrdenDeudorNormalBonificado,OrdenAcredorNormalBonificado,CuentaIntMoraDevNoCobRes,CuentaIntMoraNoCobAct into scuentaactivo,scuentariesgocred,scuentaintnormal,scuentaintmora,scuentaiva,scuentadeudornormal,scuentaacrenormal,scuentadeudormora,scuentaacremora from tipoprestamo where tipoprestamoid = stipoprestamoid;
  
  select serie_user into pserie_user from parametros where usuarioid=pusuarioid;   
  -- Aplicar el descuento por el capital a la reserva

  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');
  
  --
  -- Dar de alta la poliza contable
  --

  select *
    into pnumero_poliza,preferencia
    from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');
    
 
-- Encabezado de la poliza

  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','CASTIGO DE PRESTAMO:'||sreferenciaprestamo,pfecha);
    
-- Detalle de la poliza   

	select *
       into pmovipolizaid
       from spimovipoliza(ppolizaid,scuentariesgocred,' ','C',fcapital,0,' ',' ','CASTIGO PRESTAMO');
   
	select *
       into pmovipolizaid2
       from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,fcapital,' ',' ','CASTIGO PRESTAMO');

       
    select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
     where seriecaja = pserie_user;

    lreferenciacaja := lreferenciacaja+1;   

    select *
     into pmovicajaid
     from spimovicajaseguro(lsocioid,'00',ppolizaid,lreferenciacaja,pserie_user,pmovipolizaid,pprestamoid,'A',NULL);

    update prestamos set claveestadocredito='002' where prestamoid=pprestamoid;
              
  -- Crear el préstamo con tipo CAS Castigado
  
    for r in select * from prestamos where prestamoid=pprestamoid
    loop

       if exists (select referenciaprestamo from autorizabonificacion where referenciaprestamo=r.referenciaprestamo) then
       
          select inormal,imoratorio into finormal,fimoratorio from  autorizabonificacion where referenciaprestamo=r.referenciaprestamo;
                              
          raise notice ' % + % + % + % - %',fcapital,finteres,fmoratorio,fiva,finormal;

          finteres:=finteres-finormal;
          fmoratorio:=fmoratorio-fimoratorio;

          if fiva <> 0 then 
            fiva:=(finteres+fmoratorio)*giva;  
          end if;
          
          pmontoprestamo:=fcapital+finteres+fmoratorio+fiva;
          pcapitalpagado:=0;          
          dfechaultimopago:=current_date;

          --Agregar las partidas de los intereses y la bonificación 

          update movipolizas set debe=fcapital+finteres+fmoratorio+fiva where movipolizaid=pmovipolizaid; 
                    
          select * into pmovipolizaid3
          from spimovipoliza(ppolizaid,scuentaintnormal,' ','A',0,finteres,' ',' ','CASTIGO PRESTAMO');
          select * into pmovipolizaid4
          from spimovipoliza(ppolizaid,scuentaintmora,' ','A',0,fmoratorio,' ',' ','CASTIGO PRESTAMO');
          select * into pmovipolizaid5
          from spimovipoliza(ppolizaid,scuentaiva,' ','A',0,fiva,' ',' ','CASTIGO PRESTAMO');
          
          --Bonificaciones
          select * into pmovipolizaid6
          from spimovipoliza(ppolizaid,scuentadeudornormal,' ','C',finormal,0,' ',' ','CASTIGO PRESTAMO');
          select * into pmovipolizaid7
          from spimovipoliza(ppolizaid,scuentaacrenormal,' ','A',0,finormal,' ',' ','CASTIGO PRESTAMO');
          
          select * into pmovipolizaid8
          from spimovipoliza(ppolizaid,scuentadeudormora,' ','C',fimoratorio,0,' ',' ','CASTIGO PRESTAMO');          
          select * into pmovipolizaid9
          from spimovipoliza(ppolizaid,scuentaacremora,' ','A',0,fimoratorio,' ',' ','CASTIGO PRESTAMO');

                    
       end if;
    
       sreferenciaprestamocas:=substring(r.referenciaprestamo||'CAS-',1,18); 

       select spiprestamoscas into ispiprestamoscas from spiprestamoscas(sreferenciaprestamocas,pmontoprestamo,
                        pmontoprestamo,
                        r.numero_de_amor,
                        r.fecha_otorga,
                        r.fecha_vencimiento,
                        'CAS',
                        r.tasanormal,
                        r.tasa_moratoria,
                        lsocioid,
                        r.dias_de_cobro,
                        r.meses_de_cobro,
                        r.dia_mes_cobro,
                        r.fecha_1er_pago,
                        r.clavegarantia,
                        r.monto_garantia,
                        r.claveestadocredito,
                        r.usuarioid,
                        r.clavefinalidad,
                        r.calculonormalid,
                        r.calculomoratorioid,
                        0,
                        r.solicitudprestamoid,
                        r.norenovaciones,
                        r.formalizado,
                        r.condicionid,
                        r.clasificacioncreditoid,
                        r.sujetoid,
                        r.tipoacreditadoid,
                        r.fechavaluaciongarantia,
                        r.prestamodescontado,
                        r.comision,
                        r.tipocobrocomision,
                        r.ahorrocompromiso,
                        r.interesanticipado);

       end loop;

       for f in select * from amortizaciones  where prestamoid=pprestamoid

       loop

         insert into amortizaciones(prestamoid,claveestadocredito,numamortizacion, fechadepago,importeamortizacion,interesnormal,saldo_absoluto,interespagado, abonopagado ,ultimoabono,iva,totalpago,ahorro,seguro,ahorropagado,seguropagado,cobranza,cobranzapagado,moratoriopagado) values (ispiprestamoscas,f.claveestadocredito,f.numamortizacion,f. fechadepago,f.importeamortizacion,f.interesnormal,f.saldo_absoluto,f.interespagado,f. abonopagado ,f.ultimoabono,f.iva,f.totalpago,f.ahorro,f.seguro,f.ahorropagado,f.seguropagado,f.cobranza,f.cobranzapagado,f.moratoriopagado);

       end loop;
       
--Crear la poliza del nuevo credito--
--Dar de alta la poliza contable
--

select cuentaactivo,cuentaactivovencida into scuentaactivo,scuentaactivovencida from tipoprestamo where tipoprestamoid = 'CAS';

  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');
  
-- Encabezado de la poliza

 select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','CASTIGO DE PRESTAMO:'||sreferenciaprestamo,dfechaultimopago);
-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,scuentaactivo,' ','C',pmontoprestamo,0,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,pcapitalpagado,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivovencida,' ','A',0,pmontoprestamo-pcapitalpagado,' ',' ','CARTERA CASTIGADA');
    
   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = pserie_user;

  lreferenciacaja := lreferenciacaja+1;   

    select *
     into pmovicajaid
     from spimovicajaseguro(lsocioid,'00',ppolizaid,lreferenciacaja,pserie_user,pmovipolizaid,ispiprestamoscas,'A',NULL);
              
   select * into veint from verificainterespagado(sreferenciaprestamocas,sreferenciaprestamo);
   select * into veamo from verificaamortizacionpagada(sreferenciaprestamocas);   
     
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


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
   insert into prestamos(referenciaprestamo, montoprestamo, saldoprestamo, numero_de_amor, fecha_otorga, fecha_vencimiento, tipoprestamoid, tasanormal, tasa_moratoria, socioid, dias_de_cobro, meses_de_cobro, dia_mes_cobro, fecha_1er_pago, clavegarantia, monto_garantia, claveestadocredito, usuarioid, clavefinalidad, calculonormalid, calculomoratorioid, fechaultimopago,solicitudprestamoid,norenovaciones,formalizado,condicionid,clasificacioncreditoid,sujetoid,tipoacreditadoid,fechavaluaciongarantia,prestamodescontado,comision,tipocobrocomision,ahorrocompromiso,interesanticipado)
    values( preferenciaprestamo,pmontoprestamo, pmontoprestamo, pnumero_de_amor, pfecha_otorga, pfecha_vencimiento, ptipoprestamoid, ptasanormal, ptasa_moratoria, psocioid, pdias_de_cobro, pmeses_de_cobro, pdia_mes_cobro, pfecha_1er_pago, pclavegarantia, pmonto_garantia, '001', pautorizaprestamo, pfinalidadprestamo, pcalculonormalid, pcalculomoratorioid, pfecha_otorga,psolicitudprestamoid,pnorenovaciones,pformalizado,pcondicionid,pclasificacioncreditoid,psujetoid,ptipoacreditadoid,pfecha_otorga,pprestamodescontado,pcomision,ptipocobrocomision,pahorrocompromiso,pinteresanticipado);
else
   insert into prestamos(referenciaprestamo, montoprestamo, saldoprestamo, numero_de_amor, fecha_otorga, fecha_vencimiento, tipoprestamoid, tasanormal, tasa_moratoria, socioid, dias_de_cobro, meses_de_cobro, dia_mes_cobro, fecha_1er_pago, clavegarantia, monto_garantia, claveestadocredito, usuarioid, clavefinalidad, calculonormalid, calculomoratorioid, fechaultimopago,solicitudprestamoid,norenovaciones,formalizado,condicionid,clasificacioncreditoid,sujetoid,tipoacreditadoid,fechavaluaciongarantia,prestamodescontado,comision,tipocobrocomision,ahorrocompromiso,interesanticipado)
    values( preferenciaprestamo,pmontoprestamo, pmontoprestamo, pnumero_de_amor, pfecha_otorga, pfecha_vencimiento, ptipoprestamoid, ptasanormal, ptasa_moratoria, psocioid, pdias_de_cobro, pmeses_de_cobro, pdia_mes_cobro, pfecha_1er_pago, pclavegarantia, pmonto_garantia, '001', pautorizaprestamo, pfinalidadprestamo, pcalculonormalid, pcalculomoratorioid, pfecha_otorga,psolicitudprestamoid,pnorenovaciones,pformalizado,pcondicionid,pclasificacioncreditoid,NULL,ptipoacreditadoid,pfecha_otorga,pprestamodescontado,pcomision,ptipocobrocomision,pahorrocompromiso,pinteresanticipado);
end if;

 --  raise exception 'Llega bien al alta';         
return currval('prestamos_prestamoid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
CREATE or replace FUNCTION spimovicajaseguro(integer, character, integer, integer, character, integer, integer, character, integer) RETURNS integer
    AS $_$
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

   fdepositoefectivo numeric;
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
      
begin

   select estatussocio,tiposocioid into iestatussocio,stiposocioid
     from socio
    where socioid=psocioid;

  select montopartesocial,partesocialcompleta,ideexento,poride
       into fmontopartesocial,ipartesocialcompleta,fideexento,fporide
       from empresa where empresaid=1;

   select aplicasaldo,aceptadeposito,aceptaretiro
     into saplicasaldo,saceptadeposito,saceptaretiro
     from tipomovimiento where tipomovimientoid=ptipomovimientoid;

   pefectivo:=0;

   insert into movicaja(socioid,tipomovimientoid,polizaid,referenciacaja,seriecaja,movipolizaid,prestamoid,estatusmovicaja,inversionid,saldoactual,efectivo)
   values(psocioid,ptipomovimientoid,ppolizaid,preferenciacaja,pseriecaja,pmovipolizaid,pprestamoid,pestatusmovicaja,pinversionid,fsaldo,pefectivo);

   
return currval('movicaja_movicajaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
	



    

CREATE or replace FUNCTION  castigoprestamo(integer,character,numeric,date) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  pusuarioid alias for $2;
  psaldoprestamo alias for $3;
  pfechapago alias for $4;
  

  r record;
  f record;
    
  fcapital numeric;
  pfecha date;
  pnumero_poliza int4;
  preferencia int4;
  pserie_user char(2);
  sreferenciaprestamo char(18);
  scuentaactivo char(24);
  scuentariesgocred char(24);
  scuentaactivovencida char(24);
  
  stipoprestamoid char(3);
  ispiprestamoscas integer;

  ppolizaid int4;
  pmovipolizaid int4;
  pmovipolizaid2 int4;
  lreferenciacaja integer;
  pmovicajaid int4;
  lsocioid integer;
  dfechaultimopago date;
  pmontoprestamo numeric;
  pcapitalpagado numeric;
  sreferenciaprestamocas  char(18); 

  veint integer;
  veamo integer;
  swamo integer;
  igeneraramortizaciones integer;
  
begin

  pfecha:=current_date;

  select referenciaprestamo,tipoprestamoid,socioid,fechaultimopago,montoprestamo into sreferenciaprestamo,stipoprestamoid,lsocioid,dfechaultimopago,pmontoprestamo from prestamos where prestamoid=pprestamoid;

  
  -- Se cambia esta linea para utilizar el saldo que viene como parametro
  --pcapitalpagado:=pmontoprestamo-fcapital;

  swamo:=0;
  
  if psaldoprestamo > pmontoprestamo then
    pmontoprestamo:=psaldoprestamo;
    pcapitalpagado:=0;
    swamo:=1;
  else
    pcapitalpagado:=pmontoprestamo-psaldoprestamo;
  end if;

  dfechaultimopago:=pfechapago;
  
  
  select cuentaactivo,cuentariesgocred into scuentaactivo,scuentariesgocred from tipoprestamo where tipoprestamoid = stipoprestamoid;
  select serie_user into pserie_user from parametros where usuarioid=pusuarioid;   

 
  -- Crear el préstamo con tipo CAS Castigado
  
    for r in select * from prestamos where prestamoid=pprestamoid
    loop

       sreferenciaprestamocas:=r.referenciaprestamo||'CAS-';
       select spiprestamoscas into ispiprestamoscas from spiprestamoscas(r.referenciaprestamo||'CAS-',pmontoprestamo,
                        psaldoprestamo,
                        r.numero_de_amor,
                        r.fecha_otorga,
                        r.fecha_vencimiento,
                        'CAS',
                        r.tasanormal,
                        r.tasa_moratoria,
                        lsocioid,
                        r.dias_de_cobro,
                        r.meses_de_cobro,
                        r.dia_mes_cobro,
                        r.fecha_1er_pago,
                        r.clavegarantia,
                        r.monto_garantia,
                        '001',
                        r.usuarioid,
                        r.clavefinalidad,
                        r.calculonormalid,
                        r.calculomoratorioid,
                        0,
                        r.solicitudprestamoid,
                        r.norenovaciones,
                        r.formalizado,
                        r.condicionid,
                        r.clasificacioncreditoid,
                        r.sujetoid,
                        r.tipoacreditadoid,
                        r.fechavaluaciongarantia,
                        r.prestamodescontado,
                        r.comision,
                        r.tipocobrocomision,
                        r.ahorrocompromiso,
                        r.interesanticipado);

       end loop;

       if swamo=0 then 
          for f in select * from amortizaciones  where prestamoid=pprestamoid

          loop

            insert into amortizaciones(prestamoid,claveestadocredito,numamortizacion, fechadepago,importeamortizacion,interesnormal,saldo_absoluto,interespagado, abonopagado ,ultimoabono,iva,totalpago,ahorro,seguro,ahorropagado,seguropagado,cobranza,cobranzapagado,moratoriopagado) values (ispiprestamoscas,f.claveestadocredito,f.numamortizacion,f. fechadepago,f.importeamortizacion,f.interesnormal,f.saldo_absoluto,f.interespagado,f. abonopagado ,f.ultimoabono,f.iva,f.totalpago,f.ahorro,f.seguro,f.ahorropagado,f.seguropagado,f.cobranza,f.cobranzapagado,f.moratoriopagado);

          end loop;
       else
           select generaramortizaciones into igeneraramortizaciones from  generaramortizaciones(sreferenciaprestamocas,pcapitalpagado,dfechaultimopago);
       end if;
       
  --Crear la poliza del nuevo credito

--
-- Dar de alta la poliza contable
--

select cuentaactivo,cuentaactivovencida into scuentaactivo,scuentaactivovencida from tipoprestamo where tipoprestamoid = 'CAS';

  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');
  
-- Encabezado de la poliza

 select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','CASTIGO DE PRESTAMO:'||sreferenciaprestamo,dfechaultimopago);
-- Detalle de la poliza

   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,scuentaactivo,' ','C',pmontoprestamo,0,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,pcapitalpagado,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid2
     from spimovipoliza(ppolizaid,scuentaactivovencida,' ','A',0,pmontoprestamo-pcapitalpagado,' ',' ','CARTERA CASTIGADA');
    
   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = pserie_user;

  lreferenciacaja := lreferenciacaja+1;   

    select *
     into pmovicajaid
     from spimovicajaseguro(lsocioid,'00',ppolizaid,lreferenciacaja,pserie_user,pmovipolizaid,ispiprestamoscas,'A',NULL);
              
   --Validar amortizaciones pagadas.
   
   select * into veint from verificainterespagado(sreferenciaprestamocas,sreferenciaprestamo);
   select * into veamo from verificaamortizacionpagada(sreferenciaprestamocas);   
     
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE or replace FUNCTION verificainterespagado(character,character) RETURNS integer
    AS $_$
declare
  preferenciaprestamo alias for $1;
  preferenciaprestamoantes alias for $2;

  fAbono numeric;
  fAplicar numeric;
  amor record;
  pprestamoid int4;
  pprestamoantesid int4;
  
  lsaldoprestamo numeric;

  finteres numeric;
  fintpag numeric;
  
begin

select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo;
select prestamoid into pprestamoantesid from prestamos where referenciaprestamo=preferenciaprestamoantes;

-- Actualizar interes pagado

  select sum(case when m.cuentaid=t.cuentaintnormal then m.haber else 0 end) as interes into finteres from movicaja mc, movipolizas m, prestamos pr,  tipoprestamo t where mc.prestamoid=pprestamoantesid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and t.tipoprestamoid = pr.tipoprestamoid and m.polizaid = mc.polizaid;

  update amortizaciones set interespagado=0 where prestamoid=pprestamoid;

  raise notice ' Interes % prestamoid %',finteres,pprestamoid;

  if finteres > 0 then
    for amor in 
        select *
          from amortizaciones
         where prestamoid=pprestamoid 
      order by fechadepago
    loop

      if finteres > amor.interesnormal then
         update amortizaciones set interespagado=amor.interesnormal 
         where amortizacionid=amor.amortizacionid;
         finteres:=finteres-amor.interesnormal ;
      else
        if finteres > 0 then
          if amor.abonopagado = amor.importeamortizacion then 
          --    update amortizaciones set interesnormal=finteres 
          --   where amortizacionid=amor.amortizacionid;
          end if;
          update amortizaciones set interespagado=finteres 
          where amortizacionid=amor.amortizacionid;
          finteres:=0;
        end if;
      end if;
      --raise notice ' interes % ',finteres;
    end loop;
  end if;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
CREATE or replace FUNCTION verificaamortizacionpagada(character) RETURNS integer
    AS $_$
declare
  preferenciaprestamo alias for $1;

  fAbono numeric;
  fAplicar numeric;
  amor record;
  pprestamoid int4;

  lsaldoprestamo numeric;

  finteres numeric;
  fintpag numeric;
  
begin

select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo;

-- Actualizar interes pagado

  select sum(case when m.cuentaid=t.cuentaactivo then m.haber else 0 end) as interes into finteres from movicaja mc, movipolizas m, prestamos pr,  tipoprestamo t where mc.prestamoid=pprestamoid and mc.tipomovimientoid='00' and pr.prestamoid = mc.prestamoid and t.tipoprestamoid = pr.tipoprestamoid and m.polizaid = mc.polizaid;

  update amortizaciones set abonopagado=0 where prestamoid=pprestamoid;

  raise notice ' Interes % prestamoid %',finteres,pprestamoid;

  if finteres > 0 then
    for amor in 
        select *
          from amortizaciones
         where prestamoid=pprestamoid 
      order by fechadepago
    loop

      if finteres > amor.importeamortizacion then
         update amortizaciones set abonopagado=amor.importeamortizacion 
         where amortizacionid=amor.amortizacionid;
         finteres:=finteres-amor.importeamortizacion ;
      else
        if finteres > 0 then
          if amor.abonopagado = amor.importeamortizacion then 
          --    update amortizaciones set importeamortizacion=finteres 
          --   where amortizacionid=amor.amortizacionid;
          end if;
          update amortizaciones set abonopagado=finteres 
          where amortizacionid=amor.amortizacionid;
          finteres:=0;
        end if;
      end if;
      --raise notice ' interes % ',finteres;
    end loop;
  end if;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

--select * from castigoprestamo(1501,'sopypc');

