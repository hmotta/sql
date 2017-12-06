drop TYPE rformatosociopatmirv2 cascade;
CREATE TYPE rformatosociopatmirv2 AS (
	folio_if character varying(5),							--01
	clave_socio_cliente character varying(18),				--02
	primer_apellido character varying(26),					--03
	segundo_apellido character varying(26),					--04
	nombre character varying(100),							--05
	sexo character varying(10),   							--06
	fecha_de_nacimiento character(10),						--07
	lengua character varying(15),							--08
	ocupacion character varying(40),						--09
	actividad_productiva character varying(40),				--10
	estado_civil character varying(14),						--11
	escolaridad character varying(12),						--12
	fecha_alta_en_sistema character(10),					--13
	calle character varying(90),							--14
	numero_exterior character varying(15),					--15
	numero_interior character varying(15),					--16
	colonia character varying(100),							--17
	codigo_postal character(5),								--18
	localidad character varying(49),						--19
	municipio character varying(40),						--20
	estado character varying(50),							--21
	capital_social_requerido character varying(12),					--22
	--requerido character varying(12),						--23
	saldo_de_aportacion_requerido character varying(12),	--24
	saldo_de_aportacion_excedente character varying(12),	--25
	saldo_de_aportacion_voluntario character varying(12),	--26
	sucursal character varying(35),							--27
	usuario_captura character varying(20),					--28
	fecha_baja character(10),								--29
	persona_moral character(10)								--30
);

CREATE or replace FUNCTION spssociopatmirv2(date, date) RETURNS SETOF rformatosociopatmirv2
    AS $_$
declare
  pfechainicio alias for $1;
  pfechafinal alias for $2;


  r rformatosociopatmirv2%rowtype;
  pposicion integer;
--pnombre character varying(40);
  i int;
begin
  i:=1;
  for r in
       select
--01 folio_if character varying(5)
'0017',
--02 clave_socio_cliente character varying(18)
trim(s.clavesocioint),
--03 primer_apellido character varying(26)
spatmir((case when su.paterno = null or su.paterno = ' ' or su.paterno = '' or su.paterno = 'X' then 'NO PROPORCIONADO' else trim(su.paterno) end)),
--04 segundo_apellido character varying(26)
spatmir((case when su.materno = null or su.materno = ' ' or su.materno = '' or su.materno = 'X' then '' else trim(su.materno) end)),
--05 nombre character varying(100)
spatmir(trim(su.nombre)),
--06 ssexo character varying(10)
(case when so.sexo=0 then 'masculino' else 'femenino' end),
--07 fecha_de_nacimiento character(10)
trim(to_char(su.fecha_nacimiento,'DD/MM/YYYY')),
--08 lengua character varying(15)
'NO ESPECIFICA',
--09 ocupacion character varying(40)
'9999',
--10 actividad_productiva character varying(40)
'NO ESPECIFICA', 
--11 estado_civil character varying(14)
(case when so.estadocivilid=0 then 'SOLTERO' else (case when so.estadocivilid=1 then 'CASADO' else (case when so.estadocivilid=2 then 'VIUDO' else (case when so.estadocivilid=3 then 'DIVORCIADO' else 'UNION LIBRE' end) end) end) end),
--12 escolaridad character varying(12)
(case when so.nivelestudiosid=0 then 'NINGUNA' else (case when so.nivelestudiosid=1 then 'PRIMARIA' else (case when so.nivelestudiosid=2 then 'SECUNDARIA' else (case when so.nivelestudiosid=3 then 'BACHILLERATO' else (case when so.nivelestudiosid=4 then 'LICENCIATURA' else (case when so.nivelestudiosid=5 then 'POSGRADO' else 'POSGRADO' end) end) end) end) end) end),
--13 fecha_alta_en_sistema character(10)
to_char(so.fechaingreso,'DD/MM/YYYY'),
--14 calle character varying(90)
spatmir(upper(trim(d.calle))),
--15 numero_exterior character varying(15)
RTrim(d.numero_ext),
--16 numero_interior character varying(15)
RTrim(d.numero_int),
--17 colonia character varying(100)
spatmir((case when character_length(trim(col.nombrecolonia))>100 then '' else trim(col.nombrecolonia) end)),
--18 codigo_postal character(5)
lpad(trim(to_char(col.cp,'99999')),5,'0'),
--19 localidad character varying(49)
spatmir((case when character_length(trim(d.comunidad))>49 then '' else trim(d.comunidad) end)),
--20 municipio character varying(40)
spatmir(case when c.nombreciudadmex='SANTA MARIA CHILAPA DE DIAZ' then 'VILLA DE CHILAPA DE DIAZ' else  ( case when c.nombreciudadmex='GUSTAVO A MADERO' then 'GUSTAVO A. MADERO' else ( case when c.nombreciudadmex='CHICOLOAPAN DE JUAREZ' then 'CHICOLOAPAN' else RTrim(c.nombreciudadmex) end)  end) end ),--rtrim(d.comunidad),
--21 estado character varying(50)
spatmir(case when e.nombreestadomex='VERACRUZ LLAVE' then 'VERACRUZ' else  ( case when e.nombreestadomex='MICHOACÁN DE OCAMPO' then 'MICHOACAN' else RTrim(e.nombreestadomex) end) end ),

