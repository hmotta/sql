--
--
drop TYPE rpatmir3cre cascade;
CREATE TYPE rpatmir3cre AS (
folio_if integer,
clave_socio_ciente character(15),
no_contrato character(18),
sucursal character(4),
--CLASIFICACION DEL CREDITO Consumo, vivienda, comercial
CLASIFICACION_DEL_CREDITO character(30),
PRODUCTO_DE_CREDITO character(30),
MODALIDAD_DE_PAGO character(80),
--8
FECHA_DE_OTORGAMIENTO date,
MONTO_ORIGINAL numeric,
--10
FECHA_DE_VENCIMIENTO date,
TASA_ORDINARIA numeric,
TASA_MORATORIA numeric,
PLAZO_DEL_CREDITO numeric,
FRECUENCIA_DE_PAGO_CAPITAL integer,
FRECUENCIA_DE_PAGO_INTERESES integer,
DIAS_DE_MORA integer,
CAPITAL_VIGENTE numeric,
CAPITAL_VENCIDO numeric,
IDNC_VIGENTE numeric,
IDNC_VENCIDO numeric,
IDNC_ctas_ORDEN numeric,
--22
FECHA_ULTIMO_PAGO_CAPITAL date,
MONTO_ULTIMO_PAGO_CAPITAL numeric,
--24
FECHA_ULTIMO_PAGO_INTERESES date,
MONTO_ULTIMO_PAGO_INTERESES numeric,
RENOVADO_REESTRUCTURADO_NORMAL character(15),
VIGENTE_VENCIDO character(10),
MONTO_GARANTIA_LIQUIDA  numeric,
TIPO_DE_TASA_ORDINARIA  character(40)
);


CREATE or replace FUNCTION patmir3cre(date,date) RETURNS SETOF rpatmir3cre
    AS $_$
declare

  r rpatmir3cre%rowtype;
  pfechai alias for $1;
  pfechac alias for $2;

begin

    for r in

        select
--FOLIO IF
14,
--CLAVE SOCIO/CLIENTE
s.clavesocioint,
--no_contrato character(18),
pr.referenciaprestamo,
--sucursal character(4),
(select sucid from empresa) as sucursal,
--CLASIFICACION DEL CREDITO Consumo, vivienda, comercial
finalidaddefault(pr.tipoprestamoid),
--PRODUCTO_DE_CREDITO character(30),
t.desctipoprestamo,
--MODALIDAD_DE_PAGO character(30),
(case when pr.condicionid=0 then 'No aplica (operaciones fuera de balance)' else
 (case when pr.condicionid=1 then 'Pago unico de principal e intereses' else (case when pr.condicionid=2 then 'Pago unico de principal y pagos periodicos de intereses' else (case when pr.condicionid=3 then 'Pagos periodicos de principal e intereses' else  'Revolvente' end) end) end) end) as MODALIDAD_DE_PAGO,
