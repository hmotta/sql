
--funcion para reportear movimiento de ahorro entre un rango de fechas

drop type rdetallemovicaptacion cascade;

--CREATE TYPE rreportepagoscobros AS (
CREATE TYPE rdetallemovicaptacion AS (
	suc character(4),
	clavesocioint character(16),
	nombresocio character varying(80),
        fechamvto date,
        t_mvto character(2),
        desctipomovimiento character(30),
	deposito numeric,
	retiro numeric,
	s_pol character(30),
	usuarioid character(20)
);

--drop function spsmovicaptacionr(date,date,integer);

CREATE OR REPLACE FUNCTION spsmovicaptacionr(date,date) RETURNS SETOF rdetallemovicaptacion

AS $_$
declare
	r rdetallemovicaptacion%rowtype;
	pfechai alias for $1;
  	pfechaf alias for $2;
begin
	    for r in
	 	select substring((s.clavesocioint),1,4) as suc, s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
		p.fechapoliza as fechamvto, t.tipomovimientoid as t_mvto, t.desctipomovimiento, m.debe as deposito, m.haber as retiro,
		p.seriepoliza as s_pol, pa.usuarioid 
		from parametros pa, movicaja mc, polizas p, movipolizas m,tipomovimiento t,socio s, sujeto su 
		where pa.serie_user=mc.seriecaja and su.sujetoid=s.sujetoid and 
		s.clavesocioint = s.clavesocioint and mc.socioid = s.socioid and 
		p.polizaid = mc.polizaid and m.movipolizaid = mc.movipolizaid and 
		t.tipomovimientoid =mc.tipomovimientoid and t.tipomovimientoid in ('PA','IN','AO','AC','AA','AF','AM','AI','AP','P3','TA','AH','PR') and 
		p.seriepoliza !='ZA' and p.seriepoliza !='Z'  and p.seriepoliza !='WW' and p.fechapoliza between pfechai and pfechaf
		order by s.clavesocioint, p.fechapoliza
	    loop
      		return next r;
    	    end loop;
return;
end
$_$
    LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION spsmovicaptacionrc(date,date) RETURNS SETOF rdetallemovicaptacion

AS $_$
declare
	r rdetallemovicaptacion%rowtype;
	pfechai alias for $1;
  	pfechaf alias for $2;
	f record;
  	dblink1 text;
  	dblink2 text;
begin
for f in
		select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;

        dblink2:='set search_path to public,'||f.esquema||'; select * from spsmovicaptacionr('||''''||pfechai||''''||','||''''||pfechaf||''''||');';

        for r in
           select * from
           dblink(dblink1,dblink2) as
           t2(suc character(4),
		clavesocioint character(16),
		nombresocio character varying(80),
		fechamvto date,
                t_mvto character(2),
		desctipomovimiento character(30),
		deposito numeric,
		retiro numeric,
		s_pol character(30),
		usuarioid character(20))

            loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;

