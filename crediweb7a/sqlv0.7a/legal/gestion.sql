

CREATE TYPE rconsultagestion AS (
	clavesocioint character(15),
	nombre character varying(80),
	referenciaprestamo character(18),
	fechagestion date,
	tipogestion character(30),
	textogestion character varying(80),
	id integer,
	textocompleto text,
	textoresultado text
);


CREATE or replace FUNCTION spsgestion(integer) RETURNS SETOF rconsultagestion
    AS $_$
declare
 
 lprestamoid alias for $1;
 r rconsultagestion%rowtype;
 linea integer;

begin

  linea:=0;
  
  -- Gestiones
  for r in
    select s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio, 
           p.referenciaprestamo,c.fechagestion,                                        
           (case when c.tipogestionid=0 then 'Gestion Telefonica '                     
                 when c.tipogestionid=1 then 'Gestion Aviso      '                     
                 when c.tipogestionid=2 then 'Gestion Convenio   '         
                 when c.tipogestionid=3 then 'Gestion Visita     '
                 when c.tipogestionid=4 then 'Gestion Tablon     '
                                        else 'Gestion Legal      ' end) as tipogestion,                       
                      substr(c.textogestion,1,80) as textogestion, c.gestionid ,
                 c.textogestion as textocompleto,
           c.textoresultado
      from gestion c, prestamos p, socio s, sujeto su                                  
     where p.prestamoid = lprestamoid and                                                      
           c.prestamoid = p.prestamoid and
           --c.tipogestionid<>2 and
           --c.tipogestionid<>1 and
           s.socioid = p.socioid and                                                   
           su.sujetoid = s.sujetoid order by c.fechagestion DESC
  loop
    linea:=linea+1;
    return next r;

  end loop;

  --Convenios
  for r in
    select s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio, 
           p.referenciaprestamo,c.fechaconvenio,                                        
           'Convenio' as tipogestion,                       
           substr(c.textoconvenio,1,80) as textogestion, c.convenioid ,
           c.textoconvenio as textocompleto,
           ' ' as textoresultado
      from convenio c, prestamos p, socio s, sujeto su                                  
     where p.prestamoid = lprestamoid and                                                      
           c.prestamoid = p.prestamoid and                                             
           s.socioid = p.socioid and                                                   
           su.sujetoid = s.sujetoid
  order by c.fechaconvenio DESC
  loop

    linea:=linea+1;
    return next r;

  end loop;

  -- Cobro Legal
  
  for r in
    select s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio,p.referenciaprestamo,cl.fechacobrolegal,substring(tl.descripcion,1,15) as tipocobrolegal, substr(cl.textocobrolegal,1,80) as textocobrolegal, cl.cobrolegalid
      from cobrolegal cl, prestamos p, socio s, sujeto su, tipoprocesolegal tl
     where cl.prestamoid = lprestamoid and
           cl.prestamoid = p.prestamoid and
           s.socioid = p.socioid and
           su.sujetoid = s.sujetoid and
           cl.tipocobrolegalid=tl.tipoprocesolegalid
           order by cl.fechacobrolegal DESC
  loop

    linea:=linea+1;
    return next r;

  end loop;
  

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE or replace FUNCTION spsgestionsocio(character) RETURNS SETOF rconsultagestion
    AS $_$
declare
 
 pclavesocioint alias for $1;
 r rconsultagestion%rowtype;
 linea integer;
 lsocioid integer;

begin

  linea:=0;  
 
   -- Gestiones por socio

  select socioid into lsocioid from socio where clavesocioint=pclavesocioint;
   
  for r in
    select s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio, 
           c.referenciaprestamo,c.fechagestion,                                        
           (case when c.tipogestionid=0 then 'Gestion Telefonica '                     
                 when c.tipogestionid=1 then 'Gestion Aviso      '                     
                 when c.tipogestionid=2 then 'Gestion Convenio   '         
                 when c.tipogestionid=3 then 'Gestion Visita     '
                 when c.tipogestionid=4 then 'Gestion Tablon     '
                                        else 'Gestion Legal      ' end) as tipogestion,                       
                      substr(c.textogestion,1,80) as textogestion, c.gestionid ,
                 c.textogestion as textocompleto,
           c.textoresultado
      from gestion c,  socio s, sujeto su                                  
     where c.socioid=lsocioid and 
           s.socioid = c.socioid and                                                   
           su.sujetoid = s.sujetoid order by c.fechagestion DESC
  loop
  
    return next r;

  end loop;

  --Convenios
  for r in
    select s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio, 
           c.referenciaprestamo,c.fechaconvenio,                                        
           'Convenio' as tipogestion,                       
           substr(c.textoconvenio,1,80) as textogestion, c.convenioid ,
           c.textoconvenio as textocompleto,
           ' ' as textoresultado
      from convenio c, socio s, sujeto su                                  
     where c.socioid=lsocioid and                                             
           s.socioid = c.socioid and                                                   
           su.sujetoid = s.sujetoid
  order by c.fechaconvenio DESC
  loop

    linea:=linea+1;
    return next r;

  end loop;

  -- Tablones 
  
  for r in
    select s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno as nombresocio, 
           'Tablon',c.fechatablon,                                        
           'Tablon' as tipogestion,                       
           substr(c.textotablon,1,80) as textogestion, c.tablonid ,
           c.textotablon as textocompleto,
           ' ' as textoresultado
      from tablon c,  socio s, sujeto su                                  
     where c.socioid=lsocioid and                                             
           s.socioid = c.socioid and                                                   
           su.sujetoid = s.sujetoid
  order by c.fechatablon DESC
  loop

    linea:=linea+1;
    return next r;

  end loop;
    
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION spigestion(integer, date, integer, character, text, text) RETURNS integer
    AS $_$
declare
  pprestamoid alias for $1;
  pfechagestion alias for $2;
  ptipogestionid alias for $3;
  prealiza alias for $4;
  ptextogestion alias for $5;
  ptextoresultado alias for $6;

  preferenciaprestamo char(18);
  psocioid integer;
  

begin

  select referenciaprestamo,socioid into preferenciaprestamo,psocioid from prestamos where prestamoid=pprestamoid;

  insert into gestion( prestamoid,fechagestion,tipogestionid,realiza,textogestion,textoresultado,socioid,referenciaprestamo )
  values ( pprestamoid,pfechagestion,ptipogestionid,prealiza,ptextogestion,ptextoresultado,psocioid,preferenciaprestamo );

return currval('gestion_gestionid_seq');

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    

CREATE or replace FUNCTION spiconvenio(integer, date, text, character, character, integer, date) RETURNS integer
    AS $_$
declare

  pprestamoid     alias for $1;
  pfechaconvenio  alias for $2;
  ptextoconvenio  alias for $3;
  pvigente        alias for $4;
  pusuarioid      alias for $5;
  plugar          alias for $6;
  pfechavigencia  alias for $7;
  
  preferenciaprestamo char(18);
  psocioid integer;
 
  
begin

   if plugar<>0 and plugar<>1 then
     raise exception 'Error en plugar';
   end if;

   select referenciaprestamo,socioid into preferenciaprestamo,psocioid from prestamos where prestamoid=pprestamoid;

   
   insert into convenio(prestamoid,fechaconvenio,textoconvenio,vigente,usuarioid,lugar,fechavigencia,socioid,referenciaprestamo)
    values(pprestamoid,pfechaconvenio,ptextoconvenio,pvigente,pusuarioid,plugar,pfechavigencia,psocioid,preferenciaprestamo);

return currval('convenio_convenioid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


