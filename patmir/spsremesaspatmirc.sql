CREATE TYPE rremesaspatmir AS (
	folio character(4),
	clavesocioint character(12),
	transaccion character(20),
	monto numeric,
	t_mvto character(20)
);

CREATE FUNCTION spsremesaspatmir(date, date) RETURNS SETOF rremesaspatmir
    AS $_$
declare
	r rremesaspatmir%rowtype;
	pfechai alias for $1;
  	pfechaf alias for $2;
begin
	    for r in
			select 	
                                        '0017', 
					RTrim(s.clavesocioint),
                                        'RECEPCION',
					sum(m.haber),
                                        'INTERNACIONAL'	
											
					
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
					t.tipomovimientoid in ('EV','EI','RG') and 
					p.seriepoliza !='ZA' and 
					p.seriepoliza !='Z'  and 
					p.seriepoliza !='WW' and 
					p.fechapoliza between pfechai and pfechaf and s.tiposocioid!='01' and m.haber > 0 and
					su.nombre!='COBRO DE' and su.nombre!='INTERMEX' and su.paterno!='ENVIO DE' and su.materno!='REMESAS' and su.nombre!='INTERDISA' and su.nombre!='RED DE LA GENTE' and su.nombre!='ENVIO DE'
					and su.nombre!='PAGO DE' and su.nombre!='CAJA'
			group by s.clavesocioint order by s.clavesocioint
	    loop
			
      		return next r;
    	    end loop;
	
		

		for r in
			select 	
                                        '0017', 
					RTrim(s.clavesocioint),
                                        'ENVIO',
					sum(m.debe),
                                        'INTERNACIONAL'	
					                                    
									
					
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
					t.tipomovimientoid in ('RG') and 
					p.seriepoliza !='ZA' and 
					p.seriepoliza !='Z'  and 
					p.seriepoliza !='WW' and 
					p.fechapoliza between pfechai and pfechaf and s.tiposocioid!='01' and m.debe>0 and 
					 su.nombre!='COBRO DE' and su.nombre!='INTERMEX' and su.paterno!='ENVIO DE' and su.materno!='REMESAS'and su.nombre!='INTERDISA' and su.nombre!='RED DE LA GENTE' and su.nombre!='ENVIO DE'
					and su.nombre!='PAGO DE' and su.nombre!='CAJA'
			group by s.clavesocioint order by s.clavesocioint
	    loop
			
      		return next r;
    	    end loop;


			for r in
			select 	
                                        '0017', 
					RTrim(s.clavesocioint),
                                        'RECEPCION',
					sum(m.haber),
                                        'NACIONAL'	
					                                   
									
					
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
					t.tipomovimientoid in ('RN') and 
					p.seriepoliza !='ZA' and 
					p.seriepoliza !='Z'  and 
					p.seriepoliza !='WW' and 
					p.fechapoliza between pfechai and pfechaf and s.tiposocioid!='01' and m.haber>0 and 
					su.nombre!='COBRO DE' and  su.nombre!='INTERMEX' and su.paterno!='ENVIO DE' and su.materno!='REMESAS' and  su.nombre!='INTERDISA' and su.nombre!='RED DE LA GENTE' and su.nombre!='ENVIO DE'
					and su.nombre!='PAGO DE' and su.nombre!='CAJA'
			group by s.clavesocioint order by s.clavesocioint
	    loop
			
      		return next r;
    	    end loop;



			for r in
			select 	
                                        '0017', 
					RTrim(s.clavesocioint),
                                        'ENVIO',
				
					sum(m.debe),
                                        'NACIONAL'	
														
					
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
					t.tipomovimientoid in ('EN') and 
					p.seriepoliza !='ZA' and 
					p.seriepoliza !='Z'  and 
					p.seriepoliza !='WW' and 
					p.fechapoliza between pfechai and pfechaf and s.tiposocioid!='01' and m.debe>0 and
					su.nombre!='COBRO DE' and  su.nombre!='INTERMEX' and su.paterno!='ENVIO DE' and su.materno!='REMESAS'and su.nombre!='INTERDISA' and su.nombre!='RED DE LA GENTE' and su.nombre!='ENVIO DE'
					and su.nombre!='PAGO DE' and su.nombre!='CAJA'
			group by s.clavesocioint order by s.clavesocioint
	    loop
			
      		return next r;
    	    end loop;


return;
end
$_$
    LANGUAGE plpgsql;


ALTER FUNCTION public.spsremesaspatmir(date, date) OWNER TO sistema;

--
-- Name: spsremesaspatmirc(date, date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE FUNCTION spsremesaspatmirc(date, date) RETURNS SETOF rremesaspatmir
    AS $_$
declare
	r rremesaspatmir%rowtype;
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

        dblink2:='set search_path to public,'||f.esquema||'; select * from spsremesaspatmir('||''''||pfechai||''''||','||''''||pfechaf||''''||');';

							     
        for r in
           select * from
           dblink(dblink1,dblink2) as
           t2(
        folio character(4),
	clavesocioint character(12),
	transaccion character(20),
        monto numeric,
	t_mvto character(20))
	

        loop
              return next r;
        end loop;

end loop;
return;
end
$_$
    LANGUAGE plpgsql;