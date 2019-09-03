
drop TYPE rcaptacion811 cascade;
CREATE TYPE rcaptacion811 AS
   (nivel    integer,
    concepto text,
    a        numeric,
    b        numeric,
    c        numeric,
    d        numeric,
    e        numeric,
    cuentasiti char(24),
    tiposaldoa  char(3),
    tiposaldob  char(3),
    tiposaldoc  char(3),
    tiposaldod  char(3),
    tiposaldoe  char(3)    
    );


CREATE OR REPLACE FUNCTION regulatorio811(date, int4, int4)
  RETURNS SETOF rcaptacion811  AS
$BODY$

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

 -- Para la vista                           
 a1 numeric;
 b1 numeric;
 c1 numeric;
 d1 numeric;
 e1 numeric;
 
 -- Para el ahorro                           
 a2 numeric;
 b2 numeric;
 c2 numeric;
 d2 numeric;
 e2 numeric;

 -- Para el plazo fijo                           
 a3 numeric;
 b3 numeric;
 c3 numeric;
 d3 numeric;
 e3 numeric;

 -- Totales exigibilidad inmediata
 
 ta1 numeric;
 tb1 numeric;
 tc1 numeric;
 td1 numeric;
 te1 numeric;

 -- Totales plazo fijo
 
 ta2 numeric;
 tb2 numeric;
 tc2 numeric;
 td2 numeric;
 te2 numeric;

                            

begin
                            
  -- Iniciamos llenado de registro
 
  -- Calcular la captacion verificar los tipos de movimientos de cada entidad.

  if pmiles = 0 then 
     select round(sum(deposito)),round(sum(intdevacumulado)),round(sum(saldopromedio)),round(sum(intdevmensual)),0 into a1,b1,c1,d1,e1  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('CU','CE');

     select round(sum(deposito)),round(sum(intdevacumulado)),round(sum(saldopromedio)),round(sum(intdevmensual)),0 into a2,b2,c2,d2,e2  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('AA','AM');

     select round(sum(deposito)),round(sum(intdevacumulado)),round(sum(saldopromedio)),round(sum(intdevmensual)),0 into a3,b3,c3,d3,e3  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('IN');

  else
  
     select round(sum(deposito)/1000),round(sum(intdevacumulado)/1000),round(sum(saldopromedio)/1000),round(sum(intdevmensual)/1000),0 into a1,b1,c1,d1,e1  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('CU','CE');
     select round(sum(deposito)/1000),round(sum(intdevacumulado)/1000),round(sum(saldopromedio)/1000),round(sum(intdevmensual)/1000),0 into a2,b2,c2,d2,e2  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('AM','AA');
     select round(sum(deposito)/1000),round(sum(intdevacumulado)/1000),round(sum(saldopromedio)/1000),round(sum(intdevmensual)/1000),0 into a3,b3,c3,d3,e3  from captaciontotal  where fechadegeneracion=pfechaf and tipomovimientoid in ('IN');

  end if;
  
  ta1:=a1+a2;
  tb1:=b1+b2;
  tc1:=c1+c2;  
  td1:=d1+d2;
  te1:=e1+e2;
  
  
  ta2:=a3;
  tb2:=b3;
  tc2:=c3;  
  td2:=d3;
  te2:=e3;
  

  r.nivel := 1;
  r.concepto := 'Total (1+2)';
  r.a := ta1+ta2;
  r.b := tb1+tb2;
  r.c := tc1+tc2;
  r.d := td1+td2;
  r.e := te1+te2;
  r.cuentasiti:='200000000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  
  return next r;

  r.nivel := 1;
  r.concepto := '1. Captación Tradicional / Depósitos';
  r.a := ta1+ta2;
  r.b := tb1+tb2;
  r.c := tc1+tc2;
  r.d := td1+td2;
  r.e := te1+te2;
  r.cuentasiti:='210000000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  
  return next r;

  r.nivel := 2;
  r.concepto := 'Depósitos de exigibilidad inmediata';
  r.a := ta1;
  r.b := tb1;
  r.c := tc1;
  r.d := td1;
  r.e := te1;
  r.cuentasiti:='210100000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  
  return next r;

  r.nivel := 3;
  r.concepto := 'Depósitos a la vista';
  r.a := a1;
  r.b := b1;
  r.c := c1;
  r.d := d1;
  r.e := e1;
  r.cuentasiti:='210104000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  
  return next r;

  r.nivel := 3;
  r.concepto := 'Depósitos de ahorro';
  r.a := a2;
  r.b := b2;
  r.c := c2;
  r.d := d2;
  r.e := e2;
  r.cuentasiti:='210105000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  
  return next r;


  r.nivel := 2;
  r.concepto := 'Depósitos a plazo';
  r.a := ta2;
  r.b := tb2;
  r.c := tc2;
  r.d := td2;
  r.e := te2;
  r.cuentasiti:='211100000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  
  return next r;
  
  r.nivel := 3;
  r.concepto := 'Depósitos a plazo';
  r.a := a3;
  r.b := b3;
  r.c := c3;
  r.d := d3;
  r.e := e3;
  r.cuentasiti:='211104000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;
 
  r.nivel := 3;
  r.concepto := 'Depositos retirables en dias preestablecidos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='211105000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  --Se agrega ??
  r.nivel := 3;
  r.concepto := 'Titulos de credito emitidos /3';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='212200000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;


  
  r.nivel := 1;
  r.concepto := '2. Prestamos bancarios y de otros organismos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230000000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 2;
  r.concepto := 'De corto plazo';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230200000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de banca comercial';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230202000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de desarrollo';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230203000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de fideicomisos publicos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230204000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de entidades de ahorro y credito popular (de liquidez)';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230209000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de otros organismos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230205000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;


  
  r.nivel := 2;
  r.concepto := 'De largo plazo';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230300000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;


  
  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de banca comercial';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230302000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de instituciones de desarrollo';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230303000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de fideicomisos publicos';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230304000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

  r.nivel := 3;
  r.concepto := 'Prestamos de entidades de ahorro y credito popular (de liquidez)';
  r.a := 0;
  r.b := 0;
  r.c := 0;
  r.d := 0;
  r.e := 0;
  r.cuentasiti:='230309000000';
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
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
  r.tiposaldoa:=2;
  r.tiposaldob:=29;
  r.tiposaldoc:=1;
  r.tiposaldod:=4;
  r.tiposaldoe:=5;
  return next r;

