--Modificado Para Cooperativa Yolomecatl el dia 05/10/2011 by Hmota

--alter table estadosmex add abre_estado char(3);
--alter table precorte add importeultimaamort numeric;
--alter table precorte add importevencidoamort numeric;

drop TYPE rformato cascade;
CREATE TYPE rformato AS (
	prestamoid integer,
	diasvencidos integer,
	clave character(10),
	nombre text,
	fecha_reporte char(8),
	clavesocioint character(15),
	paterno character varying(20),
	materno character varying(20),
	adicional character varying(40),
	primer_nombre character varying(40),
	segundo character varying(40),
	fecha_nac character(8),
	rfc character varying(13),
	prefijo character varying(10),
	edo_civil character varying(8),
	sexo character(1),
	f_def date,
	indic_def character varying(2),
	calle_numero character varying(80),
	segunda_linea character varying(80),
	colonia character varying(100),
	municipio character varying(100),
	ciudad character varying(100),
	estado character varying(4),
	cp character varying(15),
	telefono character varying(20),
    empresa character varying(40),
	calle_numero_1 character varying(40),
	direccion_complemento_1 character varying(40),
	colonia_1 character varying(40),
	municpio_1 character varying(40),
	ciudad_1 character varying(40),
	estado_1 character varying(40),
	cp_1 character varying(15),
	telefono_1 character varying(4),
	salario character varying(4),
	clave_otorgante_1 character(10),
	nombre_2 character varying(100),
	referenciaprestamo character(18),
	cuenta character varying(19),
	responsabilidad character varying(2),
	tipo_cta character varying(2),
	tipo_contrato character varying(3),
	moneda character varying(3),
	num_pagos integer,
	frec_pagos character varying(2),
	apertura char(8),
	importe_pago numeric,
	pago char(8),
	compra char(8),
	cierre character varying(8),
	reporte char(8),
	cred_maximo numeric,
	saldo_actual numeric,
	limite_credito numeric,
	saldo_vencido numeric,
	pagos_vencidos numeric,
	forma_pago_actual character varying(3),
	observacion character varying(80),
	member_ant character varying(10),
	nombre_ant character varying(30),
	numero_ant character varying(10)
);



CREATE or replace FUNCTION reporteburo(date) RETURNS SETOF rformato
    AS $_$
declare

  pfecha alias for $1;
  r rformato%rowtype;

  i int;
