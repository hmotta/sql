drop type rclasificacion cascade;
create type rclasificacion AS (
	clavesocioint  character(15),
	nombre character varying(80),
	pagospactados integer,
	pagosenmora  integer,
	creditospagados integer,
	creditosvigentes integer,
	saldototal numeric,
	diasatrasomaximo integer,
	montoultimocred numeric,
	montomaximocred numeric,
	correccionxanios numeric,
	anios numeric,
	calificacion numeric,
	clasificacion character(3),
	ultimocred character(3),
	descultimocred character varying(30)
);
drop function spsclasificacioncartera(date);
CREATE OR REPLACE FUNCTION spsclasificacioncartera(date) RETURNS SETOF rclasificacion
AS $_$
declare
	r rclasificacion%rowtype;
	pfecha alias for $1;
begin
	    for r in
			select s.clavesocioint, ltrim(su.nombre)||' '||ltrim(su.paterno)||' '||ltrim(su.materno),pagospactados,pagosenmora,creditospagados,creditosvigentes,saldototal,diasatrasomaximo,montoultimocred,montomaximocred,correccionxanios,anios,calificacion,clasificacion,ultimocred,descultimocred  from socio s,sujeto su,burointerno bi where s.socioid=bi.socioid and su.sujetoid=s.sujetoid and fechageneracion=pfecha order by s.clavesocioint
	    loop
      		return next r;
    	end loop;
return;
end
$_$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION spsclasificacioncarterac(date) RETURNS SETOF rclasificacion
AS $_$
declare
	r rclasificacion%rowtype;
	pfecha alias for $1;
	f record;
  	dblink1 text;
  	dblink2 text;
begin
for f in
		select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;
        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||'; select * from spsclasificacioncartera('||''''||pfecha||''''||');';

        for r in
           select * from
           dblink(dblink1,dblink2) as
           t2(clavesocioint  character(15),
	nombre character varying(80),
	pagospactados integer,
	pagosenmora  integer,
	creditospagados integer,
	creditosvigentes integer,
	saldototal numeric,
	diasatrasomaximo integer,
	montoultimocred numeric,
	montomaximocred numeric,
	correccionxanios numeric,
	anios numeric,
	calificacion numeric,
	clasificacion character(3),
	ultimocred character(3),
	descultimocred character varying(30)
			)
        loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;