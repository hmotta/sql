drop TYPE tcaptacionpatmir cascade;
CREATE TYPE tcaptacionpatmir AS (
	folio_if character varying(5),
	clave_socio_cliente character varying(18),
	nombresocio character varying(80),
	num_contrato_o_cuenta character varying(14),
	sucursal character varying(16),
	fecha_de_apertura_o_contratacion character(10),
	tipo_de_deposito_cuenta_o_producto character varying(30),
	fecha_del_deposito_ultimo character(10),
	fecha_de_vencimiento character varying(10),
	plazo_del_deposito_dias integer,
	forma_de_pago_de_rendimientos_dias character varying(10),
	tasa_de_interes_nominal_pactada_anual numeric,
	monto_del_ahorro_o_deposito_plazo_capital numeric,
	int_dev_no_pag_al_cierre_del_mes_dep_a_plazo_acumulados numeric,
	sdo_total_al_cierre_mes_cap_mas_int_dev_no_pag_dep_a_plazo numeric,
	inversioid numeric,
	saldopromedio numeric,
	intdevmensual numeric,
	intdevacumulado numeric,
	diaspromedio integer,
	diasvencimiento integer,
	tipomovimientoid character(2),
	grupo character(25),
	socioid integer,
	cuentaid character(24),
	localidad integer,
	isr numeric,
	fechaingreso character(10)
);


CREATE or replace FUNCTION spscaptacionpatmir(date, date) RETURNS SETOF tcaptacionpatmir
    AS $_$
declare
	pfechaingreso alias for $1;
	pfechacierre alias for $2;
  
  r tcaptacionpatmir%rowtype;
  psucid char(4);

begin
select sucid into psucid from empresa where empresaid=1;
	for r in
select
--1folio
	'0017',
--2clave de socio
	Rtrim(captaciontotal.clavesocioint),
--3nombre del socio  
	Rtrim(nombresocio), 
--4numero de contrato 
	(case when inversionid>0 then substring(captaciontotal.clavesocioint,1,3)||ltrim(to_char(inversionid,'999999'))||'IN' else substring(captaciontotal.clavesocioint,1,3)||substring(captaciontotal.clavesocioint,5,5)||substring(captaciontotal.clavesocioint,11,3)||substring(tipomovimientoid,1,2) end),
--5sucursal 
	(select Rtrim(nombresucursal) from empresa where empresaid=1),  
