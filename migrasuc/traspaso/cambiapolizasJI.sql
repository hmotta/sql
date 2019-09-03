
create or replace function cambiapolizasJI() returns numeric as
'
declare

  r record;
  pnumeropoliza int4;
  ptipopoliza char(1);
  pejercicio int4;
  pperiodo int4;

begin

  pejercicio:=2009;
  pperiodo:=05;

  for r in select * from polizas where seriepoliza=''WW''
     loop
        ptipopoliza=r.tipo_poliza;
        select max(numero_poliza) into pnumeropoliza from polizas where periodo=pperiodo and ejercicio=pejercicio and tipo_poliza=ptipopoliza;
        pnumeropoliza:=coalesce(pnumeropoliza,0);
        pnumeropoliza:= pnumeropoliza+1;
        
        update polizas set numero_poliza=pnumeropoliza, periodo=pperiodo, ejercicio=pejercicio where polizaid=r.polizaid;
        raise notice '' Poliza % % '',r.polizaid,r.seriepoliza;

     end loop;
  return 1;
end
'
language 'plpgsql' security definer;
