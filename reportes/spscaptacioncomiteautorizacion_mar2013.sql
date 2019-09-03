--01 NumeroSocio
--02 NombreSocio
--03 RFC
--04 CURP
--05 Contrato
--06 SucursalCuenta
--07 FechaInv
--08 Descripcion
--09 TipoDeposito
--10 TasaInteres
--11 PlazoDeposito
--12 FechaVencimiento
--13 Saldo
--14 Devengado
--15 SaldoTotal
--16 Saldo Promedio
--17 No Tutor
--18 FechaUltimoMovVentanilla

--Modificada el 27 de Febrero del 213
drop TYPE tcaptacioncomiteautorizacion cascade;
CREATE TYPE tcaptacioncomiteautorizacion AS (
	numero_de_socio character varying(18),      --01 NumeroSocio
	nombre_de_socio character varying(80),      --02 NombreSocio
	rfc character varying(16), 					--03 RFC
	curp character varying(20),					--04 CURP
	no_cuenta_contrato character varying(14),   --05 Contrato
	no_sucursal character varying(4),           --06 SucursalCuenta
	fecha_de_apertura character(10),            --07 FechaInv
	tipo_de_cuenta character varying(40),       --08 Descripcion
	tipo_de_deposito character varying(40),		--09 TipoDeposito
	tasa_nominal_anual numeric,					--10 TasaInteres
	plazo_de_productos character varying(80),	--11 PlazoDeposito	
	fecha_de_vencimiento character varying(10), --12 FechaVencimiento
	monto_deposito numeric,						--13 Saldo
	int_dev_men_y_acu numeric,					--14 Devengado
	saldo_total  numeric,						--15 SaldoTotal
	saldo_promedio numeric,						--16 Saldo Promedio                     
	num_soc_padre_tutor character varying(50),	--17 No Tutor
	fecha_ultimo_mov date 						--18 FechaUltimoMovVentanilla
	/*plazo_del_deposito_dias integer,            
	intdevmensual numeric,                      
	intdevacumulado numeric,                    
 	nombre_padre_o_tutor character varying(80),  
	tipo_persona character(10),		   
	fecha_alta_en_sistema character(10), 
	fecha_de_nacimiento character(10)*/
);
CREATE or replace FUNCTION spscaptacioncomiteautorizacion(date) RETURNS SETOF tcaptacioncomiteautorizacion
	AS $_$
	declare
		pfechacierre alias for $1;
		r tcaptacioncomiteautorizacion%rowtype;
		psucid char(4);
begin
select sucid into psucid from empresa where empresaid=1;
for r in
select
--01 numero_de_socio character varying(18),
Rtrim(clavesocioint),

--02 nombre_de_socio character varying(80),
Rtrim(nombresocio), 

--3 rfc 
(case when length(su.rfc)>=10 then su.rfc else '' end),

--4 curp
(case when length(su.curp)<18 then '' else su.curp end),

--05 Contrato
(case when inversionid>0 then substring(clavesocioint,1,3)||ltrim(to_char(inversionid,'999999'))||'IN' else substring(clavesocioint,1,3)||substring(clavesocioint,5,5)||substring(clavesocioint,11,3)||substring(tipomovimientoid,1,2) end),

--06 SucursalCuenta
(select Rtrim(sucid) from empresa where empresaid=1),

