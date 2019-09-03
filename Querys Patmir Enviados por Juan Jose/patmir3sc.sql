--
--

drop TYPE rpatmir3sc cascade;
CREATE TYPE rpatmir3sc AS (

--FOLIO IF
folio_if integer,
--CLAVE SOCIO/CLIENTE
clave_socio_ciente character(15),
--PRIMER APELLIDO
PRIMER_APELLIDO character varying(40),  
--SEGUNDO APELLIDO
segundo_APELLIDO character varying(40),
--NOMBRE
nombre character varying(40),        
--SEXO
sexo character(15),
--FECHA DE NACIMIENTO
fecha_nacimiento date,
--LENGUA
POBLACIoN_INDiGENA char(2),
--OCUPACION
ocupacion char(60),
--ACTIVIDAD PRODUCTIVA
actividad character varying(100),
--ESTADO CIVIL
estado_civil character(15),
--ESCOLARIDAD
ESCOLARIDAD char(50),
--FECHA ALTA EN SISTEMA
fecha_alta_sistema date,
--CALLE
calle char(50),
--NUMERO EXTERIOR
numero_ext char(15),
--NUMERO INTERIOR
numero_int char(15),
--COLONIA
colonia  char(50),
--CODIGO POSTAL
codpostal integer,
--LOCALIDAD
localidad char(50), 
--MUNICIPIO
municipio char(50),
--ESTADO 
ESTADO char(20),
--SALDO DE APORTACION
parte numeric,
--USUARIO CAPTURA
usuario_captura char(20),
--FECHA BAJA
fecha_baja date

);


CREATE or replace FUNCTION patmir3sc(date,date) RETURNS SETOF rpatmir3sc
    AS $_$
declare

  r rpatmir3sc%rowtype;
  pfecha1 alias for $1;
  pfechac alias for $2;
 
  f record;
  ifolio integer;
  dfechai date;

begin

dfechai:=pfecha1;

ifolio:=1;

    for r in

        select
--FOLIO IF
14,
--CLAVE SOCIO/CLIENTE
s.clavesocioint,
--PRIMER APELLIDO
su.paterno,  
--SEGUNDO APELLIDO
su.materno,
--NOMBRE
su.nombre,        
--SEXO
(case when si.sexo= 0 then 'Masculino' else 'Femenino' end) as  sexo,
--FECHA DE NACIMIENTO
su.fecha_nacimiento,
--LENGUA
ce.poblacionindigena,
--OCUPACION
si.ocupacion,
--ACTIVIDAD PRODUCTIVA
ce.actividad,
--ESTADO CIVIL
estadocivil(si.estadocivilid) as estadocivil,
--ESCOLARIDAD
'',
--FECHA ALTA EN SISTEMA
s.fechaalta,
--CALLE
d.calle,
--NUMERO EXTERIOR
d.numero_ext,
--NUMERO INTERIOR
d.numero_int,
--COLONIA
d.colonia,
--CODIGO POSTAL
d.codpostal,
--LOCALIDAD
d.comunidad, 
--MUNICIPIO
cd.nombreciudadmex,
--ESTADO 
(select nombreestadomex from estadosmex where  estadomexid=cd.estadomexid),
--SALDO DE APORTACION
sum(sd.parte) as parte,
--USUARIO CAPTURA
si.usuarioid,
--FECHA BAJA
s.fechabaja       
       

        from socio s, sujeto  su, solicitudingreso si, domicilio d, colonia col, ciudadesmex cd, conoceatucliente ce,

        (select mc.socioid, sum(mp.debe)-sum(mp.haber) as aportacion,0 as parte, 0 as ahorro, 0 as plazofijo, 0 as prestamo, 0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid ='PB' and p.polizaid = mc.polizaid and p.fechapoliza>=dfechai and p.fechapoliza < pfechac+1  group by mc.socioid  union 

        select mc.socioid,0 as aportacion, sum(mp.debe)-sum(mp.haber) as parte,0 as ahorro, 0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='PA' and p.polizaid = mc.polizaid and p.fechapoliza>=dfechai and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

        select mc.socioid,0 as aportacion,0 as parte,sum(mp.debe)-sum(mp.haber) as ahorro,0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid in ('AA','AC','CU','AM','AR','IP') and p.polizaid = mc.polizaid and p.fechapoliza>=dfechai and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

        select mc.socioid,0 as aportacion,0 as parte,0 as ahorro,sum(mp.haber)-sum(mp.debe) as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.polizaid=mp.polizaid and mp.cuentaid=tm.cuentadeposito and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='IN' and p.polizaid = mc.polizaid and p.fechapoliza>=dfechai and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid) sd

        where s.fechaalta >= dfechai and s.fechaalta < pfechac+1 and  s.sujetoid=su.sujetoid and s.socioid=si.socioid and s.socioid=sd.socioid and d.sujetoid=su.sujetoid and d.coloniaid=col.coloniaid and col.ciudadmexid=cd.ciudadmexid and su.sujetoid = ce.sujetoid  
 
        group by  s.clavesocioint,si.grupo,si.ocupacion,si.usuarioid,s.tiposocioid,si.personajuridicaid,su.paterno,su.materno,su.nombre,s.fechaalta,col.coloniaid,d.calle,d.numero_ext,d.numero_int,d.colonia,d.codpostal,d.comunidad,col.nombrecolonia,cd.estadomexid,cd.nombreciudadmex,si.profesion,su.fecha_nacimiento,s.socioid,si.sexo,si.estadocivilid,ce.actividad,ce.poblacionindigena,ce.comunidadconapo,s.fechabaja order by s.clavesocioint

        loop

            return next r;

        end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

