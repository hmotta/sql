drop TYPE rcuentasdesbloqueadassioef cascade;
CREATE TYPE rcuentasdesbloqueadassioef AS (
	sucursal character(4),
	clave_socio_cliente character varying(18), 
	nombre_socio character varying(35),
	tiposocio character varying(12),
	motivo character varying(40),
	fecha_desbloqueo date,
	usuario_desbloquea character varying(15),
	estatussocio character varying(15)
	
	

);
CREATE or replace FUNCTION spscuentasdesbloqueadassioef(date,date) RETURNS SETOF rcuentasdesbloqueadassioef
    AS $_$
declare

	pfechaini  alias for $1;
	pfechafin  alias for $2;
	
	
  r rcuentasdesbloqueadassioef%rowtype;
  
  i int;
begin

  i:=1;
  for r in
       select
		  substring((clavesocioint),1,4),
		  clavesocioint,
		  substring(nombre||' '||paterno||' '||materno,1,30),
		  (case when tiposocioid='01' then 'MENOR' else 'MAYOR' end),
		  motivo,
		  fechadesbloqueo,
                  usuariodesbloquea,
                   (case when estatussocio=2 then 'DADO DE BAJA' else  'ACTIVO' end) 
                  from cuentasbloqueadas natural join socio natural join sujeto 
			 where bloqueovigente='N' and 
				fechadesbloqueo >= pfechaini and
				fechadesbloqueo <= pfechafin

		 

    loop
   	     
	
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION spscuentasdesbloqueadassioefc(date,date) RETURNS SETOF rcuentasdesbloqueadassioef
    AS $_$
declare

  	pfechaini  alias for $1;
	pfechafin  alias for $2;
	
 
  r rcuentasdesbloqueadassioef%rowtype;

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
	dblink2:='set search_path to public,'||f.esquema||';select * from  spscuentasdesbloqueadassioef('||''''||pfechaini||''''||','||''''||pfechafin||''''||');';
        
      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	sucursal character(4),
	clave_socio_cliente character varying(18), 
	tiposocio character varying(12),
	motivo character varying(40),
	fecha_desbloqueo date,
	usuario_desbloquea character varying(15),
	estatussocio character varying(15)
	
	
)
        loop

          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

