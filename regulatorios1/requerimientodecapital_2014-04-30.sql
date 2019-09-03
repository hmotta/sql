
drop type rreqcapital cascade;
CREATE TYPE rreqcapital AS (
	rubro1 character varying(200),
	t1 numeric,
	t2 numeric,
	t3 numeric,
	t4 numeric,
        cuentasiti char(24),
        tiposaldo char(3)
);



drop FUNCTION sprpr2111(integer, integer, integer, integer);

CREATE or replace FUNCTION sprpr2111(integer, integer, integer, integer) RETURNS SETOF rreqcapital
    AS $_$
declare

  pejercicio   alias for $1;
  pperiodo     alias for $2;
  pconsolidado alias for $3;
  pmiles       alias for $4;

  sconsolida char(1);
  
  r rreqcapital%rowtype;

  daytab numeric[2][12]:=array[[31,28,31,30,31,30,31,31,30,31,30,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31]];
  mestab varchar[12]:=array['ENERO','FEBRERO','MARZO',
                            'ABRIL','MAYO','JUNIO',
                            'JULIO','AGOSTO','SEPTIEMBRE',
                            'OCTUBRE','NOVIEMBRE','DICIEMBRE'];
  a1 numeric;
  a2 numeric;
  a3 numeric;
  a4 numeric;
  a5 numeric;
  a6 numeric;
  a7 numeric;

  b1 numeric;
  b2 numeric;
  b3 numeric;
  b4 numeric;
  b5 numeric;
  b6 numeric;
  b7 numeric;
  b8 numeric;

  c0 numeric;
  c1 numeric;
  c2 numeric;
  c3 numeric;
  c4 numeric;
  c5 numeric;
  c6 numeric;
  c7 numeric;
  c8 numeric;
  c9 numeric;
  c10 numeric;
  c11 numeric;
  c12 numeric;
  c13 numeric;
  c14 numeric;
  c15 numeric;
  c16 numeric;
  c17 numeric;
  c18 numeric;
  c19 numeric;
  c20 numeric;
  c21 numeric;
  
  d1 numeric;
  d2 numeric;
  d3 numeric;
  d4 numeric;
  d5 numeric;
  d6 numeric;
  d7 numeric;
  d8 numeric;
  d9 numeric;
  d10 numeric;
  d11 numeric;
  d12 numeric;
  d13 numeric;
  d14 numeric;
  d15 numeric;

  x1 numeric;
  x2 numeric;
  x3 numeric;
  
    
  pfecha date;

begin

  select cast(to_char(pejercicio,'9999')||'-'||trim(to_char(pperiodo,'99'))||'-'||trim(to_char(daytab[1][pperiodo],'99')) as date)  into pfecha;

  raise notice 'Fecha %',pfecha;

  
  c4:=saldocuenta('1101  ',pejercicio,pperiodo,sconsolida);
  c11:=saldocuenta('1102  ',pejercicio,pperiodo,sconsolida)+
       saldocuenta('1103  ',pejercicio,pperiodo,sconsolida)+
       saldocuenta('12  ',pejercicio,pperiodo,sconsolida);

  c18:=saldocuenta('13  ',pejercicio,pperiodo,sconsolida)+
       saldocuenta('14  ',pejercicio,pperiodo,sconsolida);

  b3:=saldocuenta('1301  ',pejercicio,pperiodo,sconsolida)+saldocuenta('1302  ',pejercicio,pperiodo,sconsolida);

  b4:=abs(saldocuenta('1303  ',pejercicio,pperiodo,sconsolida));

  b5:=saldocuenta('12  ',pejercicio,pperiodo,sconsolida);
  
  b8:=saldocuenta('13  ',pejercicio,pperiodo,sconsolida);

  c3:=c4;
  
  c2:=c3*0;

  c10:=c11;
  c9:=c10*.2;

  c17:=c18;
  c16:=c17*1;

  c1:=c2+c9+c16;

  c0:=c1*.08;

  b7:=c0;

  b6:=b7*.3;
    
  d2:=(saldocuenta('4 ',pejercicio,pperiodo,sconsolida)*-1)+
      (saldocuenta('5 ',pejercicio,pperiodo,sconsolida)*-1)+
      (saldocuenta('6 ',pejercicio,pperiodo,sconsolida)*-1);

  
  d10:=saldocuenta('19 ',pejercicio,pperiodo,sconsolida);

  d1:= d2 - d10;


  a5:=b6;
  a6:=c0;
  a4:=a5+a6;

  --a1:=d1/a4*100;
  
  --a2:=d1/c0*100;
  
  --a3:=d1/(c0+b6)*100;

  x1:=(12037112.00/7059198.00)*100;
  x2:=( 12037112/(b3-b4))*100;
  x3:=( 12037112/(872094+b3-b4))*100;
  
