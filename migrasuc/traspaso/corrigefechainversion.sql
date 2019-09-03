
create or replace function corrigefechainversion() returns numeric as
'
declare

  r record; 
  ppolizaid int4;
  icambiafechapoliza integer;
  
begin
 
  for r in
  select * from inversion where serieinversion=''WW''
  loop
    if exists (select min(polizaid) from movicaja where inversionid=r.inversionid and seriecaja=''WW'' ) then

      select polizaid into ppolizaid from movicaja where inversionid=r.inversionid and seriecaja=''WW'' ;
      select cambiafechapoliza into icambiafechapoliza from cambiafechapoliza(ppolizaid,r.fechapagoanterior);

      raise notice '' Poliza % % '',ppolizaid,r.fechapagoanterior;
          
    end if;
 
  end loop;
  
  update inversion set fechapagoinversion = fechapagoanterior where fechapagoinversion=''2009-05-01'' and serieinversion=''WW'';
  
  return 1;
end
'
language 'plpgsql' security definer;


