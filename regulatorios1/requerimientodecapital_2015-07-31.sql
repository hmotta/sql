
drop type rreqcapital cascade;
CREATE TYPE rreqcapital AS (
	rubro1 character varying(250),
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
  
  capitalcontable numeric;
  otrosintangibles numeric;
  capitalneto numeric;
  requerimientoa numeric;
  requerimientototal numeric;
  
  saldo1 numeric;
  saldo2 numeric;
  saldo3 numeric;
  saldo4 numeric;
  
  pfecha date;

begin
  otrosintangibles:=187951;
  select cast(to_char(pejercicio,'9999')||'-'||trim(to_char(pperiodo,'99'))||'-'||trim(to_char(daytab[1][pperiodo],'99')) as date)  into pfecha;

  raise notice 'Fecha %',pfecha;

  saldo1:=0;
  saldo2:=0;
  saldo3:=0;
  saldo4:=0;
  select saldo from into saldo1 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='110100000000';
  c4:=saldo1;
  --c4:=saldocuenta('1101  ',pejercicio,pperiodo,sconsolida);
  
  
  saldo1:=0;
  saldo2:=0;
  saldo3:=0;
  saldo4:=0;
  select saldo from into saldo1 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='120000000000';
  select saldo from into saldo2 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='110200000000';
  c11:=saldo1+saldo2;
  --c11:=saldocuenta('1102  ',pejercicio,pperiodo,sconsolida)+
    --   saldocuenta('1103  ',pejercicio,pperiodo,sconsolida)+
      -- saldocuenta('12  ',pejercicio,pperiodo,sconsolida)-1;

  c18:=saldocuenta('13  ',pejercicio,pperiodo,sconsolida)+
       saldocuenta('14  ',pejercicio,pperiodo,sconsolida);

  
  saldo1:=0;
  saldo2:=0;
  saldo3:=0;
  saldo4:=0;
  select saldo from into saldo1 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='130000000000';
  select saldo from into saldo2 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='135000000000';
  b3:=saldo1+saldo2;
  --b3:=saldocuenta('1301  ',pejercicio,pperiodo,sconsolida)+saldocuenta('1302  ',pejercicio,pperiodo,sconsolida);

  b4:=abs(saldocuenta('1303  ',pejercicio,pperiodo,sconsolida));

  saldo1:=0;
  saldo2:=0;
  saldo3:=0;
  saldo4:=0;
  select saldo from into saldo1 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='120000000000';
  b5:=saldo1;
  --b5:=saldocuenta('12  ',pejercicio,pperiodo,sconsolida)-1;
  
  --b8:=saldocuenta('13  ',pejercicio,pperiodo,sconsolida);
  
  saldo1:=0;
  saldo2:=0;
  saldo3:=0;
  saldo4:=0;
  select saldo from into saldo1 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='130000000000';
  select saldo from into saldo2 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='135000000000';
  select saldo from into saldo3 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='139000000000';
  select saldo from into saldo4 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='140000000000';
  b8:=saldo1+saldo2+saldo3+saldo4;

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

  
  
  
  select saldo from into saldo1 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='400000000000';
  select saldo from into saldo2 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='100000000000';
  select saldo from into saldo3 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='200000000000';
  --select saldo from into saldo1 imprimircatalogominimo(pejercicio,pperiodo,1) where cuentasiti='400000000000';
  capitalcontable:= saldo1+(saldo2-saldo3-saldo1);

  capitalneto:=capitalcontable-otrosintangibles;
  requerimientoa:=(b3-b4+b5)/100;
  requerimientototal:=(requerimientoa) + ((round(c2)+round(c9)+round(b8))*0.08);
  
  x1:=round(((capitalneto/requerimientototal)*100),4);
  x2:=round((( capitalneto/(b3-b4))*100),4);
  x3:=round((( capitalneto/(requerimientoa+b3-b4))*100),4);
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
  
  r.rubro1:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;
  
  r.rubro1:='NIVEL DE CAPITALIZACIÓN = CAPITAL NETO / REQUERIMIENTO TOTAL DE CAPITAL POR RIESGOS';
  r.t1 := NULL;
  r.t2 := x1;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910100000000';
  r.tiposaldo:='153';
  return next r;
  
  r.rubro1:='REQUERIMIENTO TOTAL DE CAPITAL POR RIESGOS (I + II+III)';
  r.t1 := requerimientototal;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910400000000';
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
  
  r.rubro1:='I. Requerimiento de capital por riesgo de mercado (conforme a monto de activos)';
  r.t1 := requerimientoa;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910401000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='Requerimiento del 1% sobre A';
  r.t1 := requerimientoa;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910401010000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='A) = Suma de activos sujetos a riesgo de mercado (1 - 2 + 3 + 4)';
  r.t1 := requerimientoa;
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
  
  r.rubro1:='4. Deudores por reporto';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910604000000';
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
  
  
  r.rubro1:='II. Requerimiento de capital por riesgo de crédito (conforme a monto de activos)';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910402000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='III. Requerimientos de capitalización adicionales exigida por la CNBV ( Artículos 29,55,95, y 140 de las disposiciones a las que se refiere la ley para regular las actividades de las sociedades cooperativas de ahorro y préstamo)';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910403000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='Requerimiento del 8% sobre activos ponderados por riesgo (1 + 2 + 3)';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:= '910402020000';
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
  r.cuentasiti:='911200000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='A) Caja';
  r.t1 := c4;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911201000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='B) Valores emitidos o avalados por el Gobierno Federal';
  r.t1 := c5;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911202000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='C) Créditos con garantía expresa del propio Gobierno Federal';
  r.t1 := c6;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911203000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='D) Operaciones continguentes realizadas con las personas señaladas en este grupo';
  r.t1 := c7;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911204000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='E) Otras operaciones donde la contraparte sea alguna de las personas mencionas de este grupo';
  r.t1 := c8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911205000000';
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
  r.cuentasiti:='911300000000';
  r.tiposaldo:='152';
  return next r;
 
  r.rubro1:='A)Depósitos, valores y créditos a cargo de o garantizados o avalados por instituciones de crédito y por casas de bolsa';
  r.t1 := c11;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911301000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='B)Créditos y valores a cargo de o garantizados o avalados por fideocomisos públicos constituidos por el Gobierno Federal para el fomento económico';
  r.t1 := c12;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911302000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='C)Valores y créditos a cargo de organismos descentralizados del Gobierno Federal';
  r.t1 := c13;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911303000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='D) Otras operaciones en donde la contraparte de las Sociedades sea alguna de las personas mencionadas en este grupo';
  r.t1 := c14;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911304000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='E) Porción garantizada por alguna Entidad Pública de Fomento de préstamos para la adquisición o construcción de vivienda personal';
  r.t1 := c15;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911305000000';
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
  
  r.rubro1:='Grupo 3 (A + B - C)';
  r.t1 := b8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911400000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='A) Créditos, valores y demás activos que generen riesgo de crédito, no comprendidos en los numerales anteriores';
  r.t1 := b8;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911401000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='B) Porción no garantizada por alguna Entidad Pública de Fomento de préstamos para la adquisición o construcción de vivienda personal';
  r.t1 := c19;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911402000000';
  r.tiposaldo:='152';
  return next r;

  r.rubro1:='C) Depósito de dinero constituidos por el propio acreditado en la Entidad que cumplan con las condiciones para ser considerados una garantía ';
  r.t1 := c20;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911403000000';
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
  
  
  r.rubro1:=NULL;
  r.t1 := NULL;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:=null;
  r.tiposaldo:=null;
  return next r;
  
  r.rubro1:='CAPITAL NETO (1 - 2 - 3 - 4 - 5 - 6 - 7 - 8)';
  r.t1 := capitalneto;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911100000000';
  r.tiposaldo:='152';
  return next r;  

  r.rubro1:='1 Capital Contable';
  r.t1 := capitalcontable;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911101000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='2. Las partidas que se contabilicen en el activo de la sociedad como intangibles o que, en su caso, impliquen el diferimiento de gastos o costos en el capital de la sociedad';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911105000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='3. Los préstamos de liquidez otorgados a otras sociedades con base en lo establecido en el Artículo 19, fracción I, inciso h) de la Ley para regular las actividades de las sociedades cooperativas de a';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911108000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='4. Las inversiones en inmuebles y otros activos, netas de sus correspondientes depreciaciones, que correspondan a las actividades a que se refiere el Artículo 27 de la Ley para regular las actividades';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911110000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='5. Los créditos que se otorguen y las demás operaciones que se realicen en contravención a las disposiciones aplicables';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911111000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='6. Los certificados excedentes o voluntarios suscritos de conformidad con lo previsto por el Artículo 51 de la Ley general de sociedades cooperativas, que no cumplan según corresponda, con las caracte';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911112000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='7. Las inversiones en cualquier instrumento de deuda cuyo pago por parte del emisor o deudor, según se trate, esté previsto que se efectúe, por haberlo así convenido entre las partes, después de cubri';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911104000000';
  r.tiposaldo:='152';
  return next r;
  
  r.rubro1:='8. Los financiamientos y cualquier tipo de aportación a título oneroso, incluyendo sus accesorios, cuyos recursos, directa o indirectamente, se destinen a la adquisición de partes sociales o títulos r';
  r.t1 := 0;
  r.t2 := NULL;
  r.t3 := NULL;
  r.t4 := 1;
  r.cuentasiti:='911109000000';
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
  
 
return;
end
$_$
    LANGUAGE plpgsql;-- SECURITY DEFINER;
