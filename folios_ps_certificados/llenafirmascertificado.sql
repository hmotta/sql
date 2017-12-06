
CREATE FUNCTION verifirmascertificado() RETURNS integer
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

         insert into conoceatucliente(sujetoid,socioid,comunidadconapo,poblacionindigena) values(r.sujetoid,r.socioid,pcomunidadconapo,'NO');
         j:=j+1;       

         raise notice ' %  % ',r.socioid,pcomunidadconapo;
       
      end if;

   end loop;

return j;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;
