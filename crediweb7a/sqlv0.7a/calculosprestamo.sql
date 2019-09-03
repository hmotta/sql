--Modificado el día 2013-01-09 para recibir pago a cuenta de interes.

--update empresa set abonointeres=1, manejopagoamortizacion=0;

CREATE or replace FUNCTION spscalculopago(integer,character) RETURNS SETOF tcalculopago
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
declare
  lprestamoid alias for $1;
  susuarioid alias for $2;
  r tcalculopago%rowtype;
  --susuarioid char(20);
  pfechacalculo date;

begin
  
  --select current_user into susuarioid;
  pfechacalculo:=current_date;

  if current_date <> (select fechacalculo from parametros where usuarioid=susuarioid) then 
     select fechacalculo into pfechacalculo from parametros where usuarioid=susuarioid;

  end if;
  raise notice '% %',pfechacalculo,susuarioid;
  
  for r in select * from spscalculopago(lprestamoid)
  
  loop
     return next r;
  end loop;

return;
end
$_$;

