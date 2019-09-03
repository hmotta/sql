CREATE or replace FUNCTION sprpbalance(integer, integer, integer, integer) RETURNS SETOF rrpbalance
    AS $_$
declare

  pejercicio   alias for $1;
  pperiodo     alias for $2;
  pconsolidado alias for $3;
  pmiles       alias for $4;

  sconsolida char(1);
  r rrpbalance%rowtype;

  daytab numeric[2][12]:=array[[31,28,31,30,31,30,31,31,30,31,30,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31]];
  mestab varchar[13]:=array['ENERO','FEBRERO','MARZO',
                            'ABRIL','MAYO','JUNIO',
                            'JULIO','AGOSTO','SEPTIEMBRE',
                            'OCTUBRE','NOVIEMBRE','DICIEMBRE',
                            'DICIEMBRE'];

  fresultado numeric;
  factivo numeric;
  fpasivo numeric;
  fcapital numeric;
  cf numeric;
  cf2 numeric;
  cf5 numeric;
  cf6 numeric;
  cf7 numeric;
  cf8 numeric;
  
  
  act_dis numeric;
  pcf numeric;
  pas_cap numeric;
  pas_prb numeric;
  act_invv numeric;
  p_otrctasxpag numeric;
  totalcartera numeric;
  carteraneto numeric;
  capitalcontribuido numeric;
  totalactivo numeric;
  resultadoneto numeric;
  resultadonetot numeric;
  capitalcontribuidot numeric;
  

  finversionenvalores numeric;
  fcarteravigente numeric;
  fcarteravencida numeric;
  freserva numeric;

  fcaptacion numeric;
  fprestamosbancarios numeric;
  fotrascxp numeric;

  fcapitalcontribuido numeric;
  fcapitalganado numeric;

  f numeric;

  finvmenor30 numeric;
  pfecha date;
  f1 numeric;
  f2 numeric;

  fcapgan numeric;
