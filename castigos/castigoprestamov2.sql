--alter table autorizabonificacion add referenciaprestamo character(18);

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
  scuentaintdevnocobres char(24);
  scuentaordeninteres char(24);
  sordeninteresacreedor char(24);
  scuentaintnormalvencida char(24);
  smoravencidobalance char(24);
  
  susuarioid1 char(20);
  scuentacaja char(24);
  
  
  scuentaretiro char(24);
  
  stipoprestamoid char(3);
  ispiprestamoscas integer;

  ppolizaid int4;
  pmovipolizaidcaja int4;
  pmovipolizaid int4;
  pmovipolizaid1 int4;
  pmovipolizaid2 int4;
  pmovipolizaid3 int4;
  pmovipolizaid4 int4;
  pmovipolizaid5 int4;
  pmovipolizaid6 int4;
  pmovipolizaid7 int4;
  pmovipolizaid8 int4;
  pmovipolizaid9 int4;
  pmovipolizaid10 int4;
  pmovipolizaid11 int4;
  pmovipolizaid12 int4;
  pmovipolizaid13 int4;
  pmovipolizaid14 int4;
  pmovipolizaid15 int4;
  
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
  finteresmayor90d numeric;
  finteresmenor90d numeric;
  fiva numeric;
  fmoratorio numeric;
  finormal numeric;
  fimoratorio numeric;
  ftotalhaberes numeric;
  giva numeric;
  fivaaplicado  numeric;
  finteresaplicado  numeric; 
  fmoraaplicado numeric; 
  fivamoraaplicado numeric; 
  fcapitalaplicado numeric;
  dultimocierre date;
  xinteresdevmormenor numeric;
  xinteresdevengadomenoravencido numeric;
begin

  select iva into giva from empresa;
  
  pfecha:=current_date;
  susuarioid1:='castigos';
  
  select  p.montoprestamo-sum(m.haber) into fcapital  from prestamos p, tipoprestamo tp, movicaja mc, movipolizas m where p.prestamoid = pprestamoid and tp.tipoprestamoid = p.tipoprestamoid and mc.prestamoid = p.prestamoid and m.polizaid = mc.polizaid and m.cuentaid = tp.cuentaactivo group by p.saldoprestamo,p.montoprestamo;

  fcapital:=coalesce(fcapital,(select montoprestamo from prestamos where prestamoid = pprestamoid));
  
  select interes,moratorio,iva into finteres,fmoratorio,fiva from spscalculopago(pprestamoid);
 
  if fcapital=0 then
     raise exception 'El crédito no tiene adeudo de capital';
  end if;
        
  select referenciaprestamo,tipoprestamoid,socioid,fechaultimopago,montoprestamo into sreferenciaprestamo,stipoprestamoid,lsocioid,dfechaultimopago,pmontoprestamo from prestamos where prestamoid=pprestamoid;

  pcapitalpagado:=pmontoprestamo-fcapital;
  
  select cuentaactivo,cuentariesgocred,cuentaintnormal,cuentaintmora,cuentaiva,OrdenDeudorNormalBonificado,OrdenAcredorNormalBonificado,CuentaIntMoraDevNoCobRes,CuentaIntMoraNoCobAct,cuentaintdevnocobres,cuentaordeninteres,ordeninteresacreedor,cuentaintnormalvencida,moravencidobalance into scuentaactivo,scuentariesgocred,scuentaintnormal,scuentaintmora,scuentaiva,scuentadeudornormal,scuentaacrenormal,scuentadeudormora,scuentaacremora,scuentaintdevnocobres,scuentaordeninteres,sordeninteresacreedor,scuentaintnormalvencida,smoravencidobalance from tipoprestamo where tipoprestamoid = stipoprestamoid;
  
  select serie_user,cuentacaja into pserie_user,scuentacaja from parametros where usuarioid=susuarioid1;   

--Realizar el retiro de haberes y cubrir el capital
select *
    into pnumero_poliza,preferencia
    from rconspoliza(cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),'D',pserie_user,'A');
    
 
-- ********************* Encabezado de la poliza 1 ***************************** --
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','CASTIGO DE PRESTAMO:'||sreferenciaprestamo,pfecha);
	

