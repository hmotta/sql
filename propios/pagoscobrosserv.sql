
--funcion para reportear 
drop type rreportepagoscobros cascade;
CREATE TYPE rreportepagoscobros AS (
	suc character(4),
	clavesocioint character(16),
	nombresocio character varying(80),
	fechamvto date,
	polizaid integer,
	deposito numeric,
	retiro numeric,
	t_mvto character(2),
	desctipomovimiento character(30),
	s_pol character(30),
	usuarioid character(20)
);


CREATE OR REPLACE FUNCTION spscobropagosr(date,date) RETURNS SETOF rreportepagoscobros
AS $_$
declare
	r rreportepagoscobros%rowtype;
	pfechai alias for $1;
  	pfechaf alias for $2;
begin
	    for r in
			select 	substring((s.clavesocioint),1,4) as suc, 
					s.clavesocioint,
					su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
					p.fechapoliza as fechamvto,
					p.polizaid,
					m.debe as deposito,
					m.haber as retiro,
					t.tipomovimientoid as t_mvto,
					t.desctipomovimiento,
					p.seriepoliza as s_pol, 
					pa.usuarioid
			from 	parametros pa, 
					movicaja mc, 
					polizas p, 
					movipolizas m,
					tipomovimiento t,
					socio s, 
					sujeto su 
			where 	pa.serie_user=mc.seriecaja and 
					su.sujetoid=s.sujetoid and 
					s.clavesocioint = s.clavesocioint and 
					mc.socioid = s.socioid and 
					p.polizaid = mc.polizaid and 
					m.movipolizaid = mc.movipolizaid and 
					t.tipomovimientoid =mc.tipomovimientoid and 
					t.tipomovimientoid in ('EV','EI','RG','LE','TE','SA','AT','SM','SI','SQ','SB','ST','OP','EN','RN','TC','MV','IU','MC','CM','SK','CF','TU') and 
					p.seriepoliza !='ZA' and 
					p.seriepoliza !='Z'  and 
					p.seriepoliza !='WW' and 
					p.fechapoliza between pfechai and pfechaf and
					(m.debe > 0 or m.haber > 0)
			order by s.clavesocioint, p.fechapoliza
	    loop
			if( r.t_mvto = 'TE' ) then
					r.deposito = 0.00;
					select haber into r.deposito from movipolizas where polizaid=r.polizaid and cuentaid = '2305010403';
			end if;
			if( r.t_mvto = 'EN' ) then
					r.deposito = 0.00;
					select haber into r.deposito from movipolizas where polizaid=r.polizaid and cuentaid = '1401070104';
			end if;
      		return next r;
    	    end loop;
return;
end
$_$
    LANGUAGE plpgsql;

--
CREATE OR REPLACE FUNCTION spscobropagosrc(date,date) RETURNS SETOF rreportepagoscobros
AS $_$
declare
	r rreportepagoscobros%rowtype;
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
	usuarioid character(20))

        loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;

