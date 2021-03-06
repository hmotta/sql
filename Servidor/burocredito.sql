--Modificado Para Cooperativa Yolomecatl el dia 05/10/2011 by Hmota

--alter table estadosmex add abre_estado char(3);
--alter table precorte add importeultimaamort numeric;
--alter table precorte add importevencidoamort numeric;

drop TYPE rformato cascade;
CREATE TYPE rformato AS (
	clave character(10),
	nombre text,
	fecha_reporte char(8),
	paterno character varying(26),
	materno character varying(26),
	adicional character varying(26),
	primer_nombre character varying(100),
	segundo character varying(100),
	fecha_nac character(8),
	rfc character varying(13),
	prefijo character varying(4),
	edo_civil character (1),
	sexo character(1),
	f_def date,
	indic_def character varying(1),
	calle_numero character varying(90),
	segunda_linea character varying(40),
	colonia character varying(40),
	municipio character varying(40),
	ciudad character varying(40),
	estado character varying(4),
	cp character (5),
	telefono character varying(11),
    empresa character varying(40),
	calle_numero_1 character varying(40),
	direccion_complemento_1 character varying(40),
	colonia_1 character varying(40),
	municpio_1 character varying(40),
	ciudad_1 character varying(40),
	estado_1 character varying(4),
	cp_1 character varying(5),
	telefono_1 character varying(11),
	salario character varying(9),
	clave_otorgante_1 character(10),
	nombre_2 text,
	cuenta character varying(25),
	responsabilidad character (1),
	tipo_cta character (1),
	tipo_contrato character (2),
	moneda character (2),
	num_pagos integer,
	frec_pagos character(1),
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
	forma_pago_actual character varying(2),
	observacion character (2),
	member_ant character varying(10),
	nombre_ant character varying(30),
	numero_ant character varying(10)
);



CREATE or replace FUNCTION reporteburo(date) RETURNS SETOF rformato
    AS $_$
declare

  pfecha alias for $1;
  r rformato%rowtype;
  pposicion integer;
  pnombre character varying(40);
  i int;