select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
     where seriecaja = pserie_user;

    lreferenciacaja := lreferenciacaja+1;   
	
 	select sum(saldo) into  ftotalhaberes from spssaldosmov(lsocioid);
	
	

	
	if ftotalhaberes > fcapital+finteres+fiva+fmoratorio then
		raise exception 'Los haberes del Socio son mayores a su adeudo';
	end if;
	
	raise notice 'Voy a retirar haberes'; 
     finteresaplicado:=0;
     fmoraaplicado:=0;
    -- Retirar Haberes
	if ftotalhaberes>0 then
		for r in SELECT * FROM spssaldosmov(lsocioid) where saldo > 0
		loop
			if r.tipomovimientoid = 'IN' then
				raise exception 'Retire las inversiones del socio antes de castigar';
			end if;
			
			if r.saldo>0 then 
				select cuentaretiro into scuentaretiro from tipomovimiento where tipomovimientoid = r.tipomovimientoid;
			
				select * into pmovipolizaidcaja
					from spimovipoliza(ppolizaid,scuentacaja,' ','A',0,r.saldo,' ',' ','CASTIGO PRESTAMO '||r.tipomovimientoid);
				
				select * into pmovipolizaid1
					from spimovipoliza(ppolizaid,scuentaretiro,' ','A',r.saldo,0,' ',' ','CASTIGO PRESTAMO '||r.tipomovimientoid);
				
				--Realizar los Movimientos de Caja
				select * into pmovicajaid
					from spimovicajaseguro(lsocioid,r.tipomovimientoid,ppolizaid,lreferenciacaja,pserie_user,pmovipolizaidcaja,NULL,'A',NULL);
			end if;
		end loop;
		
		if ftotalhaberes < fcapital then
			select * into pmovipolizaidcaja
				from spimovipoliza(ppolizaid,scuentacaja,' ','A',ftotalhaberes,0,' ',' ','CASTIGO PRESTAMO CAP.');
			
			update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaidcaja;
			
			select * into pmovipolizaid2
				from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,ftotalhaberes,' ',' ','CASTIGO PRESTAMO CAP.');
			
			update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid2;
		else
			select * into pmovipolizaidcaja
				from spimovipoliza(ppolizaid,scuentacaja,' ','A',fcapital,0,' ',' ','CASTIGO PRESTAMO CAP.');
			
			update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaidcaja;
			
			select * into pmovipolizaid3
				from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,fcapital,' ',' ','CASTIGO PRESTAMO CAP.');
			
			update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid3;
			
			fivamoraaplicado:=0;	fmoraaplicado:=0;		
			if ftotalhaberes - fcapital - finteres > 0 then --Logra cubrir todo el capital + el interes ord. y parte de moratorio
				fmoraaplicado:=ftotalhaberes - fcapital - finteres;
				if fiva <> 0 then 
				    
				    fivamoraaplicado:=fmoraaplicado-(fmoraaplicado/(1+giva));
				    fmoraaplicado:=fmoraaplicado-fivamoraaplicado;
				else
				    fivaaplicado:=0;
				end if;
				select * into pmovipolizaid4
		  			from spimovipoliza(ppolizaid,scuentaintmora,' ','A',0,fmoraaplicado,' ',' ','CASTIGO PRESTAMO MOR.');
				update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid4;
				select * into pmovipolizaid5
					  from spimovipoliza(ppolizaid,scuentaiva,' ','A',0,fivamoraaplicado,' ',' ','CASTIGO PRESTAMO MOR.');
				update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid5;
			end if;
   			
			if ftotalhaberes - fcapital - fivamoraaplicado - fmoraaplicado > 0 then
				finteresaplicado:= ftotalhaberes - fcapital - fivamoraaplicado - fmoraaplicado;

				if fiva <> 0 then 
				    
				    fivaaplicado:=finteresaplicado-(finteresaplicado/(1+giva));
				    finteresaplicado:=finteresaplicado-fivaaplicado;
				else
				    fivaaplicado:=0;
				end if;
				select * into pmovipolizaid6
		  			from spimovipoliza(ppolizaid,scuentaintnormal,' ','A',0,finteresaplicado,' ',' ','CASTIGO PRESTAMO INT.');
				
				select * into pmovipolizaid7
					  from spimovipoliza(ppolizaid,scuentaiva,' ','A',0,fivaaplicado,' ',' ','CASTIGO PRESTAMO IVA');
			end if;
		end if;
		
	  --Bonificaciones
	  finormal:= finteres-finteresaplicado;
	  raise notice 'finormal %  =  finteres  % - finteresaplicado % ',finormal,finteres,finteresaplicado;
	  fimoratorio := fmoratorio - fmoraaplicado;
	  raise notice 'fimoratorio %  =  fmoratorio  % - fmoraaplicado % ',fimoratorio,fmoratorio,fmoraaplicado;
	  
	  if finormal>0 then
		  select * into pmovipolizaid8
		  from spimovipoliza(ppolizaid,scuentadeudornormal,' ','C',finormal,0,' ',' ','BONIFICACION NORMAL'); 
		  
		  update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid8;
		  
		  select * into pmovipolizaid9
		  from spimovipoliza(ppolizaid,scuentaacrenormal,' ','A',0,finormal,' ',' ','BONIFICACION NORMAL');
		  
		  update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid9;
		  
          end if;

	  if fimoratorio>0 then
		  select * into pmovipolizaid10
		  from spimovipoliza(ppolizaid,scuentadeudormora,' ','C',fimoratorio,0,' ',' ','BONIFICACION MORATORIO');          
		  
		  update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid10;
		  
		  select * into pmovipolizaid11
		  from spimovipoliza(ppolizaid,scuentaacremora,' ','A',0,fimoratorio,' ',' ','BONIFICACION MORATORIO');
		  
		  update movipolizas set prestamoid=pprestamoid where movipolizaid=pmovipolizaid11;
		  
	 end if;
	 
	 --Quitar los intereses ordinarios y moratorios devengados en el desagregado del ultimo cierre (se suspende por que el devengamiento al cierre toma lo anterior, y no deberia si un credito ya se castigó asi se debe quedar)
	 	 
	 --select max(fechacierre) into dultimocierre from precorte; 
	 
	 --select interesdevengadomenoravencido,interesdevmormenor into xinteresdevengadomenoravencido,xinteresdevmormenor from precorte where prestamoid=pprestamoid and fechacierre=dultimocierre;
	 --raise notice 'interesdevengadomenoravencido=%,interesdevmormenor=%',xinteresdevengadomenoravencido,xinteresdevmormenor;
	 
	 --if xinteresdevengadomenoravencido>0 then
		--  select * into pmovipolizaid12
		  --from spimovipoliza(ppolizaid,'51040102',' ','C',xinteresdevengadomenoravencido,0,' ',' ','ORDINARIO DEV VENC');          
		  
		  --select * into pmovipolizaid13
		  --from spimovipoliza(ppolizaid,scuentaintnormalvencida,' ','A',0,xinteresdevengadomenoravencido,' ',' ','ORDINARIO DEV VENC');
		  
	 --end if;
	 
	 --if xinteresdevmormenor>0 then
		  --select * into pmovipolizaid14
		  --from spimovipoliza(ppolizaid,'51040102',' ','C',xinteresdevmormenor,0,' ',' ','MORATORIO DEV VENC');          
		  
		  --select * into pmovipolizaid15
		  --from spimovipoliza(ppolizaid,smoravencidobalance,' ','A',0,xinteresdevmormenor,' ',' ','MORATORIO DEV VENC');
		  
	 --end if;
	 
		select * into pmovicajaid
			from spimovicajaseguro(lsocioid,'00',ppolizaid,lreferenciacaja,pserie_user,pmovipolizaidcaja,pprestamoid,'A',NULL);
			
	end if;		



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
    
 
-- ********************* Encabezado de la poliza 2 ***************************** --
      	--Se vuelve a calcular el capital despues de aplicar los haberes
	  select  p.montoprestamo-sum(m.haber) into fcapitalaplicado  from prestamos p, tipoprestamo tp, movicaja mc, movipolizas m where p.prestamoid = pprestamoid and tp.tipoprestamoid = p.tipoprestamoid and mc.prestamoid = p.prestamoid and m.polizaid = mc.polizaid and m.cuentaid = tp.cuentaactivo group by p.saldoprestamo,p.montoprestamo;

  --Verificar Operacion (saldo del nuevo prestamo calculado)
  pcapitalpagado:= pmontoprestamo - fcapitalaplicado;
  raise notice 'pcapitalpagado  % =  pmontoprestamo % - fcapitalaplicado %',pcapitalpagado,pmontoprestamo,fcapitalaplicado;
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie_user,'A',pnumero_poliza,cast(date_part('year',pfecha) as int),cast(date_part('month',pfecha) as int),' ',pfecha,'D',' ',' ','CASTIGO DE PRESTAMO:'||sreferenciaprestamo,pfecha);
    