--6fecha de apertura o contratacion
	(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','PR','TA','AI','PR','AM') then (select min(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1) else fechainversion end),
--7tipo de depsoito 
	Rtrim(desctipoinversion),
--8fecha del depsoito (ultimo)
	(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','PR','TA','AI','PR','AM') then (select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else fechainversion end),
--9fecha de vencimiento
	(case when inversionid>0 then to_char(fechavencimiento,'DD/MM/YYYY') else Rtrim('NA') end),
--10plazo deposto en dias 
	plazo,
--11forma de pago rendimiento (dias)
--formapagorendimiento,
	(case when tipomovimientoid in ('IN') then (case when (select i.noderenovaciones from inversion i where i.socioid=captaciontotal.socioid and i.inversionid=captaciontotal.inversionid)=3 then '30' else  formapagorendimiento end) else formapagorendimiento end),
--12tasa de interes nominal pactada (anual)
	tasainteresnormalinversion,
--13monto de ahorro  
	deposito,
--14intereses devengados no pagados al cierre del mes dep a plzo fijo (acumulados)
	trunc(intdevacumulado,2),
--15saldo total  (se valida de acuerdo a la herramienta de patmir)
--	saldototal,
        --trunc(deposito +(case when tipomovimientoid in ('IN')  then intdevacumulado else intdevmensual end),2),
	--deposito +(case when tipomovimientoid in ('IN')  then intdevacumulado else intdevmensual end),  --02-febrero 2013 Esta linea de Codigo seria la idela para reportear el total de haberes + int (en la herramienta de patmir no lo validad asi, entonces tomaremos la columa de saldo total + interesesacumulados ) 
 deposito + trunc(intdevacumulado,2),

--- campos adiconales  
	inversionid,

--16saldo promedio
	saldopromedio,
--17interes devengado mensual
	intdevmensual,
--18inteses devengado acumulado
	intdevacumulado,
--19dias promedio
	diaspromedio,
--20dias vencidos
	diasvencimiento,
--21tipo de movimiento id 
	tipomovimientoid, 
--22grupo 
	so.grupo,
--23socio id 
	so.socioid, 
--24cuenta contable de deposito y retiro 
	cuentaid,
--25clave de localidad
	localidad,
--26 isr de inversiones
	isr,
--27 fecha ingreso
	(select fechaingreso from solicitudingreso so where so.socioid=captaciontotal.socioid)


	from captaciontotal, solicitudingreso so, socio s
	where fechadegeneracion=pfechacierre 
	--and s.tiposocioid not in ('05')  ----modificado el 07 de Septiembre del 2012
	and s.tiposocioid in ('01','02','05')  ----modificado el 07 de Septiembre del 2012
	and s.socioid=captaciontotal.socioid
	and fechaingreso>=pfechaingreso
	and sucursal=psucid 
	and so.socioid=captaciontotal.socioid
	--and captaciontotal.clavesocioint in (select clave_socio_cliente from spssociopatmir(pfechaingreso,pfechacierre))
	-- no pa, pso p3, psv, ide
	and desctipoinversion not in ('PARTE SOCIAL','PARTE SOCIAL P3','PARTE SOCIAL ADICIONAL OBLIGAT','PARTE SOCIAL ADICIONAL VOLUNTA','IMPUESTO POR DEP. EN EFECTIVO','PAGO PARCIAL DE CAPITAL SOCIAL')
	--and saldototal>=0   --modificado el 07 de Septiembre del 2012 >=0
	
	--and (case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PA','PB','PR','TA','AI','PR','AM') then (select min(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else fechainversion end)<=pfechacierre
	order by captaciontotal.clavesocioint, tipomovimientoid

loop 
  
  return next r;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.spscaptacionpatmir(date, date) OWNER TO sistema;

--
-- Name: spscaptacionpatmirc(date, date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION spscaptacionpatmirc(date, date) RETURNS SETOF tcaptacionpatmir
    AS $_$
declare


	pfechaingreso alias for $1;
	pfechacierre alias for $2;



  r tcaptacionpatmir%rowtype;

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
        --dblink2:='set search_path to public,'||f.esquema||';select * from  spscaptacionpatmir('||''''||pfecha||''''||');';
        dblink2:='set search_path to public,'||f.esquema||';select * from  spscaptacionpatmir('||''''||pfechaingreso||''''||','||''''||pfechacierre||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	folio_if character varying(5),
	clave_socio_cliente character varying(18),
	nombresocio character varying(80),
	num_contrato_o_cuenta character varying(14),
	sucursal character varying(16),
	fecha_de_apertura_o_contratacion character(10),
	tipo_de_deposito_cuenta_o_producto character varying(30),
	fecha_del_deposito_ultimo character(10),
	fecha_de_vencimiento character varying(10),
	plazo_del_deposito_dias integer,
	forma_de_pago_de_rendimientos_dias character varying(10),
	tasa_de_interes_nominal_pactada_anual numeric,
	monto_del_ahorro_o_deposito_plazo_capital numeric,
	int_dev_no_pag_al_cierre_del_mes_dep_a_plazo_acumulados numeric,
	sdo_total_al_cierre_mes_cap_mas_int_dev_no_pag_dep_a_plazo numeric,
	 --adiconales	
	inversioid numeric,   
	saldopromedio numeric,   
	intdevmensual numeric,
	intdevacumulado numeric,
	diaspromedio integer,
	diasvencimiento integer,
	tipomovimientoid character(2),
	grupo character(25),
	socioid integer,
	cuentaid character(24),
	localidad integer,
	isr numeric,
	fechaingreso character(10)
	)

        loop
            return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.spscaptacionpatmirc(date, date) OWNER TO sistema;

--SET search_path = sucursal10, pg_catalog;

--
-- Name: cargoprestamo; Type: TABLE; Schema: sucursal10; Owner: sistema; Tablespace: 
--