--07 FechaInv
(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PA','PB','PR','TA','AI','PR','AM','CC') then (select min(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else fechainversion end),

--08 Descripcion
Rtrim(desctipoinversion),

--09 TipoDeposito
(case when tipomovimientoid in ('AC','AI','AP','AH','PR','AO','AM','CC')  then 'DEPÓSITO A LA VISTA' else  (case when tipomovimientoid in ('IN') then 'DEPÓSITOS A PLAZO' else (case when tipomovimientoid in ('AF') then 'DEPÓSITOS DE AHORRO' else (case when tipomovimientoid in ('AA') then 'DEPÓSITOS RETIRABLES EN DÍAS PREESTABLECIDOS' else 'DEPÓSITOS RETIRABLES EN DÍAS PREESTABLECIDOS' end)  end)  end) end),

--10 TasaInteres
tasainteresnormalinversion,

--11 PlazoDeposito
(case when tipomovimientoid in ('AF','IN','AI','PR','AP')  then 'AL VENCIMIENTO CONTRATO PF' else  (case when tipomovimientoid in ('AM','AO','AH','AC','CC') then 'A LA VISTA' else (case when tipomovimientoid in ('AA') then 'A LA LIQUIDACION DEL PRESTAMO' else to_char(pfechacierre+1,'DD/MM/YYYY')  end)  end) end),

--12 FechaVencimiento
(case when inversionid>0 then to_char(fechavencimiento,'DD/MM/YYYY') else (case when tipomovimientoid in ('AA') then (case when exists (select p.fecha_vencimiento from prestamos p where saldoprestamo>0 and claveestadocredito<>'008' and p.socioid=captaciontotal.socioid) then (select to_char(max(p.fecha_vencimiento),'DD/MM/YYYY') from prestamos p where saldoprestamo>0 and claveestadocredito<>'008' and p.socioid=captaciontotal.socioid) else to_char(pfechacierre+1,'DD/MM/YYYY') end) else 'NA' end) end),

--13 Saldo
deposito,

--14 Devengado
(case when tipomovimientoid in ('IN')  then intdevacumulado else intdevmensual end),

--15 SaldoTotal
deposito+(case when tipomovimientoid in ('IN')  then intdevacumulado else intdevmensual end),

--16 Saldo Promedio
saldopromedio,

--17 No Tutor
(case when (select tiposocioid from socio where socioid=captaciontotal.socioid)='01' then (select coalesce(s.clavesocioint,'') from socio s,relacion re where re.socioid=s.socioid and re.solicitudingresoid=(select solicitudingresoid from solicitudingreso where socioid=captaciontotal.socioid) and  esrepresentante=1 and s.tiposocioid='02' limit 1) else '' end ),

--18 FechaUltimoMovVentanilla
(case when tipomovimientoid in ('AA','AC','AF','AH','AO','AP','P3','PA','PB','PR','TA','AI','PR','AM') then (select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=captaciontotal.socioid and mc.tipomovimientoid = captaciontotal.tipomovimientoid and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechacierre+1 ) else fechainversion end)

/*
plazo,

intdevmensual,

intdevacumulado,

(case when (select tiposocioid from socio where socioid=captaciontotal.socioid)='01' then (select su.nombre||' '||su.paterno||' '||su.materno from sujeto su,relacion re where re.sujetoid=su.sujetoid and re.solicitudingresoid=(select solicitudingresoid from solicitudingreso where socioid=captaciontotal.socioid) and  esrepresentante=1 limit 1) else '' end ),

(case when so.personajuridicaid=0 then 'FISICA' else 'MORAL' end),

(select fechaingreso from solicitudingreso so where so.socioid=captaciontotal.socioid),

(select fecha_nacimiento from sujeto where sujetoid=(select sujetoid from socio where socioid=captaciontotal.socioid)),

(select tipoinversionid from inversion  where inversionid=captaciontotal.inversionid) as tipoinversionid*/

	from captaciontotal, solicitudingreso so, sujeto su, socio s
	where fechadegeneracion=pfechacierre
	and so.socioid=captaciontotal.socioid  
	and so.socioid=s.socioid
	and s.sujetoid=su.sujetoid
	and sucursal=psucid and tipomovimientoid not in ('IP','ID','PA','P3','PB')
	order by clavesocioint, tipomovimientoid
loop 
  return next r;
end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

/*CREATE or replace FUNCTION spscaptacioncomiteautorizacionc(date) RETURNS SETOF tcaptacioncomiteautorizacion
		AS $_$
declare

	pfecha alias for $1;
	r tcaptacioncomiteautorizacion%rowtype;
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
	dblink2:='set search_path to public,'||f.esquema||';select * from  spscaptacioncomiteautorizacion('||''''||pfecha||''''||');';
	--raise notice '% % ', dblink1,dblink2;

	for r in
	SELECT * FROM
		dblink(dblink1,dblink2) as
		t2(
	numero_de_socio character varying(18),      --01
	nombre_de_socio character varying(80),      --02
	no_cuenta_contrato character varying(14),   --03
	no_sucursal character varying(4),           --04
	fecha_de_apertura character(10),            --05
	tipo_de_cuenta character varying(40),       --06
	plazo_de_productos character varying(80),   --07
	fecha_de_vencimiento character varying(10), --08
	tasa_nominal_anual numeric,                 --09
	saldo_promedio numeric,                     --10
	plazo_del_deposito_dias integer,            --11
	monto_deposito numeric,                     --12
	int_dev_men_y_acu numeric,                  --13
	saldo_total  numeric,                       --14
	intdevmensual numeric,                      --15
	intdevacumulado numeric,                    --16
	num_soc_padre_tutor character varying(50),  --17
 	nombre_padre_o_tutor character varying(80),   --18
	tipo_persona character(10),		    --19
	fecha_alta_en_sistema character(10), 	    --20
	fecha_de_nacimiento character(10)
	)
	loop
	return next r;
	end loop;
	end loop;
	return;
end
$_$
	LANGUAGE plpgsql SECURITY DEFINER;*/