return ;

END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;



drop type tcaptacion811 cascade;

CREATE TYPE tcaptacion811 AS (
CLAVE__ENTIDAD char(6),
CLAVE_NIVEL_INSTITUCION integer,
CONCEPTO char(12),
SUBREPORTE integer,
TIPO_saldo integer,
DATO NUMERIC
);


CREATE or replace FUNCTION captacion811(date,integer,integer) RETURNS SETOF tcaptacion811
    AS $BODY$
    
declare

  pfechacierre alias for $1;
  pconsolidado alias for $2;
  penmiles alias for $3;
  
  
  r tcaptacion811%rowtype;
   
  pclaveentidad  char(6);
  pnivel integer;

  pejercicio integer;
  pejercicioanterior integer;
  
  pperiodo integer;
  pperiodoanterior integer;
 
begin

--Nivel de la entidad
pnivel:=303;
--Clave de la entidad

select rtrim(ltrim(claveentidad)) into  pclaveentidad from empresa;

pejercicio:=cast(extract(year from pfechacierre) as integer);
pperiodo:=cast(extract(month from pfechacierre) as integer);
       
for r in select pclaveentidad,pnivel,cuentasiti,811,tiposaldoa,a from regulatorio811(pfechacierre,pconsolidado,penmiles) 
loop 
  return next r;
end loop;
       
for r in select pclaveentidad,pnivel,cuentasiti,811,tiposaldob,b from regulatorio811(pfechacierre,pconsolidado,penmiles) 
loop 
  return next r;
end loop;
       
for r in select pclaveentidad,pnivel,cuentasiti,811,tiposaldoc,c from regulatorio811(pfechacierre,pconsolidado,penmiles) 
loop 
  return next r;
end loop;
       
for r in select pclaveentidad,pnivel,cuentasiti,811,tiposaldod,d from regulatorio811(pfechacierre,pconsolidado,penmiles) 
loop 
  return next r;
end loop;
       
for r in select pclaveentidad,pnivel,cuentasiti,811,tiposaldoe,e from regulatorio811(pfechacierre,pconsolidado,penmiles) 
loop 
  return next r;
end loop;

  
return ;

END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;



  