-- Primero validar el riesgo de credito

--
--  Comienza pagina 1
--
--
  r.rubro1:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;

  r.rubro1:='Capital neto / Requerimiento total de capital por riesgos 1/';
  r.t1 := NULL;
  r.t2 := x1;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910100000000';
  r.tiposaldo:='153';
  return next r;

  r.rubro1:='Índice de capitalización (Riesgos de crédito) = Capital neto / Activos ponderados por riesgo de crédito 1/';
  r.t1 := NULL;
  r.t2 := x2;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910200000000';
  r.tiposaldo:='153';
  return next r;

  r.rubro1:='Índice de capitalización (Riesgos de crédito y mercado) = Capital neto / ( Requerimiento por riesgos de mercado + Activos';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;
  
  r.rubro1:='ponderados por riesgo de crédito) 1/';
  r.t1 := NULL;
  r.t2 := x3;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910300000000';
  r.tiposaldo:='153';
  return next r;
  
  r.rubro1:='Requerimiento total de capital por riesgos  (I + II + III)';
  r.t1 := '7059198';
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910400000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='I  Requerimiento de capital por riesgo de mercado';
  r.t1 := '872094';
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910401000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='II  Requerimiento  de capital por riesgo de crédito';
  r.t1 := '6187104';
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910402000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='III  Requerimiento de capital por operaciones irregulares capitalizables';
  r.t1 := a7;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910403000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;  
  
  r.rubro1:='I Requerimiento por riesgo de mercado (Entidades con nivel II)';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
    r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='Requerimiento del 1% sobre A';
  r.t1 := (b3-b4+b5)/100;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910500000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='A) = Suma de la cartera de créditos otorgada por la Entidad, neta de las correspondientes provisiones para riesgos crediticios,';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
    r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='y el total de las inversiones en valores  (1 - 2 +3)';
  r.t1 := ((b3-b4)+b5)-1;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910600000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='1  Cartera Total (Vigente + Vencida)';
  r.t1 := b3;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910601000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='2  Estimaciones Preventivas para Riesgos Crediticios   2/';
  r.t1 := b4;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910602000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='3  Inversiones en Valores';
  r.t1 := b5;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910603000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='II Requerimiento por riesgo de mercado (Entidades con niveles III o IV)';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
    r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='Requerimiento del 30% sobre B';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='910700000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='B) = Requerimiento de capitalización por riesgo de crédito';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='910800000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
    r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;
  
  r.rubro1:='II Requerimiento por riesgo de crédito  (8% de Activos ponderados por riesgo) (Entidades con niveles II, III o IV)';
  r.t1 := '6187104';
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='910900000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='Activos ponderados por riesgo  (1 + 2 + 3)';
  r.t1 := round(c2)+round(c9)+round(b8);
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911000000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='1 Ponderación por riesgo de Activos Grupo 1 (0%)';
  r.t1 := c2;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911001000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='Grupo 1 (A+B+C+D+E)';
  r.t1 := c3;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911002000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='A) Caja';
  r.t1 := c4;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911002010000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='B) Valores emitidos o avalados por el Gobierno Federal';
  r.t1 := c5;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911002020000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='C) Créditos al Gobierno Federal o con garantía expresa de la Federación';
  r.t1 := c6;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911002030000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='D) Operaciones continguentes realizadas con las personas señaladas en este grupo';
  r.t1 := c7;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911002040000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='E) Otras operaciones donde la contraparte sea alguna de las personas mencionas de este grupo';
  r.t1 := c8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911002050000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='2 Ponderación por riesgo de Activos Grupo 2 (20%)';
  r.t1 := c9;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911003000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='Grupo 2 (A+B+C+D+E)';
  r.t1 := c10;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911004000000';
  r.tiposaldo:='152';
  return next r;
 
  r.rubro1:='A)Depósitos, valores y créditos a cargo de o garantizados o avalados por instituciones de crédito y por casas de bolsa';
  r.t1 := c11;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911004010000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='B)Créditos y valores a cargo de o garantizados o avalados por fideocomisos públicos constituidos por el Gobierno Federal para el fomento económico';
  r.t1 := c12;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911004020000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='C)Valores y créditos a cargo de organismos descentralizados del Gobierno Federal';
  r.t1 := c13;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911004030000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='D)Otras operaciones autorizadas en donde la contraparte de las Entidades sea alguna de las personas mencionadas en este grupo';
  r.t1 := c14;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911004040000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='E) Porción garantizada por alguna Entidad Pública de Fomento de préstamos para la adquisición o construcción de vivienda personal';
  r.t1 := c15;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911004050000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='3 Ponderación por riesgo de Activos Grupo 3 (100%)';
  r.t1 := b8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911005000000';
  r.tiposaldo:='152';
  return next r;  
  
  r.rubro1:='Grupo 3 (A + B - (C * 0.67) )';
  r.t1 := b8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911006000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='A) Créditos, valores y demás activos que generen riesgo de crédito, no comprendidos en los numerales anteriores';
  r.t1 := b8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911006010000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='B) Porción no garantizada por alguna Entidad Pública de Fomento de préstamos para la adquisición o construcción de vivienda personal';
  r.t1 := c19;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911006020000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='C) Depósito de dinero constituidos por el propio acreditado en la Entidad que cumplan con las condiciones para ser considerados una garantía ';
  r.t1 := c20;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911006030000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
    r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;
  
  r.rubro1:='Capital Neto (1 + 2 + 3 - 4 - 5 - 6 - 7 - 8 - 9 -10)';
  r.t1 := 12278256-241144;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911100000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='1 Capital Contable';
  r.t1 := '12278256';
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911101000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='2 Obligaciones subordinadas de conversión obligatoria   3/';
  r.t1 := d3;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911102000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='3 Obligaciones subordinadas no convertibles o de conversión voluntaria   3/';
  r.t1 := d4;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911103000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='Con plazo de vencimiento por 3 o más años (al 100%)   3/';
  r.t1 := d5;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911103010000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='Con plazos de vencimiento con más de 2  y hasta 3 años (al 60%)   3/';
  r.t1 := d6;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911103020000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='Con plazos de vencimiento con más de 1 y hasta 2 años (al 30%)   3/';
  r.t1 := d7;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911103030000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='Con plazos de vencimiento de hasta por un año (al 0%)   3/';
  r.t1 := d8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911103040000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='4 Inversiones en instrumentos de deuda cuyo pago por parte del emisor o deudor este previsto se efectúe después de cubrir';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.cuentasiti:=NULL;
  r.tiposaldo:=NULL;
  r.t4 := 1;
  return next r;
  
  r.rubro1:='otros pasivos (títulos subordinados)   3/';
  r.t1 := d9;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911104000000';
  r.tiposaldo:='152';
  return next r;
 
  r.rubro1:='5 Gastos de organización y otros intangibles';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911105000000';
  r.tiposaldo:='152';
  return next r;
 
  r.rubro1:='6 Impuestos diferidos activos';
  r.t1 := d11;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911106000000';
  r.tiposaldo:='152';
  return next r;
 
  r.rubro1:='7 Otros intangibles de registro diferido en el capital contable o estado de resultados';
  r.t1 := '241144';
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911107000000';
  r.tiposaldo:='152';
  return next r;
 
  r.rubro1:='8 Préstamos de liquidez';
  r.t1 := d12;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911108000000';
  r.tiposaldo:='152';
  return next r;
 
  r.rubro1:='9 Financiamientos destinados a la adquisición de partes sociales o títulos representativos del capital de la Entidad    4/';
  r.t1 := d14;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911109000000';
  r.tiposaldo:='152';
  return next r;

  return next r;
 
  r.rubro1:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  
  r.rubro1:='Notas:';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='1/ Los Indicadores se deben presentar sin el signo "%", a 4 decimales y en base 100. Por ejemplo: 20% sería 20.0000.';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='1/ Los Indicadores se deben presentar sin el signo "%", a 4 decimales y en base 100. Por ejemplo: 20% sería 20.0000.';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='2/ A diferencia de otros reportes en este, se solicita que la Estimación para riesgos crediticios se presente con signo positivo';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='3/ Aplicable sólo para las entidades pertenecientes a nivel III y IV';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='4/ Aplicable sólo para las entidades pertenecientes a nivel IV';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;
  
  r.rubro1:='Los niveles a los que hace referencia el presente reporte corresponden a los niveles de activos totales netos, de conformidad con la regulación prudencial,';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='que deba observar y aplicar cada Entidad en función de su nivel de activos, contenida en el capital';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
    r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;

  r.rubro1:='Las celdas sombreadas representan celdas invalidadas para las cuales no aplica la información solicitada.';
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;

  return next r;
  
 
return;
end
$_$
    LANGUAGE plpgsql;-- SECURITY DEFINER;
