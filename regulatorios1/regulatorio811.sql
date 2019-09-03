CREATE OR REPLACE FUNCTION regulatorio811(date, integer, integer) RETURNS SETOF rcaptacion811
    AS $_$

  DECLARE
  --Modificado el 4-08-2011
  
  pfechaf   alias for $1;
  pconsolidado alias for $2;
  pmiles       alias for $3;
  
  r rcaptacion811%rowtype;
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

--1;Saldo al cierre del mes
--2;Saldo del capital al cierre del mes
--4;Intereses del mes
--5;Comisiones del mes
--29;Saldo de los intereses devengados no pagados del mes

 -- Para la vista                           
 vista1 numeric;
 vista2 numeric;
 vista4 numeric;
 vista5 numeric;
 vista29 numeric;

 -- Para Depositos retirables en dias preestablecidos
 retirablesdias1 numeric;
 retirablesdias2 numeric;
 retirablesdias4 numeric;
 retirablesdias5 numeric;
 retirablesdias29 numeric;

 -- Prestamos bancarios y de otros organismos de corto plazo
 cp1 numeric;
 cp2 numeric;
 cp4 numeric;
 cp29 numeric;
 
 -- Banca de desarrollo
 bancadesarrollo1 numeric;
 bancadesarrollo2 numeric;
 bancadesarrollo4 numeric;
 bancadesarrollo29 numeric;

 -- fideicomisos publicos 
 fideicomisospublicos1 numeric;
 fideicomisospublicos2 numeric;
 fideicomisospublicos4 numeric;


                            

begin
                            
  -- Iniciamos llenado de registro
	iperiodo:=cast(date_part('month',pfechaf) as int);
	iejercicio:=cast(date_part('year',pfechaf) as int);
  -- Calcular la captacion verificar los tipos de movimientos de cada entidad.

--  if pmiles = 0 then 
     
	 select round(sum(deposito+intdevmensual)),round(sum(deposito)),round(sum(intdevmensual)),0,round(sum(intdevmensual)) into vista1,vista2,vista4,vista5,vista29  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('AM','AA','AF','AO','AH','CC','PR','AC','AI','AP');

     select round(sum(deposito+intdevacumulado)),round(sum(deposito)),round(sum(intdevmensual)),0,round(sum(intdevacumulado)) into retirablesdias1,retirablesdias2,retirablesdias4,retirablesdias5,retirablesdias29  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('IN') and desctipoinversion not in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT');

     bancadesarrollo2:=(coalesce(round(saldocuenta('22010201',iejercicio,iperiodo)),0)*-1)+(coalesce(round(saldocuenta('22010203',iejercicio,iperiodo)),0)*-1);
	 select round(sum(debe)) into bancadesarrollo4 from movipolizas natural join polizas where cuentaid in ('51020302','51020305') and ejercicio=iejercicio and periodo=iperiodo;
	 bancadesarrollo29:=coalesce(round(saldocuenta('22010202',iejercicio,iperiodo)),0)*-1;
	 bancadesarrollo1:=bancadesarrollo2+bancadesarrollo29;
	 
     fideicomisospublicos2:=coalesce(round(saldocuenta('22010301',iejercicio,iperiodo)),0)*-1 + coalesce(round(saldocuenta('22010303',iejercicio,iperiodo),0))*-1;
	 
	 select round(sum(debe)) into fideicomisospublicos4 from movipolizas natural join polizas where cuentaid in ('51020303','51020304') and ejercicio=iejercicio and periodo=iperiodo;
	 fideicomisospublicos1:=fideicomisospublicos2;
