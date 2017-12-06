--
--

drop TYPE rpatmir3capta cascade;
CREATE TYPE rpatmir3capta AS (
--FOLIO IF
folio_if integer,
--CLAVE SOCIO/CLIENTE
clave_socio_ciente character(15),
--PRIMER APELLIDO
NUM_CONTRATO_CUENTA character(20),
SUCURSAL character(4),
FECHA_DE_APERTURA date,
TIPO_DE_DEPOSITO character(40),
FECHA_DEL_DEPOSITO date, 
FECHA_DE_VENCIMIENTO date,
PLAZO                integer,
FORMA_DE_PAGO_RENDIMIENTOS integer,
TASA_DE_INTERES numeric,
MONTO           numeric,
IDNP            numeric,
SALDO_TOTAL     numeric
);


CREATE or replace FUNCTION patmir3capta(date,date) RETURNS SETOF rpatmir3capta
    AS $_$
declare

  r rpatmir3capta%rowtype;
  pfechai alias for $1;
  pfechac alias for $2;

begin

    for r in
        select
--FOLIO IF
14,
--CLAVE SOCIO/CLIENTE
ct.clavesocioint,
--NUM_CONTRATO_CUENTA character(20),
(case when ct.tipomovimientoid<>'IN' then ct.tipomovimientoid||'-'||ct.clavesocioint else to_char(inversionid,'99999999') end),
ct.sucursal,
--FECHA_DE_APERTURA date,
ct.fechainversion,
--TIPO_DE_DEPOSITO character(40),
replace(ct.desctipoinversion,',',''),
--FECHA_DEL_DEPOSITO date
ct.fechainversion,
--FECHA_DE_VENCIMIENTO date
(case when ct.tipomovimientoid='IN' then ct.fechavencimiento else pfechac end),
--PLAZO                integer,
(case when ct.tipomovimientoid='IN' then ct.fechavencimiento-ct.fechainversion else 1 end),
--FORMA_DE_PAGO_RENDIMIENTOS integer,
(case when ct.tipomovimientoid='IN' then ct.fechavencimiento-ct.fechainversion else 1 end),
--TASA_DE_INTERES numeric,
ct.tasainteresnormalinversion,
--MONTO           numeric,
ct.deposito,
--IDNP            numeric,
ct.intdevacumulado,
ct.saldototal
from captaciontotal ct where fechadegeneracion=pfechac and substring(cuentaid,1,1)='2' and socioid in (select socioid from socio where fechaalta > pfechai) and sucursal=(select sucid from empresa) order by tipomovimientoid,clavesocioint 

        loop

            return next r;

        end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

--
-- Name: patmir3captac(date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION patmir3captac(date,date) RETURNS SETOF rpatmir3capta
    AS '
declare

  r rpatmir3capta%rowtype;

  pfechai alias for $1;
  pfechaf alias for $2;
  
  f record;

  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente=''S''
 loop
        raise notice ''Conectando sucursal % % '',f.basededatos,f.esquema;

        dblink1:=''host=''||f.host||'' dbname=''||f.basededatos||'' user=''||f.usuariodb||'' password=''||f.passworddb;
        dblink2:=''set search_path to public,''||f.esquema||'';select * from  patmir3capta(''||''''''''||pfechai||''''''''||'',''||''''''''||pfechaf||''''''''||'');'';

--        raise notice ''dblink % % '',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(
               folio_if integer,
               clave_socio_ciente character(15),
               NUM_CONTRATO_CUENTA character(20),
               SUCURSAL character(4),
               FECHA_DE_APERTURA date,
               TIPO_DE_DEPOSITO character(40),
               FECHA_DEL_DEPOSITO date, 
               FECHA_DE_VENCIMIENTO date,
               PLAZO                integer,
               FORMA_DE_PAGO_RENDIMIENTOS integer,      
               TASA_DE_INTERES numeric,
               MONTO           numeric,
               IDNP            numeric,
               SALDO_TOTAL     numeric
               )

        loop
                return next r;
        end loop;

 end loop;

return;
end
'
language 'plpgsql' security definer;