--
-- Name: patmir3scc(date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION patmir3scc(date,date) RETURNS SETOF rpatmir3sc
    AS '
declare

  r rpatmir3sc%rowtype;

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
        dblink2:=''set search_path to public,''||f.esquema||'';select * from  patmir3sc(''||''''''''||pfechai||''''''''||'',''||''''''''||pfechaf||''''''''||'');'';

--        raise notice ''dblink % % '',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(
--FOLIO IF
folio_if integer,
--CLAVE SOCIO/CLIENTE
clave_socio_ciente character(15),
--PRIMER APELLIDO
PRIMER_APELLIDO character varying(40),  
--SEGUNDO APELLIDO
segundo_APELLIDO character varying(40),
--NOMBRE
nombre character varying(40),        
--SEXO
sexo character(15),
--FECHA DE NACIMIENTO
fecha_nacimiento date,
--LENGUA
POBLACIoN_INDiGENA char(2),
--OCUPACION
ocupacion char(60),
--ACTIVIDAD PRODUCTIVA
actividad character varying(100),
--ESTADO CIVIL
estado_civil character(15),
--ESCOLARIDAD
ESCOLARIDAD char(50),
--FECHA ALTA EN SISTEMA
fecha_alta_sistema date,
--CALLE
calle char(50),
--NUMERO EXTERIOR
numero_ext char(15),
--NUMERO INTERIOR
numero_int char(15),
--COLONIA
colonia  char(50),
--CODIGO POSTAL
codpostal integer,
--LOCALIDAD
localidad char(50), 
--MUNICIPIO
municipio char(50),
--ESTADO 
ESTADO char(20),
--SALDO DE APORTACION
parte numeric,
--USUARIO CAPTURA
usuario_captura char(20),
--FECHA BAJA
fecha_baja date

)

        loop
                return next r;
        end loop;

 end loop;

return;
end
'
language 'plpgsql' security definer;




CREATE or replace FUNCTION estadocivil(integer) RETURNS text
    AS $_$
declare
pestadocivil alias for $1;

ptexto text;

begin
  
  if pestadocivil=0 then
    ptexto := 'SOLTERO(A)    ';
  end if;
  if pestadocivil=1 then
    ptexto := 'CASADO(A)   ';
  end if;
    if pestadocivil=2 then
    ptexto := 'DIVORCIADO(A)     ';
  end if;
  if pestadocivil=3 then
    ptexto := 'VIUDO(A) ';
  end if;
  if pestadocivil=4 then
    ptexto := 'UNION LIBRE    ';
  end if;

  return ptexto;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