--22 capital_social_requerido character varying(12)---------ok
(case when (select sum(mp.debe)-sum(mp.haber) as saldo from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.socioid=s.socioid and mp.movipolizaid=mc.movipolizaid and  mc.tipomovimientoid='PA' and tm.tipomovimientoid=mc.tipomovimientoid and tm.aplicasaldo='S' and mc.polizaid=p.polizaid and mp.polizaid=p.polizaid and p.fechapoliza<=pfechafinal)  > 0 then '500.00' else '0' end),

--23 requerido character varying(12) -------x definir 
--(case when to_char((select sum(mp.debe)-sum(mp.haber) as saldo from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.socioid=s.socioid and mp.movipolizaid=mc.movipolizaid and  mc.tipomovimientoid='PA' and tm.tipomovimientoid=mc.tipomovimientoid and tm.aplicasaldo='S' and mc.polizaid=p.polizaid and mp.polizaid=p.polizaid and p.fechapoliza<=pfechafinal), '999999.99') > 0 then to_char((select sum(mp.debe)-sum(mp.haber) as saldo from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.socioid=s.socioid and mp.movipolizaid=mc.movipolizaid and  mc.tipomovimientoid='PA' and tm.tipomovimientoid=mc.tipomovimientoid and tm.aplicasaldo='S' and mc.polizaid=p.polizaid and mp.polizaid=p.polizaid and p.fechapoliza<=pfechafinal), '999999.99') else '0' end),


--24 saldo_de_aportacion_requerido character varying(12)  --- ok
(case when to_char((select sum(mp.debe)-sum(mp.haber) as saldo from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.socioid=s.socioid and mp.movipolizaid=mc.movipolizaid and  mc.tipomovimientoid='PA' and tm.tipomovimientoid=mc.tipomovimientoid and tm.aplicasaldo='S' and mc.polizaid=p.polizaid and mp.polizaid=p.polizaid and p.fechapoliza<=pfechafinal), '999999.99') > 0 then to_char((select sum(mp.debe)-sum(mp.haber) as saldo from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.socioid=s.socioid and mp.movipolizaid=mc.movipolizaid and  mc.tipomovimientoid='PA' and tm.tipomovimientoid=mc.tipomovimientoid and tm.aplicasaldo='S' and mc.polizaid=p.polizaid and mp.polizaid=p.polizaid and p.fechapoliza<=pfechafinal), '999999.99') else '0' end),

--25 saldo_de_aportacion_excedente character varying(12)  ---- ok 
'0.00',


--26 saldo_de_aportacion_voluntario character varying(12) ---- definir que productos 

(case when (select sum(saldo) FROM spssaldosmov(s.socioid) where saldo>0 and desctipomovimiento in ('PARTE SOCIAL ADICIONAL PSO','PARTE SOCIAL ADICIONAL PSV')) > 0  then (select sum(saldo) FROM spssaldosmov(s.socioid) where saldo>0 and desctipomovimiento in ('PARTE SOCIAL ADICIONAL PSO','PARTE SOCIAL ADICIONAL PSV')) else '0' end), 


