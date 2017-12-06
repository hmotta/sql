--
-- Name: rreporte1; Type: TYPE; Schema: public; Owner: sistema
--
--2.- Reporte Socios PATMIR
--Clave, Nombre, Sucursal,Dirección, Colonia, Ciudad, Actividad, Sexo, Fecha Nac, Edo Civil, Edad, Parte social, Aportación Social, Ahorro, Plazo fijo.

select * from llenaconoceatucliente();

drop TYPE rgeneralsocios cascade;
CREATE TYPE rgeneralsocios AS (
	clavesocioint character(15),
        grupo  character(25),
        tiposocioid character(2),
        personajuridica character(10),
	nombre character varying(80),
	sucursal character(4),        
        direccion character varying(80),
        colonia character varying(50),
        comunidadmigrada character varying(50),
        ciudadsepomex  character varying(50),       
        claveestadoconapo character varying(10),
        clavemunicipioconapo character varying(10),
        clavelocalidadconapo char(10),
        municipioconapo character varying(100),
        localidadconapo character varying(100),
        Parte_Social_PA numeric,
        Parte_Adicional_PB numeric,
        Parte_P3 numeric,
        profesion character varying(40),
        ocupacion character varying(40),
        sexo character(15),
        fecha_nacimiento date,
        estado_civil character(15),
        fechaingreso date,
        numerohabitantes integer,
	GRADO_DE_MARGINACIoN character(15),
        POBLACIoN_INDiGENA char(2),
        SALDO_AHORRO numeric,
        fechaultimoahorro date,
        SALDO_PROMEDIO_inver numeric,
        fechaultimoinversion date,
	edad integer
);


CREATE or replace FUNCTION generalsocios(date) RETURNS SETOF rgeneralsocios
    AS $_$
declare

  r rgeneralsocios%rowtype;
  pfechac alias for $1;

  f record;

