-- Function: patmir3mic(date)

-- DROP FUNCTION patmir3mic(date);

drop TYPE rpatmir3mic cascade;
CREATE TYPE rpatmir3mic AS (

-- FOLIO IF
folio_if integer,
--clave socio/cliente
clavesocio character varying(40),
contrato char(10),
--MONTO ASEGURADO
montoasegurado numeric,
--MONTO PAGADO
montopagado numeric,  
--TIPO MICROSEGURO
tipo_microseguro character(2)
);

CREATE OR REPLACE FUNCTION patmir3mic(date,date)
  RETURNS SETOF rpatmir3mic AS
$BODY$
declare

  r rpatmir3mic%rowtype;
  pfechai alias for $1;
  pfechac alias for $2;

begin

    for r in
        select
-- FOLIO IF
14,
--CLAVE SOCIO/CLIENTE
s.clavesocioint as clavesocio,
replace((select coalesce(max(seriecaja),'')||to_char(coalesce(max(referenciacaja),0),'0000000') from movicaja where socioid=s.socioid and fechahora > pfechai-1 and fechahora < pfechac+1),' ','') as contrato,
--MONTO ASEGURADO,
0,
sum(sd.montopagado) as montopagado,
--TIPO MICROSEGURO,
'MS'
from socio s, (select mc.socioid, sum(mp.debe)-sum(mp.haber) as montopagado from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid ='MS' and p.polizaid = mc.polizaid  and p.fechapoliza >= pfechai and p.fechapoliza < pfechac+1  group by mc.socioid ) sd
where s.fechaalta >= pfechai and s.fechaalta <pfechac+1 and s.socioid=sd.socioid group by s.clavesocioint,s.socioid order by s.clavesocioint

        loop

           r.montoasegurado:=(trunc(r.montopagado/25)*5000);
           if r.montopagado > 0 then
              return next r;
           end if;
        end loop;

return;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;


CREATE OR REPLACE FUNCTION patmir3micc(date,date)
  RETURNS SETOF rpatmir3mic AS
$BODY$
declare

  r rpatmir3mic%rowtype;

  pfechai alias for $1;
  pfechaf alias for $2;
  
  f record;

  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from  patmir3mic('||''''||pfechai||''''||','||''''||pfechaf||''''||');';

--        raise notice 'dblink % % ',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(
		  -- FOLIO IF
		  folio_if integer,
 		  --clave socio/cliente
		  clavesocio character varying(40),
                  contrato character(10),
		  --MONTO ASEGURADO	
		  montoasegurado numeric,
		  --MONTO PAGADO	
		  montopagado numeric,  
       		  --TIPO MICROSEGURO
		  tipo_microseguro character(2)
               )

        loop
                return next r;
        end loop;

 end loop;

return;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;





  
