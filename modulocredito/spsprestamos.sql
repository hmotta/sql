drop type rprestamosaimprimir CASCADE;
create type rprestamosaimprimir as (
	prestamoid integer,
	nosolicitud integer,
	referenciaprestamo character varying(18),
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

CREATE or replace FUNCTION spsprestamosaimprimir(date) RETURNS SETOF rprestamosaimprimir
    AS $_$
declare

	pfecha  alias for $1;
	r rprestamosaimprimir%rowtype;
	fechaini date;
	i int;
begin
	fechaini:=pfecha-7;
	
	i:=1;
  for r in
       select
		p.prestamoid,
	   
		sp.nosolicitud,
		
		p.referenciaprestamo,
		
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
	
 
	from solicitudprestamo sp, prestamos p, socio s, sujeto su 

	where
		p.solicitudprestamoid=sp.solicitudprestamoid and
		s.socioid = sp.socioid and 
		 su.sujetoid=s.sujetoid and
		 
		 --sp.vigencia is not null and
		--sp.vigencia<=pfecha and 
		sp.fechasolicitud >= fechaini


  loop
        
	
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;