--
-- Name: rreporteide; Type: TYPE; Schema: public; Owner: sistema
--
drop type rreporteide cascade;
CREATE TYPE rreporteide AS (
	suc character(4),
	clavesocioint character(15),
	socioid integer,
	nombre character varying(80),
	tipopersona character(10),
	rfc character(15),
	curp character(20),
	domicilio character varying(80),
	comunidad character varying(80),
	saldoide numeric,	
	importe numeric
);

--
-- Name: reporteide(date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE OR REPLACE FUNCTION reporteide(date) RETURNS SETOF rreporteide
    AS $_$
declare  
  r rreporteide%rowtype;
  pfechac alias for $1;
  periodo integer;
  ejercicio integer;
begin
    periodo:=cast(date_part('month',pfechac) as int);
    ejercicio:=cast(date_part('year',pfechac) as int);
    for r in

        select 	substring((s.clavesocioint),1,4) as suc,
		s.clavesocioint,
		s.socioid,
		ltrim(su.paterno)||' '||ltrim(su.materno)||' '||ltrim(su.nombre),
		(case when si.personajuridicaid = 1 then 'Moral' else 'Fisica' end) as  tipopersona,
		su.rfc,
		su.curp,
		substr(ltrim(rtrim(d.calle))||' '||d.numero_ext,1,80) || ' ' || d.colonia || ' C.P.' || d.codpostal as domicilio,
		d.comunidad,
		sum(sd.saldo) as saldoide
	from 	socio s,
		sujeto  su,
		solicitudingreso si,
		domicilio d,
		(
		select  mc.socioid, sum(mp.debe)-sum(mp.haber) as saldo
		from 	movicaja mc, 
			movipolizas mp, 
			tipomovimiento tm, 
			polizas p 
		where 	mp.movipolizaid=mc.movipolizaid and 
			tm.tipomovimientoid=mc.tipomovimientoid and 
			mc.tipomovimientoid = 'ID' and 
			p.polizaid = mc.polizaid and 
			p.periodo = periodo and 
			p.ejercicio = ejercicio  
		group by mc.socioid 
		) sd
 	where 	s.sujetoid=su.sujetoid and 
		s.socioid=si.socioid and 
		s.socioid=sd.socioid and 
		su.sujetoid=d.sujetoid
	group by s.clavesocioint,ltrim(su.paterno)||' '||ltrim(su.materno)||' '||ltrim(su.nombre),
		su.fecha_nacimiento,
		s.fechaalta,
		s.tiposocioid,
		s.socioid,
		s.fechaalta,
		su.fecha_nacimiento,
		s.estatussocio,
		si.personajuridicaid,
		si.sexo,
		su.rfc,
		su.curp,
		d.calle,
		d.numero_ext,
		d.colonia,
		d.teldomicilio , 
		d.comunidad,
		d.codpostal
	order by s.clavesocioint

        loop
	  if( periodo > 06 ) then
	   	select sum(sumadepositos)-15000 into r.importe from sumadepositos('',pfechac,r.socioid);
	   else
		select sum(sumadepositosold)-15000 into r.importe from sumadepositosold('',pfechac,r.socioid);
  	   end if;
          return next r;
        end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION reporteidec(date) RETURNS SETOF rreporteide
AS $_$
declare
	r rreporteide%rowtype;
	pfechac alias for $1;
	f record;
  	dblink1 text;
  	dblink2 text;
begin
for f in
		select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;

        dblink2:='set search_path to public,'||f.esquema||'; select * from reporteide('||''''||pfechac||''''||');';

        for r in
           select * from
           dblink(dblink1,dblink2) as
           t2(suc character(4),
		clavesocioint character(15),
		socioid integer,
		nombre character varying(80),
		tipopersona character(10),
		rfc character(15),
		curp character(20),
		domicilio character varying(80),
		comunidad character varying(80),
		saldoide numeric,	
		importe numeric)

        loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;
