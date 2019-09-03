
drop TYPE rcaptacion815 cascade;
CREATE TYPE rcaptacion815 AS
   (nivel    integer,
    concepto text,
    a        numeric,
    b        numeric,
    cuentasiti char(24),
    tiposaldoa  char(3),
    tiposaldob  char(3)
    );

    
CREATE OR REPLACE FUNCTION regulatorio815(date, numeric, int4, int4)
  RETURNS SETOF rcaptacion815  AS
$BODY$

  DECLARE
  --modificado 4-08-2011
  pfechaf   alias for $1;
  vudi  alias for $2;
  pconsolidado alias for $3;
  pmiles       alias for $4;
  
  r rcaptacion815%rowtype;
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

 saldoa numeric;
 saldob numeric;

 vudi1 numeric;
 vudi2 numeric;
                            
begin
                            
  -- Iniciamos llenado de registro
 
  -- Calcular la captacion verificar los tipos de movimientos de cada entidad.

  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and substring(cuentaid,1,2)='21';
  else
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
  r.nivel := 1;
  r.concepto := 'Total';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225000000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;
  

  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo <= 7 and substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo <= 7 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
  r.nivel := 1;
  r.concepto := 'De 1 a 7 dias';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225001000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 7 and plazo <= 30 and substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 7 and plazo <= 30 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
 
  r.nivel := 1;
  r.concepto := 'De 8 dias a 1 mes';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225002000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  if pconsolidado=1 then
     select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 30 and plazo <= 90 and substring(cuentaid,1,2)='21';
  else 
     select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 30 and plazo <= 90 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
 
  r.nivel := 1;
  r.concepto := 'De 1 mes a 3 meses';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225003000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;
  
  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 90 and plazo <= 180 and substring(cuentaid,1,2)='21';
  else 
     select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 90 and plazo <= 180 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
 
  r.nivel := 1;
  r.concepto := 'De 3 mes a 6 meses';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225004000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  if pconsolidado=1 then
     select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 180 and plazo <= 365 and substring(cuentaid,1,2)='21';
  else 
     select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 180 and plazo <= 365 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
 
  r.nivel := 1;
  r.concepto := 'De 6 mes a 1 año';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225005000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  if pconsolidado=1 then
     select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 365 and plazo <= 365*2 and substring(cuentaid,1,2)='21';
  else 
     select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 365 and plazo <= 365*2 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
 
  r.nivel := 1;
  r.concepto := 'De 1 año a 2 años';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225006000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 365*2  and substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and plazo > 365*2  and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;  
  
 
  r.nivel := 1;
  r.concepto := 'Mas de 2 años';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225007000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;


  
  if pconsolidado=1 then   
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and substring(cuentaid,1,2)='21';

 else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      

  r.nivel := 1;
  r.concepto := 'Total';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225100000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  
  vudi1 = 6000*vudi;
  vudi2 = 6000*vudi;
  
  if pconsolidado=1 then   
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and deposito <= vudi1 and  substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and deposito <= vudi1 and  substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
 end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      

  r.nivel := 1;
  r.concepto := 'Hasta 6000 udis';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225101000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  
  vudi1 = 6000*vudi;
  vudi2 = 8000*vudi;

  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob  from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob  from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);

   end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      

   r.nivel := 1;
  r.concepto := 'De 6001 a 8000 udis';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225102000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  vudi1 = 8000*vudi;
  vudi2 = 10000*vudi;
  
  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob  from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob  from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
   end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      

  r.nivel := 1;
  r.concepto := 'De 8001 a 10000 udis';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225103000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  vudi1 = 10000*vudi;
  vudi2 = 15000*vudi;

   if pconsolidado=1 then
     select sum(deposito),count(captaciontotalid)  into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21';
   else
     select sum(deposito),count(captaciontotalid)  into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
   end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      

  r.nivel := 1;
  r.concepto := 'De 10001 a 15000 udis';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225104000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  
  vudi1 = 15000*vudi;
  vudi2 = 20000*vudi;
  
  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      

  r.nivel := 1;
  r.concepto := 'De 15001 a 20000 udis';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225105000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;
    
  vudi1 = 20000*vudi;
  vudi2 = 25000*vudi;

  if pconsolidado=1 then
     select sum(deposito),count(captaciontotalid) into saldoa,saldob  from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21';
  else
     select sum(deposito),count(captaciontotalid)  into saldoa,saldob from captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1 and  deposito <= vudi2 and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);
  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      

  r.nivel := 1;
  r.concepto := 'De 20001 a 25000 udis';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225106000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;

  vudi1 = 25000*vudi;
  vudi2 = 25000*vudi;

  if pconsolidado=1 then
    select sum(deposito),count(captaciontotalid) from  into saldoa,saldob captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1  and substring(cuentaid,1,2)='21';
  else 
    select sum(deposito),count(captaciontotalid) from  into saldoa,saldob captaciontotal where fechadegeneracion=pfechaf and deposito > vudi1  and substring(cuentaid,1,2)='21' and sucursal = (select sucid from empresa);

  end if;

  if pmiles=1 then 
    saldoa:=round(saldoa/1000);
  
  else
    saldoa:=round(saldoa);
    saldob:=round(saldob);
  end if;      
  
  r.nivel := 1;
  r.concepto := 'Mas de 25000 udis';
  r.a :=saldoa;
  r.b :=saldob;
  r.cuentasiti:='225107000000';
  r.tiposaldoa:=1;
  r.tiposaldob:=84;
  return next r;


return ;

END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

drop type tcaptacion815 cascade;

CREATE TYPE tcaptacion815 AS (
CLAVE__ENTIDAD char(6),
CLAVE_NIVEL_INSTITUCION integer,
CONCEPTO char(12),
SUBREPORTE integer,
TIPO_saldo integer,
DATO NUMERIC
);


CREATE or replace FUNCTION captacion815(date,numeric,integer,integer) RETURNS SETOF tcaptacion815
    AS $BODY$
    
declare

  pfechacierre alias for $1;
  pudi alias for $2;
  pconsolidado alias for $3;
  penmiles alias for $4;
  
  
  r tcaptacion815%rowtype;
   
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
       
for r in select pclaveentidad,pnivel,cuentasiti,815,tiposaldoa,a from regulatorio815(pfechacierre,pudi,pconsolidado,penmiles) 
loop 
  return next r;
end loop;
       
for r in select pclaveentidad,pnivel,cuentasiti,815,tiposaldob,b from regulatorio815(pfechacierre,pudi,pconsolidado,penmiles) 
loop 
  return next r;
end loop;
  
return ;

END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;



  
