CREATE OR REPLACE FUNCTION verificacomisionlinea(integer, numeric)
  RETURNS SETOF rcomision AS
$BODY$
declare
  pprestamoid alias for $1;
  pmontodispone alias for $2;
  
  
  r rcomision%rowtype;
   
  fcomision numeric;
  itipocobrocomision integer;
 
  fmontoprestamo numeric;
  pporcentaje numeric;
  ptipoprestamoid char(3);
  fsaldoprestamo numeric;
  fiva numeric;
  fperiodicidad integer;
  nedad integer;
begin

--comision                
--tipocobrocomision 0= al otorgamiento, 1 ala primera amortizacion, 2 al vencimiento.

select iva into fiva from empresa;
fmontoprestamo:=pmontodispone;

select tipoprestamoid into ptipoprestamoid from prestamos where prestamoid=pprestamoid;

select porcentaje into pporcentaje from cargoprestamo where tipoprestamoid = ptipoprestamoid ;

select date_part('year', age(fecha_nacimiento)) into nedad from sujeto su, socio s, prestamos p  where su.sujetoid=s.sujetoid and s.socioid=p.socioid and p.prestamoid=pprestamoid;

pporcentaje := coalesce(pporcentaje,0);


if nedad<=65 then
   r.comision=pporcentaje/100*fmontoprestamo;  
   r.comision=round(r.comision,2);
   r.ivacomision=round(r.comision*fiva,2);
   
else

   r.comision:=0;
   r.ivacomision:=0;
   
end if;

return next r;

end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
ALTER FUNCTION verificacomisionprestamo(integer, integer, numeric)
  OWNER TO sistema;