-- >>>  Movimientos de la poliza 2 <<<<--  
	
	if fcapitalaplicado > 0 then
		select *
	       into pmovipolizaid
	       from spimovipoliza(ppolizaid,scuentariesgocred,' ','C',fcapitalaplicado,0,' ',' ','CASTIGO PRESTAMO');
	   
		select *
	       into pmovipolizaid2
	       from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,fcapitalaplicado,' ',' ','CASTIGO PRESTAMO');
	end if;

  --Cancelar el credito anterior		
    update prestamos set claveestadocredito='002',saldoprestamo=0 where prestamoid=pprestamoid;

  -- Crear el préstamo con tipo CAS Castigado
  
    for r in select * from prestamos where prestamoid=pprestamoid
    loop

       
          --Agregar las partidas de los intereses y la bonificación 
    
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
                        0,
                        0,
                        r.clasificacioncreditoid,
                        0,
                        r.tipoacreditadoid,
                        null,
                        '',
                        0,
                        0,
                        r.ahorrocompromiso,
                        0);

       end loop;

       for f in select * from amortizaciones  where prestamoid=pprestamoid

       loop

         insert into amortizaciones(prestamoid,numamortizacion, fechadepago,importeamortizacion,interesnormal,saldo_absoluto,interespagado, abonopagado ,ultimoabono,iva,totalpago,ahorro,ahorropagado,cobranza,cobranzapagado,moratoriopagado) values (ispiprestamoscas,f.numamortizacion,f. fechadepago,f.importeamortizacion,f.interesnormal,f.saldo_absoluto,f.interespagado,f. abonopagado ,f.ultimoabono,f.iva,f.totalpago,f.ahorro,f.ahorropagado,f.cobranza,f.cobranzapagado,f.moratoriopagado);

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
     into pmovipolizaid3
     from spimovipoliza(ppolizaid,scuentaactivo,' ','C',pmontoprestamo,0,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid4
     from spimovipoliza(ppolizaid,scuentaactivo,' ','A',0,pcapitalpagado,' ',' ','CARTERA CASTIGADA');

   select *
     into pmovipolizaid5
     from spimovipoliza(ppolizaid,scuentaactivovencida,' ','A',0,pmontoprestamo-pcapitalpagado,' ',' ','CARTERA CASTIGADA');
    
   select coalesce(max(referenciacaja),0)
     into lreferenciacaja
     from movicaja
    where seriecaja = pserie_user;

  lreferenciacaja := lreferenciacaja+1;   

    select *
     into pmovicajaid
     from spimovicajaseguro(lsocioid,'00',ppolizaid,lreferenciacaja,pserie_user,pmovipolizaid5,ispiprestamoscas,'A',NULL);
              
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

   pefectivo:=3;

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
                        0,
                        r.tipoacreditadoid,
                        '',
                        '',
                        0,
                        0,
                        r.ahorrocompromiso,
                        0);

       end loop;

       if swamo=0 then 
          for f in select * from amortizaciones  where prestamoid=pprestamoid

          loop

            insert into amortizaciones(prestamoid,claveestadocredito,numamortizacion, fechadepago,importeamortizacion,interesnormal,saldo_absoluto,interespagado, abonopagado ,ultimoabono,iva,totalpago,ahorro,ahorropagado,seguropagado,cobranza,cobranzapagado,moratoriopagado) values (ispiprestamoscas,f.claveestadocredito,f.numamortizacion,f. fechadepago,f.importeamortizacion,f.interesnormal,f.saldo_absoluto,f.interespagado,f. abonopagado ,f.ultimoabono,f.iva,f.totalpago,f.ahorro,f.ahorropagado,f.seguropagado,f.cobranza,f.cobranzapagado,f.moratoriopagado);

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