begin

  i:=1;
  for r in
       select
	   p.prestamoid,
	   pr.diasvencidos,
       --1 clave
       'BB12345678',
       --2 nombre 
       'COOP YOLOMECATL',
       --3 fecha_reporte
       rtrim(to_char(pfecha,'DDMMYYYY')),
	   s.clavesocioint,
       --4 paterno	
       (case when su.paterno = null or su.paterno = ' ' or su.paterno = '' or su.paterno = 'X' then 'NO PROPORCIONADO' else ltrim(rtrim(su.paterno)) end),
       --5 materno
       (case when su.materno = null or su.materno = ' ' or su.materno = '' or su.materno = 'X' then 'NO PROPORCIONADO' else ltrim(rtrim(su.materno)) end),
       --6 adicional
       '',
       --7 primer_nombre
       ltrim(rtrim(su.nombre)),
       --8 segundo
       '',
       --9 fecha_nac
       rtrim(to_char(su.fecha_nacimiento,'DDMMYYYY')),
       --10 rfc
       substring(rtrim(su.rfc),1,13),
       --11 prefijo
       '',
       --12 edo_civil
       (case when so.estadocivilid=0 then 'S' else (case when so.estadocivilid=1 then 'M' else (case when so.estadocivilid=2 then 'D' else (case when so.estadocivilid=3 then 'W' else 'F' end) end) end) end),
       --13 sexo
       (case when so.sexo=0 then 'M' else 'F' end),
       --14 f_dec
       null,
       --15 indic_def
       '',
       --16 calle_numero
       upper((rtrim(ltrim(d.calle))||' '||rtrim(ltrim(d.numero_ext)))),
       --17 direccion_complemento
       '',
       --18 colonia_o_pob
       rtrim(col.nombrecolonia),
       --19 municipio
       rtrim(c.nombreciudadmex),--rtrim(d.comunidad),
       --20 ciudad
       '',--rtrim(c.nombreciudadmex),
       --21 estado
       rtrim(e.abre_estado),
       --22 cp
       lpad(ltrim(to_char(col.cp,'99999')),5,'0'),
       --23 telefono
       '',--ltrim(case when d.teldomicilio = ' ' or d.teldomicilio = '' or d.teldomicilio = null then '0' else d.teldomicilio end),
	   --24 empresa
	   '',
	   --25 direccion_calle_numero
	   '',
	   --26 direccion_complemento
	   '',
	   --27 colonia_o_poblacion
	   '',
	   --28 delegacion_o_municpio
	   '',
	   --29 ciudad
	   '',
	   --30 estado
	   '',
	   --31 c.p.
	   '',
	   --32 telefono
	   '',
	   --33 salario
	   '',
       --34 clave_otorgante
       'BB12345678',
       --35 nombre del otorgante
       'COOP YOLOMECATL',
	   p.referenciaprestamo,
       --36 numero_cuenta
       (select substring(sucid,1,3) from empresa where empresaid=1)||substring(p.referenciaprestamo,1,6)||substring(p.referenciaprestamo,8,10),
       --37 responsabilidad
       'I',
       --38 tipo_cta
       'I',
       --39 tipo_contrato
       'PL',
       --40 moneda
       'MX',
       --41 num_pagos
       p.numero_de_amor,
       --42 frec_pagos
       (case when p.meses_de_cobro=2 then 'B' else (case when p.meses_de_cobro=3 then 'Q' else 'M' end) end),       
	   --43 fecha_apertura
       to_char(p.fecha_otorga,'DDMMYYYY'),
       --44 importe_pago
       (case when 
       trunc(((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)+importeultimaamort)<  trunc(pr.saldoprestamo+((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)) then trunc(((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)+importeultimaamort) else  trunc(pr.saldoprestamo+((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)) end),      
       --45 pago_ultimo_pago
       to_char(pr.fechaultamorpagada,'DDMMYYYY'),
       --46 fecha_ultima_compra
       to_char(p.fecha_otorga,'DDMMYYYY'),
       --47 fecha_cierre_credito
       (case when pr.saldoprestamo=0 then to_char(pfecha,'DDMMYYYY') else '' end),
       --48 fecha_reporte
       to_char(pfecha,'DDMMYYYY'),
       --49 credito_maximo
       trunc(p.montoprestamo),
       --50 saldo_actual El saldo más todos los intereses.
       trunc(pr.saldoprestamo+((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)),
       --51 limite_credito
       trunc(p.montoprestamo),
       --52 saldo_vencido
       trunc(importevencidoamort),             
       --53 numero_pagos_vencidos
       --(case when pr.importevencidoamort=0 then 0 else pr.noamorvencidas end),
       pr.noamorvencidas,
       --54 forma_pago_mop
       (case when pr.importevencidoamort=0 then '01' else (case when pr.diasvencidos >=1 and pr.diasvencidos <=29 then '02' else (case when pr.diasvencidos >29 and pr.diasvencidos <=59 then '03' else (case when pr.diasvencidos >59 and pr.diasvencidos <=89 then '04' else (case when pr.diasvencidos >89 and pr.diasvencidos <=119 then '05' else  (case when pr.diasvencidos >119 and pr.diasvencidos <=149 then '06' else (case when pr.diasvencidos >149 and pr.diasvencidos <=360 then '07' else (case when pr.diasvencidos >360 and pr.diasvencidos <=389 then '96' else '96' end) end) end)end) end) end) end) end),       
	   --55 clave_observacion
       '',
	   --56 clave_anterior_otorgante
       '',
	   --57 nombre_anterior_otorgante
       '',
	   --58 numero_cta_anterior
       ''
       from precorte pr, prestamos p, socio s, solicitudingreso so, sujeto su, domicilio d, colonia col, ciudadesmex c, estadosmex e
       where pr.fechacierre = pfecha and pr.saldoprestamo >0 and s.tiposocioid = '02' and 
             p.prestamoid = pr.prestamoid and
             s.socioid = p.socioid and
             su.sujetoid=s.sujetoid and
             so.socioid=s.socioid and
             d.sujetoid=su.sujetoid and
             col.coloniaid=d.coloniaid and
             c.ciudadmexid=d.ciudadmexid and
             e.estadomexid=c.estadomexid 
  loop
    --r.clave:=i;
    --i:=i+1;
	IF r.paterno = 'NO PROPORCIONADO' AND r.materno <> 'NO PROPORCIONADO' THEN
		r.paterno = r.materno; r.materno = 'NO PROPORCIONADO';
	END IF;
    return next r;
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION reporteburoc(date) RETURNS SETOF rformato
    AS $_$
declare

  pfecha alias for $1;
  r rformato%rowtype;

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
        dblink2:='set search_path to public,'||f.esquema||';select * from  reporteburo('||''''||pfecha||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	prestamoid integer,
	diasvencidos integer,
	clave character(10),
	nombre text,
	fecha_reporte char(8),
	clavesocioint character(15),
	paterno character varying(20),
	materno character varying(20),
	adicional character varying(40),
	primer_nombre character varying(40),
	segundo character varying(40),
	fecha_nac character(8),
	rfc character varying(13),
	prefijo character varying(10),
	edo_civil character varying(8),
	sexo character(1),
	f_def date,
	indic_def character varying(2),
	calle_numero character varying(80),
	segunda_linea character varying(80),
	colonia character varying(100),
	municipio character varying(100),
	ciudad character varying(100),
	estado character varying(4),
	cp character varying(15),
	telefono character varying(20),
    empresa character varying(40),
	calle_numero_1 character varying(40),
	direccion_complemento_1 character varying(40),
	colonia_1 character varying(40),
	municpio_1 character varying(40),
	ciudad_1 character varying(40),
	estado_1 character varying(40),
	cp_1 character varying(15),
	telefono_1 character varying(4),
	salario character varying(4),
	clave_otorgante_1 character(10),
	nombre_2 character varying(100),
	referenciaprestamo character(18),
	cuenta character varying(19),
	responsabilidad character varying(2),
	tipo_cta character varying(2),
	tipo_contrato character varying(3),
	moneda character varying(3),
	num_pagos integer,
	frec_pagos character varying(2),
	apertura char(8),
	importe_pago numeric,
	pago char(8),
	compra char(8),
	cierre character varying(8),
	reporte char(8),
	cred_maximo numeric,
	saldo_actual numeric,
	limite_credito numeric,
	saldo_vencido numeric,
	pagos_vencidos numeric,
	forma_pago_actual character varying(3),
	observacion character varying(80),
	member_ant character varying(10),
	nombre_ant character varying(30),
	numero_ant character varying(10))
        loop
       --   r.clave:=i;
        --  i:=i+1;
          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