begin

    for r in

        select

        s.clavesocioint,
        si.grupo,
        s.tiposocioid,
        (case when si.personajuridicaid= 0 then 'FISICA' else 'MORAL' end) as  personajuridica, 
        ltrim(su.nombre)||' '||ltrim(su.paterno)||' '||ltrim(su.materno),
        (select sucid from empresa where empresaid=1) as sucursal,
        d.calle||d.numero_ext as direccion,
        col.nombrecolonia,
        d.comunidad,
        cd.nombreciudadmex,
        --claveestadoconapo character varying(10),
        --(select substring(claveconapo,1,2) from comunidadconapo where claveconapo=ce.comunidadconapo) ,
        --clavemunicipioconapo character varying(10),
        --' '||(select substring(claveconapo,3,3) from comunidadconapo where claveconapo=ce.comunidadconapo),
        --clavelocalidadconapo char(10),
        --(select claveconapo from comunidadconapo where claveconapo=ce.comunidadconapo),
        --(select nombremun from comunidadconapo where claveconapo=ce.comunidadconapo),
        --localidadconapo character varying(50),
        --(select nombre from comunidadconapo where claveconapo=ce.comunidadconapo),        
        sum(sd.PA) as parteadicional,
        sum(sd.PB) as partesocial,
        sum(sd.P3) as partep3,
        si.profesion,
        si.ocupacion,
        (case when si.sexo= 0 then 'Masculino' else 'Femenino' end) as  sexo,
        su.fecha_nacimiento,
        estadocivil(si.estadocivilid) as estadocivil,
        s.fechaalta,
        --(select poblacion from comunidadconapo where claveconapo=ce.comunidadconapo),
        --(select marginacion from comunidadconapo where claveconapo=ce.comunidadconapo),
        --ce.poblacionindigena,
        sum(sd.ahorro) as saldoahorro,
        (select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=s.socioid and mc.tipomovimientoid in
        	('AO','AC','AA','AF','AP') and mc.polizaid=p.polizaid and p.tipo <> 'W' and p.fechapoliza < pfechac+1 ),
        sum(sd.plazofijo) as plazofijo, --este es el saldo_promedio_inver
        (select max(p.fechapoliza) from movicaja mc, polizas p where mc.socioid=s.socioid and mc.tipomovimientoid ='IN' and mc.polizaid=p.polizaid and p.fechapoliza < pfechac+1 ),
		trunc((pfechac-su.fecha_nacimiento)/365) as edad

        from socio s, sujeto  su, solicitudingreso si, domicilio d, colonia col, ciudadesmex cd, --conoceatucliente ce,

        (select mc.socioid, sum(mp.debe)-sum(mp.haber) as PA,0 as PB,0 as P3, 0 as ahorro, 0 as plazofijo, 0 as prestamo, 0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='PA' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1  group by mc.socioid  union 

        select mc.socioid,0 as PA, sum(mp.debe)-sum(mp.haber) as PB,0 as P3,0 as ahorro, 0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='PB' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

 select mc.socioid,0 as PA,0 as PB , sum(mp.debe)-sum(mp.haber) as P3,0 as ahorro, 0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='P3' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

        select mc.socioid,0 as PA,0 as PB,0 as P3,sum(mp.debe)-sum(mp.haber) as ahorro,0 as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid in ('AO','AC','AA','AF','AP') and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid union

        select mc.socioid,0 as PA,0 as PB,0 as P3,0 as ahorro,sum(mp.haber)-sum(mp.debe) as plazofijo,0 as prestamo,0 as prestamoid from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mc.polizaid=mp.polizaid and (mp.cuentaid=tm.cuentadeposito or mp.cuentaid=2102010108) and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid='IN' and p.polizaid = mc.polizaid and p.fechapoliza < pfechac+1 and tm.aplicasaldo='S' group by mc.socioid) sd

        where s.fechaalta < pfechac+1 and  s.sujetoid=su.sujetoid and s.socioid=si.socioid and s.socioid=sd.socioid and d.sujetoid=su.sujetoid and d.coloniaid=col.coloniaid and col.ciudadmexid=cd.ciudadmexid and su.sujetoid = ce.sujetoid  
 
        group by  s.clavesocioint,si.grupo,s.tiposocioid,si.personajuridicaid,ltrim(su.nombre)||' '||ltrim(su.paterno)||' '||ltrim(su.materno),s.fechaalta,col.coloniaid,d.calle,d.numero_ext,d.comunidad,col.nombrecolonia,cd.nombreciudadmex,si.profesion,si.ocupacion,su.fecha_nacimiento,s.socioid,si.sexo,si.estadocivilid,si.profesion,ce.poblacionindigena,ce.comunidadconapo order by s.clavesocioint

        loop
            
            return next r;

        end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

--
-- Name: generalsociosc(date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION generalsociosc(date) RETURNS SETOF rgeneralsocios
    AS '
declare

  r rgeneralsocios%rowtype;

  pfechai alias for $1;
  f record;

  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente=''S''
 loop
        raise notice ''Conectando sucursal % % '',f.basededatos,f.esquema;

        dblink1:=''host=''||f.host||'' dbname=''||f.basededatos||'' user=''||f.usuariodb||'' password=''||f.passworddb;
        dblink2:=''set search_path to public,''||f.esquema||'';select * from  generalsocios(''||''''''''||pfechai||''''''''||'');'';

--        raise notice ''dblink % % '',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(
        clavesocioint character(15),
        grupo character(25),
        tiposocioid character(2),
        personajuridica character(10),
	nombre character varying(80),
	sucursal character(4),        
        direccion character varying(80),
        colonia character varying(50),
        comunidadmigrada character varying(50),
        ciudadsepomex  character varying(50),       
        claveestadoconapo character varying(10),
        clavemunicipioconapo character varying(10),
        clavelocalidadconapo char(10),
        municipioconapo character varying(100),
        localidadconapo character varying(100),
        Parte_Social_PA numeric,
        Parte_Adicional_PB numeric,
        Parte_P3 numeric,
        profesion character varying(40),
        ocupacion character varying(40),
        sexo character(15),
        fecha_nacimiento date,
        estado_civil character(15),
        fechaingreso date,
        numerohabitantes integer,
	GRADO_DE_MARGINACIoN character(15),
        POBLACIoN_INDiGENA char(2),
        SALDO_PROMEDIO_AHORRO numeric,
        fechaultimoahorro date,
        SALDO_PROMEDIO_inver numeric,
        fechaultimoinversion date,
	edad integer)

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
