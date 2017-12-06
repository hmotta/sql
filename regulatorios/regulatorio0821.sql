--Modo de uso 
--select clave__entidad,clave_nivel_institucion,subreporte,clasificacion_contable,localidad,sum(numero_cuentas_contrato),sum(monto_depositos) from captacion821('2010-12-31') group by clave__entidad,clave_nivel_institucion,subreporte,clasificacion_contable,localidad order by clasificacion_contable,localidad;

alter table ciudadesmex  add localidadcnbv character(10);
alter table colonia      add localidadcnbv character(10);


drop type tcaptacion821 cascade;
CREATE TYPE tcaptacion821 AS (
--PERIODO INTEGER,
--CLAVE_FEDERACION CHAR(6),
CLAVE_ENTIDAD char(6),
CLAVE_NIVEL_INSTITUCION integer,
SUBREPORTE integer,
NUMERO_SECUENCIA integer,
CLASIFICACION_CONTABLE char(12), --catalogo
LOCALIDAD  char(10),
NUMERO_CUENTAS_CONTRATO numeric,
MONTO_DEPOSITOS numeric);

CREATE or replace FUNCTION captacion821(date) RETURNS SETOF tcaptacion821
    AS $_$
declare
  --Modificado 4-08-2011
  pfechacierre alias for $1;  
  r tcaptacion821%rowtype;
  i integer;
  pejercicio integer;
  pperiodo integer;

  total1  numeric;
  total11 numeric;
  total2  numeric;
  total21 numeric;
  
begin

 total1:=0;
 total11:=0; 
 total2 :=0; 
 total21:=0; 
  
 i:=0;
 pejercicio:=date_part('year',pfechacierre);
 pperiodo:=date_part('month',pfechacierre);

--Totales captacion

for r in
select
--Periodo
--pperiodo,
--Clavefederacion
--0,
--CLAVE_ENTIDAD char(6),
(select rtrim(ltrim(substring(claveentidad,1,6))) from empresa),
--CLAVE_NIVEL_INSTITUCION integer,
303,
--SUBREPORTE integer,
821,
--NUMERO_SECUENCIA integer,
0,
--Clasificacion_contable
'210000000000',
--Localidad 
rtrim(ltrim(localidad)),
--Numero_de_cuentas_contrato
count(captaciontotalid),
--Monto_depositos
sum(deposito)
from  captaciontotal where fechadegeneracion=pfechacierre and substring(cuentaid,1,2)='21' and sucursal=(select sucid from empresa) group by tipomovimientoid,localidad

loop 
 
  i:=i+1;
  r.NUMERO_SECUENCIA:=i;
  return next r;

end loop;

--Totales ahorros  

for r in
select
--Periodo
--pperiodo,
--Clavefederacion
--0,
--CLAVE_ENTIDAD char(6),
(select rtrim(ltrim(substring(claveentidad,1,6))) from empresa),
--CLAVE_NIVEL_INSTITUCION integer,
303,
--SUBREPORTE integer,
821,
--NUMERO_SECUENCIA integer,
0,
--Clasificacion_contable
'210100000000',
--Localidad 
rtrim(ltrim(localidad)),
--Numero_de_cuentas_contrato
count(captaciontotalid),
--Monto_depositos
sum(deposito)
from  captaciontotal where fechadegeneracion=pfechacierre and substring(cuentaid,1,2)='21' and tipomovimientoid in ('AA','AM') and sucursal=(select sucid from empresa) group by tipomovimientoid,localidad

loop 
 
  i:=i+1;
  r.NUMERO_SECUENCIA:=i;
  return next r;

end loop;

--Por cuenta

for r in
select
--Periodo
--pperiodo,
--Clavefederacion
--0,
--CLAVE_ENTIDAD char(6),
(select rtrim(ltrim(substring(claveentidad,1,6))) from empresa),
--CLAVE_NIVEL_INSTITUCION integer,
303,
--SUBREPORTE integer,
821,
--NUMERO_SECUENCIA integer,
0,
--Clasificacion_contable
(case when tipomovimientoid in ('IN') then '211104000000' else (case when tipomovimientoid in ('AA','AM') then '210102000000' else  '210101000000' end) end),
--Localidad 
rtrim(ltrim(localidad)),
--Numero_de_cuentas_contrato
count(captaciontotalid),
--Monto_depositos
sum(deposito)
from  captaciontotal where fechadegeneracion=pfechacierre and substring(cuentaid,1,2)='21' and sucursal=(select sucid from empresa)  group by tipomovimientoid,localidad

loop 
 
  i:=i+1;
  r.NUMERO_SECUENCIA:=i;
  return next r;

end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE FUNCTION captacion821c(date) RETURNS SETOF tcaptacion821
    AS $_$
declare
  pfecha alias for $1;

  r tcaptacion821%rowtype;

  f record;
  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop
 
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;
        
        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from captacion821('||''''||pfecha||''''||');';
        raise notice ' % % ',dblink1,dblink2;
		  for r in
		    select * from
		   dblink(dblink1,dblink2) as
                   t2(
                   CLAVE__ENTIDAD char(6),
                   CLAVE_NIVEL_INSTITUCION integer,
                   SUBREPORTE integer,
                   NUMERO_SECUENCIA integer,
                   CLASIFICACION_CONTABLE char(12), --catalogo
                   LOCALIDAD  char(10),
                   NUMERO_CUENTAS_CONTRATO numeric,
                   MONTO_DEPOSITOS numeric)
	        loop
                  return next r;
             end loop;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

