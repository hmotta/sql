CREATE OR REPLACE FUNCTION rcoeficiente(date, integer, integer) RETURNS SETOF rrcoeficiente
    AS $_$

  DECLARE

  pfechaf   alias for $1;
  pconsolidado alias for $2;
  pmiles       alias for $3;
  
  r rrcoeficiente%rowtype;
  sconsolida char(1);
  dfechai date;

 
  iperiodo int;
  iejercicio int;


  daytab numeric[2][13]:=array[[31,28,31,30,31,30,31,31,30,31,30,31,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31,31]];
  
  mestab varchar[13]:=array['ENERO','FEBRERO','MARZO',
                            'ABRIL','MAYO','JUNIO',
                            'JULIO','AGOSTO','SEPTIEMBRE',
                            'OCTUBRE','NOVIEMBRE','DICIEMBRE',
                            'DICIEMBRE'];


  ftitulosalvencimiento numeric;
  finversionmenor30 numeric;
  fbancos numeric;
  b numeric;

  fprestamosbancarios numeric;
  fdepositoplazomenor30 numeric;
  fdepositoplazomenor30ant numeric;
  fdepositoexigibilidad numeric;
  fdepositocortoplazo numeric;


  fbancosprom numeric;
  ftitulosalvencimientoprom numeric;
  fdepositoplazomenor30prom numeric;
  fdepositoexigibilidadprom numeric;
  fprestamosbancariosprom numeric;
  a numeric;

  ftitulosdisponibles numeric;  
  ftitulosconservados numeric;
  ftitulosreporto     numeric;

  fcoeficiente numeric;
  psucid char(4);
  
begin

  ftitulosalvencimientoprom := 0;
  fbancosprom := 0;
  fdepositoplazomenor30prom := 0;
  fdepositoexigibilidadprom := 0;
  fprestamosbancariosprom := 0;

  select sucid into psucid from empresa where empresaid=1;
  
  -- Inicio de mes

  dfechai := pfechaf - (cast(extract(day from pfechaf) as integer));
  raise notice 'Fecha inicio de mes %',dfechai;

  iejercicio:=date_part('year',pfechaf);
  iperiodo:=date_part('month',pfechaf);

  if pconsolidado=1 then
    r.concepto1:='CONSOLIDADO COEFICIENTE DE LIQUIDEZ';
    sconsolida:='S';
  else
    r.concepto1:='SUCURSAL COEFICIENTE DE LIQUIDEZ';
    sconsolida:='N';
  end if;

  return next r;

-- Calculo de B

  ftitulosdisponibles := abs(saldocuenta('1202',iejercicio,iperiodo,sconsolida));
  --ftitulosconservados := abs(saldocuenta('120301',iejercicio,iperiodo,sconsolida));
  ftitulosconservados := abs(saldocuenta('1203',iejercicio,iperiodo,sconsolida));
  ftitulosreporto := abs(saldocuenta('1204',iejercicio,iperiodo,sconsolida));  

  ftitulosalvencimiento := abs(saldocuenta('1201',iejercicio,iperiodo,sconsolida));   --4

  --ftitulosalvencimientoprom := abs(saldopromediocuenta('1201',iejercicio,iperiodo,sconsolida))+
  --                             abs(saldopromediocuenta('1204',iejercicio,iperiodo,sconsolida));

  finversionmenor30 := ftitulosalvencimiento + ftitulosdisponibles + ftitulosconservados + ftitulosreporto;
  --finversionmenor30 := ftitulosalvencimiento;   

  fbancos := saldocuenta('1102',iejercicio,iperiodo,sconsolida);                       -- 3

  --fbancosprom := saldopromediocuenta('1102',iejercicio,iperiodo,sconsolida);

  b := fbancos +  finversionmenor30;                                                     -- B  ( 3+4 )

