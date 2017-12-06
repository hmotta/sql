drop TYPE tinversionesdiarias cascade;
CREATE TYPE tinversionesdiarias AS (
     sucursal character(4),
     clavesocioint           character(12),
     paterno  		character varying(30),
     materno		character varying(30),
     nombre			text,
     fecha_nacimiento date,
     inversionid character varying(12),
     tipoinversionid character varying(30),     desctipoinversion character varying(30),
     referenciainversion character varying(12),
     serieinversion character(4), 
     usuario character varying(20),
     depositoinversion numeric, 
     retiroinversion numeric,
     interesinversion numeric,
     fechainversion date,
     fechavencimiento date,
     plazo character varying(30),
     noderenovaciones character varying(30),
     tipoinversion character(3) ,
     tasainteresnormalinversion numeric,
     tasainteresmoratorioinversion numeric,
     reinversionautomatica character(1), 
     clavesociobeneficiario1 character varying(15),
     nombrebeneficiario1 character varying(120),
     rpor1 character varying(15),
     clavesociobeneficiario2 character varying(15),
     nombrebeneficiario2  character varying(120),
     rpor2 character varying(15), 
     clavesociobeneficiario3 character varying(15),
     nombrebeneficiario3 character varying(120),
     rpor3 character varying(15), 
     clavesociobeneficiario4  character varying(15),
     nombrebeneficiario4 character varying(120),
     rpor4 character varying(15)
 );

CREATE or replace FUNCTION inversionesdiarias(date) RETURNS SETOF tinversionesdiarias
    AS $_$
declare
  pfechacierre alias for $1;
r tinversionesdiarias%rowtype;
l record;

 rnobeneficiario1 character varying(12);
 rnobeneficiario2 character varying(12);
 rnobeneficiario3 character varying(12);
 rnobeneficiario4 character varying(12);
 rclavesociobeneficiario1  character varying(12);
 rclavesociobeneficiario2  character varying(12);
 rclavesociobeneficiario3  character varying(12);
 rclavesociobeneficiario4  character varying(12);
 rnombrebeneficiario1  character varying(120);
 rnombrebeneficiario2  character varying(120);
 rnombrebeneficiario3  character varying(120);
 rnombrebeneficiario4  character varying(120);
 rpor1 numeric; 
 rpor2 numeric; 
 rpor3 numeric; 
 rpor4 numeric; 
 vusuario character varying(15);
 j integer;

begin
    for r in
	select 
	 substring(s.clavesocioint,1,4),
	 RTrim(s.clavesocioint),
	 su.paterno,
	 su.materno,
	 su.nombre,
	 su.fecha_nacimiento,
	 i.inversionid,
         i.tipoinversionid,
	 t.desctipoinversion,
         i.referenciainversion, 
         i.serieinversion, 
	 '' as usuario,
         i.depositoinversion, 
         i.retiroinversion,
	 i.interesinversion,
	 i.fechainversion,
	 i.fechavencimiento,
	 '' as plazo,
         i.noderenovaciones,
	 t.tipoinversionid,
	 i.tasainteresnormalinversion,
         i.tasainteresmoratorioinversion,
	 i.reinversionautomatica, 
	 0 as clavesociobeneficiario1,
	'' as nombrebeneficiario1,
	0,
	0 as clavesociobeneficiario2,
	'' as nombrebeneficiario2,
	0,
	0 as clavesociobeneficiario3,
	'' as nombrebeneficiario3,
	0,
	0 as clavesociobeneficiario4,
	'' as nombrebeneficiario4,
	0

		from inversion i,socio s, sujeto su, tipoinversion t, beneficiario b
		 where i.fechainversion= pfechacierre and i.socioid=s.socioid and su.sujetoid=s.sujetoid and i.tipoinversionid=t.tipoinversionid 
		loop 
		   ---dias mora cierre actual-----
		 j:=0;
		 for l in 
        select * from beneficiario where inversionid=r.inversionid
		
            loop 
		
             j:=j+1;		
		if j=1 then
		
		select  sujetoid into rnobeneficiario1 from beneficiario where beneficiarioid=l.beneficiarioid;
		select porcentajebeneficiario into rpor1 from beneficiario where beneficiarioid=l.beneficiarioid;
		select clavesocioint into rclavesociobeneficiario1 from socio where sujetoid=rnobeneficiario1;
		select nombre||' '||paterno||' '||materno into rnombrebeneficiario1 from sujeto where sujetoid=rnobeneficiario1;
			r.clavesociobeneficiario1:=rclavesociobeneficiario1;
			r.nombrebeneficiario1:=rnombrebeneficiario1;
			r.rpor1=porcentajebeneficiario1;
         end if;
		 
		 if j=2 then
		
		select  sujetoid into rnobeneficiario2 from beneficiario where beneficiarioid=l.beneficiarioid;
		select porcentajebeneficiario into rpor2 from beneficiario where beneficiarioid=l.beneficiarioid;
		select clavesocioint into rclavesociobeneficiario2 from socio where sujetoid=rnobeneficiario2;
		select nombre||' '||paterno||' '||materno into rnombrebeneficiario2 from sujeto where sujetoid=rnobeneficiario2;
			r.clavesociobeneficiario2:=rclavesociobeneficiario2;
			r.nombrebeneficiario2:=rnombrebeneficiario2;
			r.rpor2=porcentajebeneficiario2;
         end if;
		 
		 if j=3 then
		
		select  sujetoid into rnobeneficiario3 from beneficiario where beneficiarioid=l.beneficiarioid;
		select porcentajebeneficiario into rpor3 from beneficiario where beneficiarioid=l.beneficiarioid;
		select clavesocioint into rclavesociobeneficiario3 from socio where sujetoid=rnobeneficiario3;
		select nombre||' '||paterno||' '||materno into rnombrebeneficiario3 from sujeto where sujetoid=rnobeneficiario3;
			r.clavesociobeneficiario3:=rclavesociobeneficiario3;
			r.nombrebeneficiario3:=rnombrebeneficiario3;
			r.rpor3=porcentajebeneficiario3;
         end if;
		 
		 if j=4 then
		
		select  sujetoid into rnobeneficiario4 from beneficiario where beneficiarioid=l.beneficiarioid;
		select porcentajebeneficiario into rpor4 from beneficiario where beneficiarioid=l.beneficiarioid;
		select clavesocioint into rclavesociobeneficiario4 from socio where sujetoid=rnobeneficiario4;
		select nombre||' '||paterno||' '||materno into rnombrebeneficiario4 from sujeto where sujetoid=rnobeneficiario4;
			r.clavesociobeneficiario4:=rclavesociobeneficiario4;
			r.nombrebeneficiario4:=rnombrebeneficiario4;
			r.rpor4=porcentajebeneficiario4;
         end if;
         end loop;
		 r.plazo:=r.fechavencimiento-r.fechainversion;
		 select usuarioid into vusuario from parametros where serieuser=r.serieinversion;
		 
		 r.usuario=vusuario;
		return next r;

		end loop;
return;
end

		
$_$
LANGUAGE plpgsql SECURITY DEFINER;

