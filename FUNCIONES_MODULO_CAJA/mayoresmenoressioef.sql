drop TYPE rmayoresmenoressioef cascade;
CREATE TYPE rmayoresmenoressioef AS (
	sucursal character(4),
	clavesocioint character varying(18), 
	nombre text,
	oficina text,
	estado text,
	municipio text,
	colonia  text,
	comunidad text,
	domicilio text,
	num_domicilio text,
	aportacion numeric,
	actividad_productiva text,
	sexo text,
	fecha_nacimiento date,
	estado_civil text,
	fecha_ingreso date 

);
CREATE or replace FUNCTION spsmayoresmenoressioef(date,character varying) RETURNS SETOF rmayoresmenoressioef
    AS $_$
declare

	pfechaini  alias for $1;
	ptiposocio  alias for $2;
	
	
  r rmayoresmenoressioef%rowtype;
  
  i int;
begin

  i:=1;
  for r in
		select 

			substring((s.clavesocioint),1,4),			
			s.clavesocioint, 
			su.nombre||' '||su.paterno||' '||su.materno,
		 	substring((s.clavesocioint),1,3),
			es.nombreestadomex,
			cd.nombreciudadmex,
			ncol.nombrecolonia,
		 	d.comunidad,
			d.calle,
			d.numero_int||' '||d.numero_ext , 
			saldomov(s.socioid,'PA',current_date), 
			si.ocupacion,
			sexo(si.sexo),
			su.fecha_nacimiento, 
			estadocivil(si.estadocivilid),
			si.fechaingreso 
			from socio s, sujeto su, domicilio d,colonia ncol, ciudadesmex cd, solicitudingreso si, estadosmex es 
			where s.sujetoid = su.sujetoid and 
			      su.sujetoid = d.sujetoid and
			      d.coloniaid = ncol.coloniaid and
			      d.ciudadmexid = cd.ciudadmexid and 
			      cd.estadomexid=es.estadomexid and 
			      s.socioid = si.socioid  and
			      s.tiposocioid=ptiposocio  and
		 	      si.fechaingreso<=pfechaini
		  	      order by s.clavesocioint

	loop
   	     
	
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION spsmayoresmenoressioefc(date,character varying) RETURNS SETOF rmayoresmenoressioef
    AS $_$
declare

  	pfechaini  alias for $1;
	ptiposocio  alias for $2;
	
 
  r rmayoresmenoressioef%rowtype;

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
	dblink2:='set search_path to public,'||f.esquema||';select * from  spsmayoresmenoressioef('||''''||pfechaini||''''||','||''''||ptiposocio||''''||');';
        
      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	sucursal character(4),
	clavesocioint character varying(18), 
	nombre text,
	oficina character varying(3),
	estado text,
	municipio text,
	colonia  text,
	comunidad text,
	domicilio text,
	num_domicilio text,
	aportacion numeric,
	actividad_productiva text,
	sexo text,
	fecha_nacimiento date,
	estado_civil text,
	fecha_ingreso date 
	
	
)
        loop

          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

