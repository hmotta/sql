drop type rsolicitudesprestamo CASCADE;
create type rsolicitudesprestamo as (
	solicitudprestamoid integer,
	nosolicitud integer,
	clavesocioint character(15),
	nombre character varying (80),
	monto numeric,
	fechasolicitud date,
	vigencia date,
	tipoprestamoid character(3),
	desctipoprestamo character(30),
	periodopagoid integer,
	abonospropuestos integer,
	tasanormal numeric,
	tasamoratorio numeric,
	usuarioid character varying(20),
	etapa integer,
	estatus integer
);

CREATE or replace FUNCTION spssolitudesprestamo(date) RETURNS SETOF rsolicitudesprestamo
    AS $_$
declare

	pfecha  alias for $1;
	r rsolicitudesprestamo%rowtype;
	pmultiplica numeric;
	pnombre character varying(40);
	fechaini date;
  
	i int;
begin
	fechaini:=pfecha-30;
	
	i:=1;
  for r in
       select
	    sp.solicitudprestamoid,
		
		sp.nosolicitud,
		
		trim(s.clavesocioint),
	
		su.nombre||' '||su.paterno||' '|| su.materno as nombre,
	
		sp.montosolicitado,
	
		sp.fechasolicitud,
	
		sp.vigencia,
	
		sp.tipoprestamoid ,
	
		(select desctipoprestamo FROM tipoprestamo where tipoprestamoid=sp.tipoprestamoid),

		sp.periodopagoid,

		sp.abonospropuestos,

		sp.tasanormal,
		
		sp.tasamoratorio,
		
		trim(sp.usuarioid),
		
		sp.etapa,
		
		sp.estatus
	
 
	from solicitudprestamo sp, socio s, sujeto su 

	where
		s.socioid = sp.socioid and 
		 su.sujetoid=s.sujetoid and
		 --sp.vigencia is not null and
		--sp.vigencia<=pfecha and 
		sp.fechasolicitud >= fechaini and 
		tipoprestamoid not in ('N5','N53','N54')


  loop
        
	
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;