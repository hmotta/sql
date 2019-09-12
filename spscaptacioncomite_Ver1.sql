drop type tcaptacioncomite cascade;
CREATE TYPE tcaptacioncomite AS (
	numero_de_socio character varying(18),
	nombre_de_socio character varying(80),
	no_contrato character varying(14),
	sucursal character varying(16),
	fecha_de_apertura character(10),
	tipo_de_deposito character varying(30),
	fecha_del_deposito character(10),
	fecha_de_vencimiento character varying(10),
	plazo_del_deposito_dias integer,
	forma_de_pago_de_rendimientos_dias character varying(10),
	tasa_de_interes_nominal_pactada_anual numeric,
	monto_del_ahorro_o_deposito_plazo_capital numeric,
	int_dev_no_pag_al_cierre_del_mes_dep_a_plazo_acumulados numeric,
	sdo_total_al_cierre_mes_cap_mas_int_dev_no_pag_dep_a_plazo numeric
);

CREATE or replace FUNCTION spscaptacioncomite(date) RETURNS SETOF tcaptacioncomite
    AS $_$
declare
  pfechacierre alias for $1;
  r tcaptacioncomite%rowtype;
  psucid char(4);

begin
select sucid into psucid from empresa where empresaid=1;
	for r in
select
--01-ClaveSocio
	Rtrim(clavesocioint),
--02-Nombresocio 
	Rtrim(nombresocio), 
--03-numero de contrato 
	(case when inversionid>0 then substring(clavesocioint,1,3)||ltrim(to_char(inversionid,'999999'))||'IN' else substring(clavesocioint,1,3)||substring(clavesocioint,5,5)||substring(clavesocioint,11,3)||substring(tipomovimientoid,1,2) end),
--04-sucursal 
	(select Rtrim(nombresucursal) from empresa where empresaid=1),  
--05-fecha de apertura o contratacion
	(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PA','PB','PR','TA','AI','PR','AM') then (select min(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else fechainversion end),
--06-tipo de depsoito 
	Rtrim(desctipoinversion),
--07-Fecha_del_Deposito
	(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PB','PR','TA','AI','PR','AM') then (select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else (case when tipomovimientoid in ('IN') then fechainversion else (select fechaingreso from solicitudingreso where socioid=captaciontotal.socioid ) end ) end),
--08-fecha de vencimiento
	(case when inversionid>0 then to_char(fechavencimiento,'DD/MM/YYYY') else (case when tipomovimientoid in ('P3') then to_char(fechadegeneracion,'DD/MM/YYYY') else to_char(fechavencimiento,'DD/MM/YYYY') end) end),
--09-plazo deposto en dias 
	plazo,
--10-forma de pago rendimiento (dias)
	(case when tipomovimientoid in ('IN') then (case when (select i.noderenovaciones from inversion i where i.socioid=captaciontotal.socioid and i.inversionid=captaciontotal.inversionid)=3 then '30' else  formapagorendimiento end) else formapagorendimiento end),
--11-tasa de interes nominal pactada (anual)
	tasainteresnormalinversion,
--12-Monto de Original(Capital solo de Depositos a Plazo) 
	deposito,
--13-intereses devengados no pagados al cierre del mes dep a plzo fijo (acumulados)
	(case when tipomovimientoid in ('IN') then intdevacumulado else intdevmensual end),
--14-saldo total 
	saldototal
	from captaciontotal 
	where fechadegeneracion=pfechacierre 
	and sucursal=psucid and tipomovimientoid not in ('IP','ID')
	order by clavesocioint, tipomovimientoid

loop 
  
  return next r;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--ALTER FUNCTION public.spscaptacioncomite(date) OWNER TO sistema;

CREATE or replace FUNCTION spscaptacioncomitec(date) RETURNS SETOF tcaptacioncomite
    AS $_$
declare

  pfecha alias for $1;
  r tcaptacioncomite%rowtype;

  f record;

  dblink1 text;
  dblink2 text;

  i int;
begin

i:=1;

for f in
 select * from sucursales where vigente='S'
 
  loop

        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from  spscaptacioncomite('||''''||pfecha||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	numero_de_socio character varying(18),
	nombre_de_socio character varying(80),
	no_contrato character varying(14),
	sucursal character varying(16),
	fecha_de_apertura character(10),
	tipo_de_deposito character varying(30),
	fecha_del_deposito character(10),
	fecha_de_vencimiento character varying(10),
	plazo_del_deposito_dias integer,
	forma_de_pago_de_rendimientos_dias character varying(10),
	tasa_de_interes_nominal_pactada_anual numeric,
	monto_del_ahorro_o_deposito_plazo_capital numeric,
	int_dev_no_pag_al_cierre_del_mes_dep_a_plazo_acumulados numeric,
	sdo_total_al_cierre_mes_cap_mas_int_dev_no_pag_dep_a_plazo numeric)

        loop
            return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

