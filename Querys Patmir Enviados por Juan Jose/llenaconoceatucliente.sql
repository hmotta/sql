

drop FUNCTION spisocio(integer, integer, character, integer, integer, character, date, date, integer, integer);

drop FUNCTION spisocio(integer, character, integer, integer, character, date, date, integer, integer);

CREATE or replace FUNCTION spisocio(integer, integer, character, character, date, date, integer, integer, integer) RETURNS integer
    AS $_$ 
declare 
  psocioid alias for $1; 
  psujetoid alias for $2; 
  ptiposocioid alias for $3; 
  pclavesocioint alias for $4; 
  pfechaalta alias for $5; 
  pfechabaja alias for $6; 
  pestatussocio    alias for $7; 
  psolicitudingresoid alias for $8; 
  pmotivobajaid alias for $9; 
 
  sclavesocioint char(15);
  isocioid integer;
 
begin 
 
 
   sclavesocioint:=''; 
 
   select clavesocioint 
     into sclavesocioint 
     from socio 
    where clavesocioint=pclavesocioint; 
 
   raise notice '*%* *%*',sclavesocioint,pclavesocioint; 
   if sclavesocioint=pclavesocioint then 
     raise exception 'Un socio ya tiene asignada esa clave, no se pueden repetir claves de socio.'; 
 
   end if; 
 
   insert into socio(sujetoid,tiposocioid,clavesocioint,fechaalta,fechabaja,estatussocio,solicitudingresoid,motivobajaid) 
    values( psujetoid, 
            ptiposocioid, 
            pclavesocioint, 
            pfechaalta, 
            pfechabaja, 
            pestatussocio, 
            psolicitudingresoid, 
            pmotivobajaid); 

    isocioid:=currval('socio_socioid_seq'); 
            
    if not exists (select sujetoid from conoceatucliente where sujetoid=psujetoid) then
       insert into conoceatucliente(sujetoid,socioid,poblacionindigena,comunidadconapo) values(psujetoid,isocioid,'NO',(select c.claveconapo from colonia c, domicilio d where d.sujetoid=psujetoid and c.coloniaid=d.coloniaid));
    else
      if isocioid > 0 then
        update conoceatucliente set socioid=isocioid where sujetoid=psujetoid;
      end if;
    end if;
           
return isocioid; 
end 
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
CREATE or replace FUNCTION llenaconoceatucliente() RETURNS integer
    AS $$
declare
r record;

pactividad             char(100);
ppoblacionindigena     char(2);
pcomunidadconapo       char(10);
j integer;

begin

j:=0;
for r in select s.sujetoid,s.socioid,d.coloniaid from socio s, sujeto su, domicilio d where s.sujetoid=su.sujetoid and su.sujetoid=d.sujetoid 
   loop
      if not exists (select sujetoid from conoceatucliente where sujetoid=r.sujetoid) then

         insert into conoceatucliente(sujetoid,socioid,comunidadconapo,poblacionindigena) values(r.sujetoid,r.socioid,pcomunidadconapo,'SI');
         j:=j+1;       

         --raise notice ' %  % ',r.socioid,pcomunidadconapo;
      else
          if (select max(socioid) from conoceatucliente where sujetoid=r.sujetoid) is null then
             update conoceatucliente set socioid=r.socioid where sujetoid=r.sujetoid;
          end if;
          
      end if;

   end loop;

return j;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;


select * from llenaconoceatucliente();
