drop type rretirosdecaja cascade;
create type rretirosdecaja AS (
	clavesocioint  character(15),
	nombre character varying(80),
	folio integer,
	numero_poliza  integer,
	serie character(2),
	fecha date,
	retiro numeric,
	tipomovimientoid character(2),
	desctipomovimiento character(30),
	denominacionid integer,
	modoretiro character varying(40) 
);
CREATE OR REPLACE FUNCTION retirosdecaja(date, date) RETURNS SETOF rretirosdecaja
    AS $_$
declare
 pfecha1 alias for $1;
 pfecha2 alias for $2;
 r rretirosdecaja%rowtype;
 l record;
 i int;
  fcapital numeric;
 fnormal numeric;
 fmoratorio numeric;
 fiva numeric;
 fcobranza numeric;
 denominacion integer;
 --tipomovimiento char;
 
begin
 -------------------------------------------
 -- Movimientos de deposito retiro en caja
 -------------------------------------------

 for r in

select s.clavesocioint,su.paterno||' '||su.materno||' '||su.nombre as nombre,m.referenciacaja as folio,p.numero_poliza,m.seriecaja as serie,
          p.fechapoliza as fecha, mp.haber as retiro, m.tipomovimientoid,tp.desctipomovimiento,  coalesce(sa.denominacionid,0),'' as modoretiro
     from movicaja m, polizas p, movipolizas mp, socio s, parametros pa,sujeto su,tipomovimiento tp,sabana sa
	 where 
          p.polizaid = m.polizaid and
          p.fechapoliza between pfecha1 and pfecha2 and
          mp.movipolizaid = m.movipolizaid and
          mp.polizaid = p.polizaid and
          pa.serie_user = m.seriecaja and 
          mp.cuentaid = pa.cuentacaja and 
          s.socioid = m.socioid and 
		  su.sujetoid=s.sujetoid and sa.referenciacaja=m.referenciacaja and sa.seriecaja=m.seriecaja and
		  m.tipomovimientoid=tp.tipomovimientoid and
          m.tipomovimientoid <> 'IN' and
          m.tipomovimientoid <> '00' and
          m.tipomovimientoid <> 'CO' and
		  m.tipomovimientoid <> 'RE' and
          m.tipomovimientoid <> 'CH' 
 order by m.referenciacaja
 
 loop
  -- Movimientos normales en Caja   
	if r.denominacionid=16 or r.denominacionid=0 then 
		r.modoretiro='TRANSFERENCIA'; 
	else 
		if r.denominacionid=15 or r.denominacionid=17 then 
			r.modoretiro='CHEQUE'; 
		else 
			r.modoretiro='EFECTIVO'; 
		end if;
	end if;
   return next r;
 end loop;
 
 for l in
   select s.clavesocioint,s.sujetoid,p.polizaid,p.polizaid, t.cuentaintinver,t.cuentaivainver,t.cuentapasivo,t.cuentariesgocred,
   m.referenciacaja as folio,p.numero_poliza,m.seriecaja as serie,
          p.fechapoliza as fecha,0 as retiro,m.tipomovimientoid,tp.desctipomovimiento
     from movicaja m, polizas p, movipolizas mp, socio s, inversion ix, tipoinversion t, parametros pa, tipomovimiento tp
    where 
          p.polizaid = m.polizaid and
          p.fechapoliza between  pfecha1 and pfecha2 and
          mp.polizaid = p.polizaid and
          pa.serie_user = m.seriecaja and 
          mp.cuentaid = pa.cuentacaja and         
          s.socioid = m.socioid and
		  tp.tipomovimientoid=m.tipomovimientoid and
          m.tipomovimientoid='IN' and
          ix.inversionid = m.inversionid and
          t.tipoinversionid = ix.tipoinversionid and
		  ix.inversionid not in (select inversionanteriorid from inversion where inversionanteriorid is not null)
group by m.referenciacaja,p.numero_poliza,m.seriecaja,
          m.socioid,s.clavesocioint,p.fechapoliza,
          m.tipomovimientoid,tp.desctipomovimiento, p.polizaid, t.cuentaintinver,t.cuentaivainver,t.cuentapasivo,t.cuentariesgocred,s.sujetoid
   order by m.referenciacaja

 loop 
   -- Movimientos capital

   fnormal := 0;
   fmoratorio := 0;
   fiva := 0;
   fcapital := 0;

   select coalesce(haber-debe,0) into fcapital
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentapasivo;

   select coalesce(SUM(haber-debe),0) into fnormal
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentaintinver;

   select coalesce(SUM(haber-debe),0) into fiva
     from movipolizas
    where polizaid = l.polizaid and
          cuentaid = l.cuentariesgocred;
   select su.paterno||' '||su.materno||' '||su.nombre into r.nombre from sujeto su where su.sujetoid=l.sujetoid;
   -- Formar renglon
   r.folio := l.folio;
   r.numero_poliza := l.numero_poliza;
   r.serie := l.serie;
   --r.socioid := l.socioid;
   r.clavesocioint := l.clavesocioint;
   r.fecha := l.fecha;
   if fcapital>0 then
     r.retiro := 0;
   else
     r.retiro := (-1*fcapital)+(-1*fnormal);
   end if;
   r.tipomovimientoid := l.tipomovimientoid;
   r.desctipomovimiento := l.desctipomovimiento;
   return next r;
 end loop;
 
 
return;
end;
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION retirosdecajac(date, date, integer) RETURNS SETOF rretirosdecaja
    AS $_$
declare
 pfecha1 alias for $1;
 pfecha2 alias for $2;
 servidor alias for $3;
 r rretirosdecaja%rowtype;
 f record;
 dblink1 text;
 dblink2 text;

begin
 for f in
   SELECT *from sucursales where vigente='S'
 loop
     raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;
	 
	 if servidor=1 then 
		dblink1:='host='||f.hostremoto||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
	 else
		dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
	 end if;
     dblink2:='set search_path to public,'||f.esquema||'; select * from retirosdecaja('||''''||pfecha1||''''||','||''''||pfecha2||''''||');';
     for r in
      SELECT * FROM
        dblink(dblink1,dblink2) as t2 (clavesocioint  character(15),
	nombre character varying(80),
	folio integer,
	numero_poliza  integer,
	serie character(2),
	fecha date,
	retiro numeric,
	tipomovimientoid character(2),
	desctipomovimiento character(30),
	denominacionid integer,
	modoretiro character varying(40) )


     loop
       return next r;
     end loop;

 end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;