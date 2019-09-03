
--se corre en la sucursal donde se van a pasar los socios con los parametros del origen 
--select * from spstraspasasucursalx('0','ZZZ','cajayolo04','sucursal4','localhost'); 

--Los que no pasan
--en la 9
--update socio set estatussocio=1 where clavesocioint in ('009-00632-02','009-00145-02','009-00183-02');
--en la 8
--update socio set clavesocioint ='008-00632-' where clavesocioint ='008-00632-02';


drop function spstraspasasucursalx(char,char,char,char,char);
create or replace function spstraspasasucursalx(char,char,char,char,char) returns int4 as
$_$
declare  
  r record;
  m record;
  psocioi alias for $1;
  psociof alias for $2;
  pdb alias for $3;
  psucursal alias for $4;
  phost alias for $5;

  sociotraspaso int4;
  j int4;
  pserie char(2);
  scuentacaja char(24);
  msaldomov numeric;
  pretiromov numeric;

begin
-- Serie de Caja
pserie := 'WW';

select cuentacaja into scuentacaja from parametros where serie_user=pserie;

j:=0;

for r in
    select clavesocioint   
      FROM dblink('host=localhost dbname='||''''||pdb||''''||' user=sistema password =1sc4pslu2 ',
                  'set search_path to public,'||''''||psucursal||''''||';
                 select clavesocioint from socio where estatussocio in (1,3) and clavesocioint between psocioi and psociof order by clavesocioint') as t(clavesocioint char(15))

    loop

      --raise notice ' Traspasando Socio %',r.clavesocioint;
      j:=j+1;

      SELECT traspasasocio into sociotraspaso from traspasasocio(r.clavesocioint,phost,pdb,psucursal,pserie);
        
    end loop;

return j;
end
$_$
language 'plpgsql' security definer;