--27 sucursal character varying(4)
(select Rtrim(nombresucursal) from empresa where empresaid=1),
--28 usuario_captura character varying(20)
rtrim(so.usuarioid),
--29 fecha_baja character(10)
(case when s.fechabaja>pfechafinal then null else to_char(s.fechabaja,'DD/MM/YYYY') end),
--30 persona_moral character(10)
(case when so.personajuridicaid=0 then '0' else '1' end)

	from socio s, 
			solicitudingreso so,
			sujeto su, domicilio d,
			colonia col,
			ciudadesmex c,
			estadosmex e
			--inversion inv
	where s.tiposocioid in ('02','01','05') 
			--and so.personajuridicaid = 0 
			--and s.estatussocio<>3
			--and s.socioid=inv.socioid
			and su.sujetoid=s.sujetoid 
			and so.socioid=s.socioid 
			and d.sujetoid=su.sujetoid
			and col.coloniaid=d.coloniaid 
			and c.ciudadmexid=d.ciudadmexid 
			and e.estadomexid=c.estadomexid 
			and su.paterno not in ('CAJA','CAJA ','CAJA1','CAJA2','PREMIOS ESTATALES','CHEQUE','ENVIO DE','SERVICIO','ATLAS-PARALIFE','ARGOS','OPORTUNIDADES','TELCEL','MOVISTAR','IUSACELL','REMESAS','COMISION','YOLOMECATL','SKY','CFE','CABLEMAS','MEGACABLE','TAU UNEFON','ENVIO DE') 
			and su.nombre not in  ('MT CENTER','EXBRACEROS','CAJA','PAGO','INTERMEX','OPORTUNIDADES')
			and so.ocupacion not in  ('CAJERA                                  ','CAJERA                                  ')
			--and s.clavesocioint 
			and so.fechaingreso between pfechainicio and pfechafinal 
			order by su.paterno,su.materno,su.nombre
  loop
   -- r.clave:=i;
    --i:=i+1;
	--IF r.paterno = 'NO PROPORCIONADO' AND r.materno <> 'NO PROPORCIONADO' THEN
	--r.paterno = r.materno; r.materno = 'NO PROPORCIONADO';
	--END IF;
	--pnombre := r.primer_nombre;
	--pposicion := position(' ' in pnombre);
	--IF pposicion > 3 THEN
	--r.primer_nombre:=substring(pnombre,0,pposicion);
	--r.segundo :=substring(pnombre,pposicion+1,character_length(pnombre));
	--END IF;
	raise notice 'Estoy Socio: %',r.clave_socio_cliente;
   return next r;
 end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.spssociopatmir(date, date) OWNER TO sistema;

--
-- Name: spssociopatmirc(date, date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION spssociopatmircv2(date, date) RETURNS SETOF rformatosociopatmirv2
    AS $_$
declare

  pfechainicio alias for $1;
  pfechafinal alias for $2;
  r rformatosociopatmirv2%rowtype;

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
        dblink2:='set search_path to public,'||f.esquema||';select * from  spssociopatmirv2('||''''||pfechainicio||''''||','||''''||pfechafinal||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	folio_if character varying(5),							--01
	clave_socio_cliente character varying(18),				--02
	primer_apellido character varying(26),					--03
	segundo_apellido character varying(26),					--04
	nombre character varying(100),							--05
	sexo character varying(10),   							--06
	fecha_de_nacimiento character(10),						--07
	lengua character varying(15),							--08
	ocupacion character varying(40),						--09
	actividad_productiva character varying(40),				--10
	estado_civil character varying(14),						--11
	escolaridad character varying(12),						--12
	fecha_alta_en_sistema character(10),					--13
	calle character varying(90),							--14
	numero_exterior character varying(15),					--15
	numero_interior character varying(15),					--16
	colonia character varying(100),							--17
	codigo_postal character(5),								--18
	localidad character varying(49),						--19
	municipio character varying(40),						--20
	estado character varying(50),							--21
	capital_social_requerido character varying(12),					--22
	--requerido character varying(12),						--23
	saldo_de_aportacion_requerido character varying(12),	--24
	saldo_de_aportacion_excedente character varying(12),	--25
	saldo_de_aportacion_voluntario character varying(12),	--26
	sucursal character varying(35),							--27
	usuario_captura character varying(20),					--28
	fecha_baja character(10),								--29
	persona_moral character(10)								--30
)
	
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


ALTER FUNCTION public.spssociopatmirc(date, date) OWNER TO sistema;

--
-- Name: spssocioprestamo(text); Type: FUNCTION; Schema: public; Owner: sistema
--
