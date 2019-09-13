-- ----------------------------
-- Function structure for castigoprestamo
-- ----------------------------
DROP FUNCTION IF EXISTS castigoprestamo(int4, bpchar);
CREATE OR REPLACE FUNCTION castigoprestamo(int4, bpchar)
  RETURNS pg_catalog.int4 AS $BODY$
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

	--Se agrega variable para almacenar si es renovado o normal 29/12/2018
	var_renovado integer;
  
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
  
  ndias_mora integer;
begin
	
	
  select iva into giva from empresa;
  
  pfecha:=current_date;
  susuarioid1:='castigos';
  

select p.montoprestamo-sum(m.haber) into fcapital  from prestamos p, cat_cuentas_tipoprestamo ct, movicaja mc, movipolizas m where p.prestamoid = pprestamoid and (ct.cat_cuentasid = p.cat_cuentasid) and mc.prestamoid = p.prestamoid and m.polizaid = mc.polizaid and m.cuentaid = ct.cuentaactivo group by p.saldoprestamo,p.montoprestamo;

 


  fcapital:=coalesce(fcapital,(select montoprestamo from prestamos where prestamoid = pprestamoid));
  
  select interes,moratorio,iva into finteres,fmoratorio,fiva from spscalculopago(pprestamoid);
  
  --Aqui se guardan los dias de mora antes de pagar el crédito
  select pfecha-min(fechadepago) into ndias_mora from amortizaciones where abonopagado<>importeamortizacion and prestamoid=pprestamoid;
  ndias_mora:=coalesce(ndias_mora,0);
  insert into prestamos_castigados (prestamoid,dias_mora,saldo_capital,int_ordinario,int_moratorio) values (pprestamoid,ndias_mora,fcapital,finteres,fmoratorio);
 
  if fcapital=0 then
     raise exception 'El crédito no tiene adeudo de capital';
  end if;
        
  select referenciaprestamo,tipoprestamoid,socioid,fechaultimopago,montoprestamo into sreferenciaprestamo,stipoprestamoid,lsocioid,dfechaultimopago,pmontoprestamo from prestamos where prestamoid=pprestamoid;

  pcapitalpagado:=pmontoprestamo-fcapital;
	raise notice '** El capital pagado es: pcapitalpagado %  =  pmontoprestamo  % - fcapital % ',pcapitalpagado,pmontoprestamo,fcapital;

  
  
	--Se parametriza las cuentas contables dependiendo si es un crédito renovado o normal
	
		select cuentaactivo,cuentariesgocred,cuentaintnormal,cuentaintmora,cuentaiva,OrdenDeudorNormalBonificado,OrdenAcredorNormalBonificado,CuentaIntMoraDevNoCobRes,CuentaIntMoraNoCobAct,cuentaintdevnocobres,cuentaordeninteres,ordeninteresacreedor,cuentaintnormalvencida,moravencidobalance
		into scuentaactivo,scuentariesgocred,scuentaintnormal,scuentaintmora,scuentaiva,scuentadeudornormal,scuentaacrenormal,scuentadeudormora,scuentaacremora,scuentaintdevnocobres,scuentaordeninteres,sordeninteresacreedor,scuentaintnormalvencida,smoravencidobalance from cat_cuentas_tipoprestamo ct , prestamos pr  where (ct.cat_cuentasid = pr.cat_cuentasid) and pr.prestamoid=pprestamoid;

  
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
	
 	select sum(saldo) into ftotalhaberes from spssaldosmov(lsocioid);
	
	

	
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
		raise notice 'Voy a hacer bonificaciones';
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
	 
	 --Quitar los intereses ordinarios y moratorios devengados en el desagregado del ultimo cierre (se suspende por que el devengamiento al cierre toma lo anterior, y no deberia si un credito ya se castigÃ³ asi se debe quedar)
	 	 
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
	select  p.montoprestamo-sum(m.haber) into fcapitalaplicado  from prestamos p, cat_cuentas_tipoprestamo ct, movicaja mc, movipolizas m where p.prestamoid = pprestamoid and (ct.cat_cuentasid = p.cat_cuentasid) and mc.prestamoid = p.prestamoid and m.polizaid = mc.polizaid and m.cuentaid = ct.cuentaactivo group by p.saldoprestamo,p.montoprestamo;




raise notice '**Consulta de saldo después de aplicar haberes';
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

  -- Crear el prÃ©stamo con tipo CAS Castigado
  
    for r in select * from prestamos where prestamoid=pprestamoid
    loop

       
          --Agregar las partidas de los intereses y la bonificaciÃ³n 
    
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

select cuentaactivo,cuentaactivovencida into scuentaactivo,scuentaactivovencida from cat_cuentas_tipoprestamo ct, prestamos pr where ct.cat_cuentasid = pr.cat_cuentasid and pr.prestamoid=pprestamoid;

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
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;