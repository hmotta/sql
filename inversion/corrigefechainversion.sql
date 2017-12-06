-- Dentro del respaldo anterior al traspaso en la sucursal a traspasar. Ejemplo 009d
-- select * from corrigefechainversion('0','ZZZ','valle003','sucursal3','localhost');


drop function corrigefechainversion(char,char,char,char,char);
create or replace function corrigefechainversion(char,char,char,char,char) returns int4 as
'
declare  
  r record;

  psocioi alias for $1;
  psociof alias for $2;
  pdb alias for $3;
  psucursal alias for $4;
  phost alias for $5;

  pinversionid int4;
  pfechapoliza date;
  pfechapolizainversion int4;
 
  j int4;

begin

 --Bucar inversiones en la sucursal 009d
  j:=0;

for r in

   select inversionid,tipoinversionid,fechainversion,fechavencimiento,p.socioid,depositoinversion,retiroinversion,interesinversion,s.clavesocioint from inversion p, socio s  where s.clavesocioint>= psocioi and s.clavesocioint <=psociof and s.socioid=p.socioid and p.depositoinversion > p.retiroinversion
   loop


       select max(fechapoliza) into pfechapoliza from polizas where polizaid in (select polizaid from movicaja where inversionid = r.inversionid);


       -- Buscar inversion en la base nueva

       select inversionid into pinversionid from dblink(''host=''||''''''''||phost||''''''''||'' dbname=''||''''''''||pdb||''''''''||'' user=sistema password=1sc4pslu2'',
        ''set search_path to public,''||''''''''||psucursal||''''''''||'';
                   select inversionid
                   from inversion p, socio s where  s.socioid=p.socioid and p.depositoinversion = ''||r.depositoinversion||'' and p.fechainversion = ''||''''''''||r.fechainversion||''''''''||'';'')
            as t(inversionid integer);

       raise notice ''Inversionid % Fecha % '',pinversionid,pfechapoliza;

       -- Buscar la poliza en la nueva base y hacer el update

        select fechapolizainversion into pfechapolizainversion from
        dblink(''host=''||''''''''||phost||''''''''||'' dbname=''||''''''''||pdb||''''''''||'' user=sistema password=1sc4pslu2'',''set search_path to public,''||''''''''||psucursal||''''''''||'';
        select * from fechapolizainversion(''||pinversionid||'',''||''''''''||pfechapoliza||''''''''||'');'') as t(fechapolizainversion integer);

       j:=j+1;


  end loop;

return j;
end
'
language 'plpgsql' security definer;


drop function fechapolizainversion(int4,date);
create or replace function fechapolizainversion(int4,date) returns numeric as
'
declare
  pinversionid alias for $1;
  pfecha alias for $2;

begin
 
  update polizas set fechapoliza = pfecha where polizaid in (select polizaid from movicaja where inversionid = pinversionid ) and seriepoliza=''WW'' and fechapoliza=''2011-09-01'';

  return 1;
end
'
language 'plpgsql' security definer;