--  end if;
  
  cp1 := bancadesarrollo1+fideicomisospublicos1;
  cp2 := bancadesarrollo2+fideicomisospublicos2;
  cp4 := bancadesarrollo4+fideicomisospublicos4; 
  cp29 := bancadesarrollo29;
 
  r.nivel := 1;
  r.concepto := 'Total (1+2)';
  r.a := vista1+retirablesdias1+cp1;
  r.b := vista2+retirablesdias2+cp2;
  r.c := vista4+retirablesdias4+cp4;
  r.d := vista5+retirablesdias5;
  r.e := vista29+retirablesdias29 +cp29;
  r.cuentasiti:='200000000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  
  return next r;

  r.nivel := 1;
  r.concepto := '1. Captacion tradicional / Depositos';
  r.a := vista1+retirablesdias1;
  r.b := vista2+retirablesdias2;
  r.c := vista4+retirablesdias4;
  r.d := vista5+retirablesdias5;
  r.e := vista29+retirablesdias29;
  r.cuentasiti:='210000000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  
  return next r;

  r.nivel := 2;
  r.concepto := 'Depositos de exigibilidad inmediata';
  r.a := vista1+retirablesdias1;
  r.b := vista2+retirablesdias2;
  r.c := vista4+retirablesdias4;
  r.d := vista5+retirablesdias5;
  r.e := vista29+retirablesdias29;
  r.cuentasiti:='210100000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  
  return next r;

  r.nivel := 3;
  r.concepto := 'Depositos a la vista';
  r.a := vista1;
  r.b := vista2;
  r.c := vista4;
  r.d := vista5;
  r.e := vista29;
  r.cuentasiti:='210104000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  
  return next r;

  r.nivel := 3;
  r.concepto := 'Depositos de ahorro';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='210105000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  
  return next r;


  r.nivel := 2;
  r.concepto := 'Depositos a plazo';
  r.a := retirablesdias1;
  r.b := retirablesdias2;
  r.c := retirablesdias4;
  r.d := retirablesdias5;
  r.e := retirablesdias29;
  r.cuentasiti:='211100000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  
  return next r;
  
  r.nivel := 3;
  r.concepto := 'Depositos a plazo';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='211104000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;
 
  r.nivel := 3;
  r.concepto := 'Depositos retirables en dias preestablecidos';
  r.a := retirablesdias1;
  r.b := retirablesdias2;
  r.c := retirablesdias4;
  r.d := retirablesdias5;
  r.e := retirablesdias29;
  r.cuentasiti:='211105000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  --Se agrega ??
  r.nivel := 3;
  r.concepto := 'Titulos de credito emitidos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='212200000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;


  
  r.nivel := 1;
  r.concepto := '2. Prestamos bancarios y de otros organismos';
  r.a := cp1;
  r.b := cp2;
  r.c := cp4;
  r.d := 0;
  r.e := cp29;
  r.cuentasiti:='230000000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 2;
  r.concepto := 'De corto plazo';
  r.a := cp1;
  r.b := cp2;
  r.c := cp4;
  r.d := 0;
  r.e := cp29;
  r.cuentasiti:='230200000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de banca comercial';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230202000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de desarrollo';
  r.a := bancadesarrollo1;
  r.b := bancadesarrollo2;
  r.c := bancadesarrollo4;
  r.d := 0;
  r.e := bancadesarrollo29;
  r.cuentasiti:='230203000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de fideicomisos publicos';
  r.a := fideicomisospublicos1;
  r.b := fideicomisospublicos2;
  r.c := fideicomisospublicos4;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230204000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de entidades de ahorro y credito popular (de liquidez)';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230209000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de otros organismos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230205000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;


  
  r.nivel := 2;
  r.concepto := 'De largo plazo';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230300000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;


  
  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de banca comercial';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230302000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de desarrollo';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230303000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de fideicomisos publicos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230304000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de entidades de ahorro y credito popular (de liquidez)';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230309000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

  -- Se agrega ??
  
  r.nivel := 3;
  r.concepto := 'Prestamos de otros organismos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230305000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=2;
  r.tiposaldoc:=4;
  r.tiposaldod:=5;
  r.tiposaldoe:=29;
  return next r;

return ;

END
$_$
    LANGUAGE plpgsql;

	
	