-- Calculo de A
    select saldoinsoluto into fprestamosbancarios from prestamobancario where fechavencimiento - pfechaf <= 30;       -- 2
     fprestamosbancarios := coalesce(fprestamosbancarios,0);

    if fprestamosbancarios = 0 then
	fprestamosbancarios := abs(saldocuenta('2201',iejercicio,iperiodo,sconsolida));
    end if; 
     
  --fprestamosbancariosprom := fprestamosbancarios;


   if sconsolida='S'  then

  select round(sum(deposito+intdevacumulado),2) 
    into fdepositoplazomenor30
    from captaciontotal where fechadegeneracion=pfechaf and tipomovimientoid='IN' and fechavencimiento - pfechaf <= 30;

  else

  select round(sum(deposito+intdevacumulado),2)
    into fdepositoplazomenor30
     from captaciontotal where fechadegeneracion=pfechaf and sucursal=psucid and tipomovimientoid='IN' and fechavencimiento - pfechaf <= 30;
  
  end if;

  --if fdepositoplazomenor30ant = 0 then 
  --   fdepositoplazomenor30prom := fdepositoplazomenor30;
  --else 
  --   fdepositoplazomenor30prom := (fdepositoplazomenor30+ fdepositoplazomenor30ant)/2;
  --end if;

  fdepositoplazomenor30 := fdepositoplazomenor30;
  --fdepositoplazomenor30 := 100;
  fdepositoexigibilidad := abs(saldocuenta('2101',iejercicio,iperiodo,sconsolida));

  --fdepositoexigibilidadprom := abs(saldopromediocuenta('2101',iejercicio,iperiodo,sconsolida));

  fdepositocortoplazo :=  fdepositoplazomenor30 + fdepositoexigibilidad;                 -- 1

  a :=  fdepositocortoplazo + fprestamosbancarios;                                      -- A  ( 1+2 )

  fcoeficiente := 100*b/a;

 if pconsolidado=1 
  then
   r.concepto1:='Coeficiente de Liquidez al'||to_char(daytab[1][iperiodo],'99')||' de '||mestab[iperiodo]||' de'||to_char(iejercicio,'9999');
  else
   r.concepto1:='Coeficiente de Liquidez al'||to_char(daytab[1][iperiodo],'99')||' de '||mestab[iperiodo]||' de'||to_char(iejercicio,'9999');
  end if; 
  r.concepto2 := null;
  r.concepto3 := null;
  r.a:=NULL;
  r.b:=NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;
 
  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;

  if pmiles=1 
  then
     r.concepto1:='(Cifras en miles de pesos)';
     r.a := NULL;
     r.b := NULL;
     r.cuentasiti:=NULL;
     r.tiposaldo:=NULL;
     return next r;     
  else
     r.concepto1:='(Cifras en pesos)';
     r.a := NULL;
     r.b := NULL;
     r.cuentasiti:=NULL;
     r.tiposaldo:=NULL;
     return next r;
  end if;
 
    r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;
  
  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;
  
  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;
  
  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;
  
  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;
  
  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  return next r;

  r.concepto1:='Coeficiente de Liquidez (B/A) 2/';
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := fcoeficiente;
  r.b := NULL;
  r.cuentasiti:='915000000000';
  r.tiposaldo:='1';
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  r.b := NULL;
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;

  r.concepto1:='A. Total Pasivos de Corto Plazo (1+2)';
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := a;
  --r.b := fdepositoexigibilidadprom + fdepositoplazomenor30prom+fprestamosbancariosprom;
  r.b := null;                       
  r.cuentasiti:= '915100000000';
  r.tiposaldo:='1';
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  
  return next r;

  r.concepto1 := NULL;
  r.concepto2:='1.Depositos de corto plazo y titulos emitidos ';
  r.concepto3 := null;
  r.a := fdepositocortoplazo;
--  r.b := fdepositoexigibilidadprom + fdepositoplazomenor30prom;
  r.b := null;
  r.cuentasiti:='915101000000';
  r.tiposaldo:='1';
  return next r;   

  r.concepto1 := NULL;
  r.concepto2 := NULL;
  r.concepto3:='De exigibilidad inmediata ';
  r.a := fdepositoexigibilidad;
--  r.b := fdepositoexigibilidadprom;
  r.b := null;
  r.cuentasiti:='915101010000';
  r.tiposaldo:='1';  
  return next r;   

  r.concepto1 := NULL;
  r.concepto2 := NULL;
  r.concepto3:='Depositos a plazo (menor a 30 dias)';  
  r.a := fdepositoplazomenor30;