begin

  select cast(to_char(pejercicio,'9999')||'-'||trim(to_char(pperiodo,'99'))||'-'||trim(to_char(daytab[1][pperiodo],'99')) as date)
    into pfecha;

  raise notice 'Fecha %',pfecha;

  fresultado:=0;
  factivo:=0;
  fpasivo:=0;
  fcapital:=0;
  freserva:=0;
  cf:=0;

  if pconsolidado=1 then
  	--r.rubro1:='CONSOLIDADO';
    r.rubro1:='';
    --r.rubro2:='D-1 Balance General';
    r.rubro2:='';
    sconsolida:='S';
  else
    --r.rubro1:='SUCURSAL';
    r.rubro1:='';
    --r.rubro2:='D-1 Balance General';
    r.rubro2:='';
    sconsolida:='N';
  end if;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := NULL;
  r.t5 := NULL;
  return next r;

  --select nombrecaja into r.rubro1 from empresa where empresaid=1;
  r.rubro2:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := NULL;
  r.t5 := NULL;
  return next r;

  --select niveloperaciones into r.rubro1 from empresa where empresaid=1;
  r.rubro2:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := NULL;
  r.t5 := NULL;
  return next r;

  --select direccioncaja into r.rubro1 from empresa where empresaid=1;
  r.rubro2:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := NULL;
  r.t5 := NULL;
  return next r;

  -- Pendiente validar aÃ±o bisiesto
  if pconsolidado=1 then
   --r.rubro1:='BALANCE GENERAL CONSOLIDADO AL'||to_char(daytab[1][pperiodo],'99')||' DE '||mestab[pperiodo]||' DE'||to_char(pejercicio,'9999');
   r.rubro1:='';
  else
   --r.rubro1:='BALANCE GENERAL AL'||to_char(daytab[1][pperiodo],'99')||' DE '||mestab[pperiodo]||' DE'||to_char(pejercicio,'9999');
   r.rubro1:='';
  end if;
  r.rubro2:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := NULL;
  r.t5 := NULL;
  return next r;

  --r.rubro1:='EXPRESADO EN MONEDA DE PODER ADQUISITIVO HISTORICO';
  r.rubro1:='';
  r.rubro2:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := NULL;
  r.t5 := NULL;
  return next r;

  if pmiles=1 then
    --r.rubro1:='(CIFRAS EN MILES DE PESOS)';
    r.rubro1:='';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;
  else
    --r.rubro1:='(CIFRAS EN PESOS)';
    r.rubro1:='';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;
  end if;


    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

    --r.rubro1:='ACTIVO';
    r.rubro1:='';
    --r.rubro2:='PASIVO';
    r.rubro2:='';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

    
    act_dis:=saldocuenta('1101 ',pejercicio,pperiodo,sconsolida)+
    		 saldocuenta('1102 ',pejercicio,pperiodo,sconsolida)+
    		 saldocuenta('1103 ',pejercicio,pperiodo,sconsolida)+
    		 saldocuenta('1104 ',pejercicio,pperiodo,sconsolida);
    r.rubro1:='DISPONIBILIDADES';
    r.rubro2:='CAPTACION TRADICIONAL';
    r.t1 := NULL;
    r.t2 := act_dis;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;


	cf:=saldocuenta('1101 ',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	r.rubro1:='Caja';
    r.rubro2:='';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;
    
	cf:=saldocuenta('1102 ',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
    r.rubro1:='Bancos';
    r.rubro2:='Captacion con vencimiento < a 30 dias';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

	cf:=saldocuenta('1103 ',pejercicio,pperiodo,sconsolida)+
		saldocuenta('1104 ',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	
	pcf:=saldocuenta('2101 ',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	
	r.rubro1:='Otras Disponibilidades';
    r.rubro2:='Depositos de exigibilidad inmediata';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := NULL;
    return next r;
  
                    
	pcf:=saldocuenta('2102 ',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	r.rubro1:=NULL;
    r.rubro2:='Depositos a Plazo';
    r.t1 :=  -0.001;  --LINEA DE SUBTOTALES
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := NULL;
    return next r;
    
    act_invv:=saldocuenta('1201 ',pejercicio,pperiodo,sconsolida) +
    		  saldocuenta('1202 ',pejercicio,pperiodo,sconsolida) +
    		  saldocuenta('1203 ',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
		pas_cap:=pas_cap/1000.00;
	end if;
    
    pas_cap:=saldocuenta('2101 ',pejercicio,pperiodo,sconsolida)*-1 +
    		 saldocuenta('2102 ',pejercicio,pperiodo,sconsolida)*-1 +
    		 saldocuenta('2103 ',pejercicio,pperiodo,sconsolida)*-1;
    if pmiles=1 then
		pas_cap:=pas_cap/1000.00;
	end if;
	pcf:=saldocuenta('2103 ',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	
	r.rubro1:='INVERSIONES EN VALORES';
	r.rubro2:='Titulos de creditos emitidos';
	r.t1 := NULL;
	r.t2 := act_invv;
	r.t3 :=NULL;
	r.t4 :=pcf;
	r.t5 :=pas_cap;
	return next r;
 
    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := -0.001;
    r.t5 := NULL;
    return next r;

    cf:=saldocuenta('1201 ',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    r.rubro1:='Titulos a negociar';
    r.rubro2:='PRESTAMOS BANCARIOS Y DE OTROS ORGANISMOS';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

	cf:=saldocuenta('1202 ',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
	pcf:=saldocuenta('2201 ',pejercicio,pperiodo,sconsolida)*-1;
    if pmiles=1 then
      pcf:=pcf/1000.00;
    end if;
    r.rubro1:='Titulos disponibles para la venta';
    r.rubro2:='De corto plazo';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := NULL;
    return next r;

	cf:=saldocuenta('1203 ',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	pcf:=saldocuenta('2202 ',pejercicio,pperiodo,sconsolida)*-1;
    if pmiles=1 then
      pcf:=pcf/1000.00;
    end if;
    pas_prb:=saldocuenta('2201 ',pejercicio,pperiodo,sconsolida)*-1 +
    		 saldocuenta('2202 ',pejercicio,pperiodo,sconsolida)*-1 ;
    r.rubro1:='Titulos conservados a vencimiento';
    r.rubro2:='De largo plazo';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := pas_prb;
    return next r;

    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 :=-0.001;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 :=-0.001;
    r.t5 := NULL;
    return next r;
    
    
    cf:=saldocuenta('1204 ',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
   
    r.rubro1:='DEUDORES POR REPORTO (SALDO DEUDOR)';
    r.rubro2:='COLATERALES VENDIDOS';
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

	--pcf:=saldocuenta('1204 ',pejercicio,pperiodo,sconsolida)*-1;
    --if pmiles=1 then
      --pcf:=pcf/1000.00;
    --end if;
    --pendiente la cuenta
    r.rubro1:=NULL;
    r.rubro2:='Reportos';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := 0.00;
    r.t5 := NULL;
    return next r;

	--pcf:=saldocuenta('1204 ',pejercicio,pperiodo,sconsolida)*-1;
    --if pmiles=1 then
      --pcf:=pcf/1000.00;
    --end if;
    --pendiente la cuenta
    r.rubro1:='CARTERA DE CREDITO VIGENTE';
    r.rubro2:='Otros colaterales vendidos';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := 0.00;  --falta identificar cuenta 
    r.t5 := 0.00;  --falta identificar cuenta 
    return next r;

    --karen
    
    cf:=saldocuenta('130101',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    fcarteravigente:=cf;

    r.rubro1:='Creditos comerciales';
    r.rubro2:=NULL;
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := -0.001;
     r.t5 := NULL;
    return next r;

    cf:=saldocuenta('130102',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    
    r.rubro1:='Creditos al consumo';
    r.rubro2:='OTRAS CUENTAS POR PAGAR';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;

	cf:=saldocuenta('1301032',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	
	pcf:=saldocuenta('230102',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
    
    r.rubro1:='Creditos a la vivienda';
    r.rubro2:='PTU por pagar';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
     r.t5 := NULL;
    return next r;

    r.rubro1:=NULL;
    r.rubro2:='Aportaciones para futuros aumentos de capital pendientes de';
    r.t1 := -0.001;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
	
	pcf:=saldocuenta('2302',pejercicio,pperiodo,sconsolida)*-1;
    if pmiles=1 then
      pcf:=pcf/1000.00;
    end if;
	r.rubro1:=NULL;
	r.rubro2:='formalizar por su Asamblea General de Socios';
	r.t1 := NULL;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := pcf;
	 r.t5 := NULL;
	return next r;
	
	fcarteravigente:=saldocuenta('130101',pejercicio,pperiodo,sconsolida) +
					 saldocuenta('130102',pejercicio,pperiodo,sconsolida) +
					 saldocuenta('130103',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		fcarteravigente:=fcarteravigente/1000.00;
	end if;
	pcf:=saldocuenta('2303',pejercicio,pperiodo,sconsolida)*-1;
		if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	r.rubro1:= 'TOTAL CARTERA DE CREDITO VIGENTE';
	r.rubro2:='Fondo de Prevision Social';
	r.t1 := fcarteravigente;
	r.t2 := NULL;
	r.t3 := NULL;
	r.t4 := pcf;
	 r.t5 := NULL;
	return next r;


	cf:=saldocuenta('2304',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
    r.rubro1:='';
    r.rubro2:='Fondo de Educacion Cooperativa';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := cf;
     r.t5 := NULL;
    return next r;

	--Falta Cuenta Contable
	--cf:=saldocuenta('2304',pejercicio,pperiodo,sconsolida)*-1;
	--if pmiles=1 then
	--	cf:=cf/1000.00;
	--end if;
    r.rubro1:='CARTERA DE CREDITO VENCIDA';
    r.rubro2:='Acreedores por liquidacion de operaciones';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := 0.00;
    r.t5 := NULL;
    return next r;

	cf:=saldocuenta('130201',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	--cf:=saldocuenta('',pejercicio,pperiodo,sconsolida)*-1;  --falta cuenta contble
	--if pmiles=1 then
		--cf:=cf/1000.00;
	--end if;
    r.rubro1:='Creditos comerciales';
    r.rubro2:='Acreedores por colaterales recibidos en efectivo';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := 0.00; --Falta Cuenta Contable
     r.t5 := NULL;
    return next r;

    cf:=saldocuenta('130202',pejercicio,pperiodo,sconsolida);  --Creditos al Consumo
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
 	pcf:=saldocuenta('2305',pejercicio,pperiodo,sconsolida)*-1 +
		 saldocuenta('2306',pejercicio,pperiodo,sconsolida)*-1 ;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	
	p_otrctasxpag:=saldocuenta('230102',pejercicio,pperiodo,sconsolida)*-1 +
				   saldocuenta('2302  ',pejercicio,pperiodo,sconsolida)*-1 +
				   saldocuenta('2303  ',pejercicio,pperiodo,sconsolida)*-1 +
				   saldocuenta('2304  ',pejercicio,pperiodo,sconsolida)*-1 +
				   saldocuenta('2305  ',pejercicio,pperiodo,sconsolida)*-1 +
				   saldocuenta('2306  ',pejercicio,pperiodo,sconsolida)*-1 ;
	if pmiles=1 then
		p_otrctasxpag:=p_otrctasxpag/1000.00;
	end if;
	
    r.rubro1:='Creditos al consumo';  --cartera vencida 
    r.rubro2:='Acreedores diversos y otras cuentas por pagar';
    r.t1 :=cf; 
    r.t2 :=NULL;
    r.t3 :=NULL;
    r.t4 :=pcf; 
    r.t5 :=p_otrctasxpag;
    return next r;

	cf:=saldocuenta('130203',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
    r.rubro1:='Creditos a la vivienda';
    r.rubro2:=NULL;
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := -0.001;
     r.t5 := NULL;
    return next r;

    pcf:=saldocuenta('25',pejercicio,pperiodo,sconsolida)*-1;
    if pmiles=1 then
      pcf:=pcf/1000.00;
    end if;
    r.rubro1:=NULL;
    r.rubro2:='PTU DIFERIDA (NETO)';
    r.t1 := -0.001;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 :=pcf;
    return next r;
    
	fcarteravencida:=saldocuenta('130201',pejercicio,pperiodo,sconsolida) +
					 saldocuenta('130202',pejercicio,pperiodo,sconsolida) +
					 saldocuenta('130203',pejercicio,pperiodo,sconsolida) ;
	if pmiles=1 then
      fcarteravencida:=fcarteravencida/1000.00;
    end if;
    r.rubro1:='TOTAL CARTERA DE CREDITO VENCIDA';
    r.rubro2:=NULL;
    r.t1 := fcarteravencida;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;

	pcf:=saldocuenta('26',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
    r.rubro1:=NULL;
    r.rubro2:='CREDITOS DIFERIDOS Y COBROS ANTICIPADOS';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := pcf;
    return next r;

	r.rubro1:='TOTAL CARTERA DE CREDITO';
    r.rubro2:=NULL;
    r.t1 := fcarteravigente+fcarteravencida;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := -0.001;
    return next r;

      if pmiles=1 then
        fpasivo:=(-1*saldocuenta('2',pejercicio,pperiodo,sconsolida)/1000.00);
        else 
        fpasivo:=(-1*saldocuenta('2',pejercicio,pperiodo,sconsolida));
    end if;
    
    r.rubro1:='(-)MENOS:';
    r.rubro2:='TOTAL PASIVO';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := fpasivo;
    return next r;
    

    r.rubro1:='ESTIMACION PREVENTIVA PARA RIESGOS';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;

 	cf2:=saldocuenta('1303 ',pejercicio,pperiodo,sconsolida)*-1;
    if pmiles=1 then
      cf2:=cf2/1000.00;
    end if;
   
    r.rubro1:='CREDITICIOS';
    --r.rubro2:='CAPITAL CONTABLE';
    r.rubro2:=NULL;
    r.t1 := cf2;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;


    r.rubro1:=NULL;
    r.rubro2:='CAPITAL CONTABLE';
    r.t1 := -0.001;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
    
	carteraneto:=(fcarteravigente+fcarteravencida) -
				saldocuenta('1303 ',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
	carteraneto:=carteraneto/1000.00;
	end if;
	r.rubro1:='CARTERA DE CREDITO (NETO)';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := carteraneto;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;

   r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;

   
	cf:=saldocuenta('14',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    r.rubro1:='OTRAS CUENTAS POR COBRAR (NETO)';
    r.rubro2:='CAPITAL CONTRIBUIDO';
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

    r.rubro1:=NULL;
    r.rubro2:='Capital social';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
    return next r;
       
    
	cf:=(saldocuenta('15',pejercicio,pperiodo,sconsolida));
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	pcf:=saldocuenta('41010101',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
    r.rubro1:='BIENES ADJUDICADOS (NETO)';
    r.rubro2:='Certificados de aportacion ordinarios';
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := pcf;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;
     
	pcf:=saldocuenta('41010102',pejercicio,pperiodo,sconsolida)*-1 +
		 saldocuenta('41010103',pejercicio,pperiodo,sconsolida)*-1 +
		 saldocuenta('41010106',pejercicio,pperiodo,sconsolida)*-1 ;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	r.rubro1:=NULL;
    r.rubro2:='Certificados excedentes voluntarios';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := pcf;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;
    
	cf:=saldocuenta('16',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	pcf:=saldocuenta('41010105',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	capitalcontribuido:= saldocuenta('41010101',pejercicio,pperiodo,sconsolida)*-1+
						 saldocuenta('41010102',pejercicio,pperiodo,sconsolida)*-1+
						 saldocuenta('41010103',pejercicio,pperiodo,sconsolida)*-1+
						 saldocuenta('41010105',pejercicio,pperiodo,sconsolida)*-1+
						 saldocuenta('41010106',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		capitalcontribuido:=capitalcontribuido/1000.00;
	end if;
    r.rubro1:='PROPIEDADES, MOBILIARIO Y EQUIPO (NETO)';
    r.rubro2:='Certificados para capital de riesgo';
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := pcf;
    r.t4 := capitalcontribuido;
    r.t5 := NULL;
    return next r;

-- Falta especificar cuenta
    r.rubro1:=NULL;
    r.rubro2 := 'Aportaciones para futuros aumentos de capital ';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := -0.001;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;
      
   pcf:=saldocuenta('4102',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
   pcf:=pcf/1000.00;
  	end if;

    r.rubro1:=NULL;
    r.rubro2 := 'formalizadas por su organo de gobierno';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := NULL;
     
    return next r;

	cf:=saldocuenta('17 ',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	r.rubro1:='INVERSIONES PERMANENTES';
    r.rubro2:='Efecto por Incorporacion al Regimen de sociedades';
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := NULL;
    return next r;
    
    cf:=saldocuenta('4107',pejercicio,pperiodo,sconsolida)*-1;
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
    capitalcontribuidot:=capitalcontribuido+cf;
    r.rubro1:=NULL;
    r.rubro2:='cooperativas de ahorro y prestamo (EIRSCAP)';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := cf;
    r.t5 :=capitalcontribuidot;
    return next r;

	r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := -0.001;
    r.t5 := NULL;
    return next r;
    
    --falta cuenta contable 
    --cf:=saldocuenta('',pejercicio,pperiodo,sconsolida)*-1;
    --if pmiles=1 then
      --cf:=cf/1000.00;
    --end if;
    --falta hacer la operacion de:
    --Efecto por IncorporaciÃ³n al RÃ©gimen de sociedades cooperativas de ahorro y prÃ©stamo (EIRSCAP) + 
    --Resultado Neto
    r.rubro1:='ACTIVOS DE LD DISPONIBLES PARA LA VENTA';
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := 0.00;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;

    r.rubro1:= NULL;
    r.rubro2:='CAPITAL GANADO';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
     
    return next r;
 
  cf:=saldocuenta('18',pejercicio,pperiodo,sconsolida);
    if pmiles=1 then
      cf:=cf/1000.00;
    end if;
   pcf:=saldocuenta('42020102',pejercicio,pperiodo,sconsolida)+
   		saldocuenta('4206',pejercicio,pperiodo,sconsolida);

   --pcf:=saldocuenta('4206',pejercicio,pperiodo,sconsolida);
 
 
    if pmiles=1 then
      pcf:=pcf/1000.00;
    end if;
	
	if pcf<0 then
		pcf:=pcf*-1;
	end if;
      
 r.rubro1:= 'PTU DIFERIDA (NETO)';
    r.rubro2:='Fondo de Reserva';
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := pcf;
     r.t5 := NULL;
     
    return next r;

	pcf:=saldocuenta('4202',pejercicio,pperiodo,sconsolida)*-1 -
		 saldocuenta('42020102',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
    
 r.rubro1:=NULL;
    r.rubro2:='Resultado de ejercicios anteriores';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := NULL;
    return next r;
 
 r.rubro1:=NULL;
    r.rubro2:='Resultado por valuacion de titulos disponibles para la';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := NULL;
    return next r;
    
    
    --suma de Cargos diferidos, pagos anticipados e intangibles +
    --otros activos
    pcf:=saldocuenta('4203',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	cf:=saldocuenta('1901',pejercicio,pperiodo,sconsolida)+ 
		saldocuenta('1902',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
    r.rubro1:='OTROS ACTIVOS';
    r.rubro2:='venta';
    r.t1 := NULL;
    r.t2 := cf;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := NULL;
    return next r;
 

	cf:=saldocuenta('1901',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	pcf:=saldocuenta('4204',pejercicio,pperiodo,sconsolida)*-1;
	if pmiles=1 then
		pcf:=pcf/1000.00;
	end if;
	
-- Falta especificar cuenta
    r.rubro1:= 'Cargos diferidos, pagos anticipados e intangibles';
    r.rubro2:= 'Resultado por tenencia de activos no monetarios';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := pcf;
    r.t5 := NULL;
    return next r;
    
	cf:=saldocuenta('1902',pejercicio,pperiodo,sconsolida);
	if pmiles=1 then
		cf:=cf/1000.00;
	end if;
	resultadoneto:=-1*(saldocuenta('5 ',pejercicio,pperiodo,sconsolida)+saldocuenta('6 ',pejercicio,pperiodo,sconsolida));
    if pmiles=1 then
      resultadoneto:=resultadoneto/1000.00;
    end if;
    
    resultadonetot:=saldocuenta('4206',pejercicio,pperiodo,sconsolida)*-1 +
   					--saldocuenta('420601  ',pejercicio,pperiodo,sconsolida)*-1 +
   					saldocuenta('4202    ',pejercicio,pperiodo,sconsolida)*-1 -
   					--saldocuenta('42020102',pejercicio,pperiodo,sconsolida)*-1 +
   					saldocuenta('4203    ',pejercicio,pperiodo,sconsolida)*-1 +
   					saldocuenta('4204    ',pejercicio,pperiodo,sconsolida)*-1 +
   					resultadoneto;

 --pcf:=saldocuenta('42020102',pejercicio,pperiodo,sconsolida)+
   --		saldocuenta('420601',pejercicio,pperiodo,sconsolida);


   						
    if pmiles=1 then
      resultadonetot:=resultadonetot/1000.00;
    end if;

    r.rubro1:= 'Otros activos';
    r.rubro2:='Resultado Neto';
    r.t1 := cf;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := resultadoneto;
    r.t5 := resultadonetot;
    return next r;
    
    
    r.rubro1:=NULL;
    r.rubro2:=NULL;
    r.t1 := -0.001;
    r.t2 := -0.001;
    r.t3 := NULL;
    r.t4 := -0.001;
    r.t5 := -0.001;
    return next r;
    

 
    r.rubro1:= NULL;
    r.rubro2:='TOTAL CAPITAL CONTABLE';
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := capitalcontribuidot+resultadonetot;
    return next r;
    

    r.rubro1:= NULL;
    r.rubro2:=NULL;
    r.t1 := NULL;
    r.t2 := NULL;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := -0.001;
    return next r;

 
    
--totalactivo:=carteraneto

totalactivo:=saldocuenta('14 ',pejercicio,pperiodo,sconsolida)+
			 saldocuenta('15 ',pejercicio,pperiodo,sconsolida)+
			 saldocuenta('16 ',pejercicio,pperiodo,sconsolida)+
			 saldocuenta('17 ',pejercicio,pperiodo,sconsolida)+
			 saldocuenta('18 ',pejercicio,pperiodo,sconsolida)+
			 saldocuenta('1901',pejercicio,pperiodo,sconsolida)+ 
			 saldocuenta('1902',pejercicio,pperiodo,sconsolida)+
			 saldocuenta('1204',pejercicio,pperiodo,sconsolida)+
			 act_dis+act_invv+carteraneto;
	if pmiles=1 then
		totalactivo:=totalactivo/1000.00;
	end if;
	
--JOSELUISMONTES
	--totalactivo:=
    r.rubro1:= 'TOTAL ACTIVO';
    r.rubro2:= 'TOTAL PASIVO Y CAPITAL CONTABLE';
    r.t1 := NULL;
    r.t2 := totalactivo;
    r.t3 := NULL;
    r.t4 := NULL;
    r.t5 := fpasivo+capitalcontribuidot+resultadonetot;
    return next r;

  --dobles linea
    r.rubro1:= NULL;
    r.rubro2:= NULL;
    r.t1 := NULL;
    r.t2 := -0.002;
    r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := -0.002;
    return next r;

  r.rubro1:= NULL;
    r.rubro2:= NULL;
    r.t1 := NULL;
    r.t2 := NULL;
   r.t3 := NULL;
    r.t4 := NULL;
     r.t5 := NULL;
   return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.sprpbalance(integer, integer, integer, integer) OWNER TO sistema;

--
-- Name: sprpbalance2(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: sistema
--