begin

  i:=1;
  for r in
       select
       --1 clave
       'SS10340001',
       --2 nombre 
       'PRUEBA',
       --3 fecha_reporte
       trim(to_char(pfecha,'DDMMYYYY')),
       --4 paterno	
       (case when su.paterno = null or su.paterno = ' ' or su.paterno = '' or su.paterno = 'X' then 'NO PROPORCIONADO' else trim(su.paterno) end),
       --5 materno
       (case when su.materno = null or su.materno = ' ' or su.materno = '' or su.materno = 'X' then 'NO PROPORCIONADO' else trim(su.materno) end),
       --6 adicional
       '',
       --7 primer_nombre
       trim(su.nombre),
	   --(case when position(' ' in trim(su.nombre)) > 3 then substring(trim(su.nombre),0,position(' ' in trim(su.nombre))) else trim(su.nombre) end),
       --8 segundo_nombre
       '',--substring(trim(su.nombre),position(' ' in trim(su.nombre))+1,character_length(trim(su.nombre))),--'',
       --9 fecha_nac
       trim(to_char(su.fecha_nacimiento,'DDMMYYYY')),
       --10 rfc
       substring(trim(su.rfc),1,13),
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
       upper(trim(d.calle)||' '||trim(d.numero_ext)),
       --17 direccion_complemento
       '',
       --18 colonia_o_pob
       (case when character_length(trim(col.nombrecolonia))>40 then '' else trim(col.nombrecolonia) end),
       --19 municipio
       trim(c.nombreciudadmex),--rtrim(d.comunidad),
       --20 ciudad
       '',--rtrim(c.nombreciudadmex),
       --21 estado
       trim(e.abre_estado),
       --22 cp
       lpad(trim(to_char(col.cp,'99999')),5,'0'),
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
       'SS10340001',
       --35 nombre del otorgante
       'PRUEBA',
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
       (case when p.meses_de_cobro=2 then 'B' else (case when p.meses_de_cobro=3 then 'Q' else ( case when p.dias_de_cobro=7then 'W' else ( case when p.dias_de_cobro=14 then 'K' else ( case when p.dias_de_cobro=15 then 'S' else 'M' end) end) end) end) end),
	   --43 fecha_apertura
       to_char(p.fecha_otorga,'DDMMYYYY'),
       --44 importe_pago
	   (case when importevencidoamort > importeultimaamort then trunc(importevencidoamort+interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor) else (case when importeultimaamort < pr.saldoprestamo then trunc(interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor+importeultimaamort) else  trunc(pr.saldoprestamo+interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor) end) end),
       --(case when trunc(((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)+importeultimaamort) <  trunc(pr.saldoprestamo+((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)) then trunc(((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)+importeultimaamort) else  trunc(pr.saldoprestamo+((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)) end),
	   --(case when cc.capital > importeultimaamort then trunc((cc.capital+cc.interes)*1.00) else trunc((importeultimaamort+cc.interes)*1.00) end),
       --45 pago_ultimo_pago
	   to_char(pr.ultimoabono,'DDMMYYYY'),
       --to_char(pr.fechaultamorpagada,'DDMMYYYY'),
       --46 fecha_ultima_compra
       null,--to_char(p.fecha_otorga,'DDMMYYYY'),
       --47 fecha_cierre_credito
       (case when pr.saldoprestamo=0 then to_char(pr.ultimoabono,'DDMMYYYY') else '' end),
       --48 fecha_reporte
       to_char(pfecha,'DDMMYYYY'),
       --49 credito_maximo
       trunc(p.montoprestamo),
       --50 saldo_actual El saldo m�s todos los intereses.
       trunc(pr.saldoprestamo+((interesdevengadomenoravencido+interesdevengadomayoravencido+interesdevmormenor+interesdevmormayor)*1.00)),
	   --trunc((cc.saldoprest+cc.interes+cc.moratorio)*1.00),
       --51 limite_credito
       null,--trunc(p.montoprestamo),
       --52 saldo_vencido
       (case when pr.diascapital>=15 then (trunc(importevencidoamort)) else 0 end),
       --53 numero_pagos_vencidos
       --(case when pr.importevencidoamort=0 then 0 else pr.noamorvencidas end),
       (case when pr.diascapital>=15 then pr.noamorvencidas else 0 end),
       --54 forma_pago_mop
	   (case when pr.diascapital>=15 then(case when pr.importevencidoamort=0 then '01' else (case when pr.diascapital >=1 and pr.diascapital <=29 then '02' else (case when pr.diascapital >29 and pr.diascapital <=59 then '03' else (case when pr.diascapital >59 and pr.diascapital <=89 then '04' else (case when pr.diascapital >89 and pr.diascapital <=119 then '05' else  (case when pr.diascapital >119 and pr.diascapital <=149 then '06' else (case when pr.diascapital >149 and pr.diascapital <=360 then '07' else (case when pr.diascapital >360 and pr.diascapital <=389 then '96' else '96' end) end) end)end) end) end) end) end) else '01' end),
	   --55 clave_observacion
       (select clave from carteraclaveburo where prestamoid=pr.prestamoid),
	   --56 clave_anterior_otorgante
       '',
	   --57 nombre_anterior_otorgante
       '',
	   --58 numero_cta_anterior
       ''
       from precorte pr, prestamos p, socio s, solicitudingreso so, sujeto su, domicilio d, colonia col, ciudadesmex c, estadosmex e
       where pr.fechacierre = pfecha and  s.tiposocioid = '02' and so.personajuridicaid = 0 and 
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
	
	
	pnombre := r.primer_nombre;
	pposicion := position(' ' in pnombre);
	IF pposicion > 3 THEN
		r.primer_nombre:=substring(pnombre,0,pposicion);
		r.segundo :=substring(pnombre,pposicion+1,character_length(pnombre));
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
	clave character(10),
	nombre text,
	fecha_reporte char(8),
	paterno character varying(26),
	materno character varying(26),
	adicional character varying(26),
	primer_nombre character varying(100),
	segundo character varying(100),
	fecha_nac character(8),
	rfc character varying(13),
	prefijo character varying(4),
	edo_civil character (1),
	sexo character(1),
	f_def date,
	indic_def character varying(1),
	calle_numero character varying(90),
	segunda_linea character varying(40),
	colonia character varying(40),
	municipio character varying(40),
	ciudad character varying(40),
	estado character varying(4),
	cp character (5),
	telefono character varying(11),
    empresa character varying(40),
	calle_numero_1 character varying(40),
	direccion_complemento_1 character varying(40),
	colonia_1 character varying(40),
	municpio_1 character varying(40),
	ciudad_1 character varying(40),
	estado_1 character varying(4),
	cp_1 character varying(5),
	telefono_1 character varying(11),
	salario character varying(9),
	clave_otorgante_1 character(10),
	nombre_2 text,
	cuenta character varying(25),
	responsabilidad character (1),
	tipo_cta character (1),
	tipo_contrato character (2),
	moneda character (2),
	num_pagos integer,
	frec_pagos character(1),
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
	forma_pago_actual character varying(2),
	observacion character (2),
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