--FECHA_DE_OTORGAMIENTO date,
pr.fecha_otorga,
--MONTO_ORIGINAL numeric,
pr.montoprestamo,
--FECHA_DE_VENCIMIENTO
pr.fecha_vencimiento,
pr.tasanormal,
pr.tasa_moratoria, 
--PLAZO_DEL_CREDITO en meses
(pr.fecha_vencimiento-pr.fecha_otorga)/30,
--FRECUENCIA_DE_PAGO_CAPITAL 
(case when pr.dias_de_cobro > 0 then pr.dias_de_cobro else pr.meses_de_cobro*30 end),
--FRECUENCIA_DE_PAGO_INTERESES 
(case when pr.dias_de_cobro > 0 then pr.dias_de_cobro else pr.meses_de_cobro*30 end),
--DIAS_DE_MORA
p.diasvencidos,
--CAPITAL_VIGENTE
p.saldovencidomenoravencido,                  
--CAPITAL_VENCIDO
p.saldovencidomayoravencido,
--IDNC_VIGENTE 
(case when p.saldovencidomenoravencido > 0 then p.interesdevengadomenoravencido else 0 end),
--IDNC_VENCIDO 
(case when p.saldovencidomayoravencido > 0 then p.interesdevengadomenoravencido else 0 end),
--IDNC_ctas_ORDEN 
p.interesdevengadomayoravencido,
--FECHA_ULTIMO_PAGO_CAPITAL 
p.ultimoabono,
--MONTO_ULTIMO_PAGO_CAPITAL
p.pagocapitalenperiodo,
--FECHA_ULTIMO_PAGO_INTERESES date
p.ultimoabonointeres,
--MONTO_ULTIMO_PAGO_INTERESES numeric,
p.pagointeresenperiodo,
--RENOVADO_REESTRUCTURADO_NORMAL 
(case when pr.clasificacioncreditoid=1 then 'Normal' else (case when pr.clasificacioncreditoid=2 then 'Renovado' else 'Reestructurado' end) end),
--VIGENTE_VENCIDO
(case when p.saldovencidomenoravencido > 0 then 'VIGENTE' else 'VENCIDO' end),
--MONTO_GARANTIA_LIQUIDA
p.depositogarantia,
--TIPO_DE_TASA_ORDINARIA
(case when pr.calculonormalid=1 then 'SALDOS INSOLUTOS' else 'SALDOS GLOBALES' end)
--(select descripcioncalculo from calculo where calculoid=pr.calculonormalid)

 from precorte p, prestamos pr, socio s, tipoprestamo t, sujeto su, solicitudingreso si where p.fechacierre=pfechac and  p.saldoprestamo <> 0 and pr.prestamoid=p.prestamoid and s.socioid=pr.socioid and  t.tipoprestamoid = pr.tipoprestamoid and su.sujetoid=s.sujetoid and s.fechaalta >=pfechai and s.socioid=si.socioid and (p.saldoprestamo <>0 or pagocapitalenperiodo <> 0 or pagointeresenperiodo <> 0)  order by p.diasvencidos,s.clavesocioint 

        loop

            return next r;

        end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

--
-- Name: patmir3crec(date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION patmir3crec(date,date) RETURNS SETOF rpatmir3cre
    AS '
declare

  r rpatmir3cre%rowtype;

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
        dblink2:=''set search_path to public,''||f.esquema||'';select * from  patmir3cre(''||''''''''||pfechai||''''''''||'',''||''''''''||pfechaf||''''''''||'');'';

--        raise notice ''dblink % % '',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(
--FOLIO IF
folio_if integer,
clave_socio_ciente character(15),
no_contrato character(18),
sucursal character(4),
CLASIFICACION_DEL_CREDITO character(30),
PRODUCTO_DE_CREDITO character(30),
MODALIDAD_DE_PAGO character(80),
FECHA_DE_OTORGAMIENTO date,
MONTO_ORIGINAL numeric,
FECHA_DE_VENCIMIENTO date,
TASA_ORDINARIA numeric,
TASA_MORATORIA numeric,
PLAZO_DEL_CREDITO numeric,
FRECUENCIA_DE_PAGO_CAPITAL integer,
FRECUENCIA_DE_PAGO_INTERESES integer,
DIAS_DE_MORA integer,
CAPITAL_VIGENTE numeric,
CAPITAL_VENCIDO numeric,
IDNC_VIGENTE numeric,
IDNC_VENCIDO numeric,
IDNC_ctas_ORDEN numeric,
FECHA_ULTIMO_PAGO_CAPITAL date,
MONTO_ULTIMO_PAGO_CAPITAL numeric,
FECHA_ULTIMO_PAGO_INTERESES date,
MONTO_ULTIMO_PAGO_INTERESES numeric,
RENOVADO_REESTRUCTURADO_NORMAL character(15),
VIGENTE_VENCIDO character(10),
MONTO_GARANTIA_LIQUIDA  numeric,
TIPO_DE_TASA_ORDINARIA  character(40)
)

        loop
                return next r;
        end loop;

 end loop;

return;
end
'
language 'plpgsql' security definer;


