drop TYPE rbajassioef cascade;
CREATE TYPE rbajassioef AS (
	sucursal character(4),
	clave_socio_cliente character varying(18), 
	grupo character varying(25),
        nombre character varying(100),
	domicilio character varying(150),
	comunidad character varying(150),
	cp int,
	fecha_alta date,
	fecha_baja date,
	motivobaja character varying(30),
	tiposocio character varying(12),
	estatusocio character varying(12),
	sexo character varying(10),
	fecha_nacimiento date,
	ocupacion character varying(40)
	

);
CREATE or replace FUNCTION spsbajassioef(date,date,character varying) RETURNS SETOF rbajassioef
    AS $_$
declare

	pfechaini  alias for $1;
	pfechafin  alias for $2;
	ptiposocio  alias for $3;
	
  r rbajassioef%rowtype;
  
  i int;
begin

  i:=1;
  for r in
       select
		  substring((s.clavesocioint),1,4),
		  s.clavesocioint,
		  si.grupo,
		  substring(su.nombre||' '||su.paterno||' '||su.materno,1,30),
		  substring((d.calle)||' '||(d.numero_ext),1,30),
	          d.comunidad,
 		  d.codpostal,
		  s.fechaalta,
		  s.fechabaja,
		  ba.descripcionmotivo,
		  (case when s.tiposocioid='01' then 'MENOR' else 'MAYOR' end),
		  (case when s.estatussocio=1 then 'ALTA' else (case when s.estatussocio=3 then 'REACTIVACION' else 'BAJA' end) end),
		  sexo(si.sexo),
		  su.fecha_nacimiento,
		  si.ocupacion
		 
                  from socio s, sujeto su, solicitudingreso si, domicilio d,motivobaja ba 
                  where s.fechabaja  >= pfechaini and 
			s.fechabaja <= pfechafin and 
			s.tiposocioid=ptiposocio and 
			s.socioid=si.socioid and 
			s.motivobajaid=ba.motivobajaid and 
			su.sujetoid = s.sujetoid and
			d.sujetoid=s.sujetoid order by s.fechaalta

    loop
   	     
	
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION spsbajassioefc(date,date,character) RETURNS SETOF rbajassioef
    AS $_$
declare

  	pfechaini  alias for $1;
	pfechafin  alias for $2;
	ptiposocio  alias for $3;
 
  r rbajassioef%rowtype;

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
	dblink2:='set search_path to public,'||f.esquema||';select * from  spsbajassioef('||''''||pfechaini||''''||','||''''||pfechafin||''''||||','||''''||ptiposocio||''''||');';
        
      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	sucursal character(4),
	clave_socio_cliente character varying(18), 
	grupo character varying(25),
        nombre character varying(100),
	domicilio character varying(150),
	comunidad character varying(150),
	cp int,
	fecha_alta date,
	fecha_baja date,
	motivobaja character varying(30),
	tiposocio character varying(12),
	estatusocio character varying(12),
	sexo character varying(10),
	fecha_nacimiento date,
	ocupacion character varying(40)
	
	
)
        loop

          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

