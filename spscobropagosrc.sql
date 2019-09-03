drop function spscobropagosrc(date, date, integer);
CREATE FUNCTION spscobropagosrc(date, date, integer) RETURNS SETOF rreportepagoscobros
    AS $_$
declare
	r rreportepagoscobros%rowtype;
	pfechai alias for $1;
  	pfechaf alias for $2;
	 servidor alias for $3;
	f record;
  	dblink1 text;
  	dblink2 text;
begin
for f in
		select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        if servidor=2 then 
			dblink1:='host='||f.hostremoto||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
		else
			dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
		end if;

        dblink2:='set search_path to public,'||f.esquema||'; select * from spscobropagosr('||''''||pfechai||''''||','||''''||pfechaf||''''||');';

        for r in
           select * from
           dblink(dblink1,dblink2) as
           t2(suc character(4),
	clavesocioint character(16),
	nombresocio character varying(80),
	fechamvto date,
	polizaid integer,
	deposito numeric,
	retiro numeric,
	t_mvto character(2),
	desctipomovimiento character(30),
	s_pol character(30),
	usuarioid character(20),
	descripcion character varying(29))

        loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;