--  r.b := fdepositoplazomenor30prom;
  r.cuentasiti:='915101020000';
  r.b := null;
  return next r;   

  r.concepto1 := NULL;
  r.concepto2 := NULL;
  r.concepto3:='Titulos de credito emitidos (plazo menor de 30 dias) 3/';
  r.a:= 0;
  --r.b := 0;
  r.b := null;
  r.cuentasiti:='915101030000';
  r.tiposaldo:='1';
  
  return next r;   

  r.concepto1 := NULL;
  r.concepto2 := NULL;
  r.concepto3:='Titulos de credito emitidos (plazo mayor o igual de 30 dias) 3/';
  r.a:= 0;
  r.b := null;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  
  return next r;   

  r.concepto1 := NULL;
  r.concepto2:='2. Prestamos bancarios y de otros organismos';
  r.concepto3 := NULL;
  r.a := fprestamosbancarios;
  --r.b := fprestamosbancarios;
  r.b := null;
  r.cuentasiti:='915102000000';
  r.tiposaldo:='1';
  
  return next r;   

  r.concepto1 := NULL;
  r.concepto2 := NULL;
  r.concepto3:='De corto plazo (menor a 30 dias)';
  r.a:= fprestamosbancarios;
  --r.b := fprestamosbancarios;
  r.b := null;
  r.cuentasiti:='915102010000';
  r.tiposaldo:='1';
  return next r; 

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
--  r.b := NULL;
  r.b := null;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;


  r.concepto1:='B. Total activos liquidos de corto plazo (3 + 4)';
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := b;  
 -- r.b := ftitulosalvencimientoprom + fbancosprom;
  r.b := null;
  r.cuentasiti:='915200000000';
  r.tiposaldo:='1';
  
  return next r;  

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3 := null;
  r.a := NULL;
  r.b := NULL;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;

  r.concepto1 := NULL;
  r.concepto2:='3.Cuentas de cheques';
  r.concepto3 := null;
  r.a := fbancos;
--  r.b := fbancosprom;
  r.b := null;
  r.cuentasiti:='915201000000';
  r.tiposaldo:='1';
 
  return next r; 

  r.concepto1 := NULL;
  r.concepto2:='4.Inversiones en valores con vencimiento menor a 30 dias 4/';
  r.concepto3 := null;
  r.a := finversionmenor30;
--  r.b := ftitulosalvencimientoprom;
  r.b := null;
  r.cuentasiti:='915202000000';
  r.tiposaldo:='1';
  return next r; 

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3:='Titulos por negociar 5/';
  r.a:= ftitulosalvencimiento;
  --r.b := ftitulosalvencimientoprom;
  r.b := null;
  r.cuentasiti:='915202010000';
  r.tiposaldo:='1';
  
  return next r; 

  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3:='Titulos disponibles para la venta 5/';
  r.a:= ftitulosdisponibles;
--  r.b := 0;
  r.b := null;
  r.cuentasiti:='915202020000';
  r.tiposaldo:='1';
  
  return next r; 
  
  r.concepto1 := NULL;
  r.concepto2 := null;
  r.concepto3:='Titulos conservados al vencimiento';
  r.a:= ftitulosconservados;
  r.b := null;
--  r.b := 0;
  r.cuentasiti:='915202030000';
  r.tiposaldo:='1';
  return next r; 
  
  --r.concepto1 := NULL;
  --r.concepto2 := null;  
  --r.concepto3:='Titulos recibidos en reporto';
  --r.a:= 0;
  --r.b := null;
  --r.cuentasiti:='915202040000';
  --r.tiposaldo:='1';
  
  return next r; 
 
  r.concepto1 := NULL;
  r.concepto2 := '5 .- Deudores por reporto con vencimiento menor o igual a 30 días';
  r.concepto3 := NULL;
  r.a:= ftitulosreporto;
  r.b := null;
  r.cuentasiti:='915202050000';
  r.tiposaldo:='1';
  
  return next r; 
 
  
return ;

END
$_$
    LANGUAGE plpgsql;