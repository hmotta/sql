-- Function: patmir3rem(date)

-- DROP FUNCTION patmir3rem(date);

drop TYPE rpatmir3rem cascade;
CREATE TYPE rpatmir3rem AS (
--FOLIO IF
folio_if integer,
--CLAVE SOCIO/CLIENTE
clave_socio_ciente character(15),
--Envio Recpcion
TRANSACCION character(10),
MONTO numeric,
--Nacional internacional
TIPO character(15),
envio_nacional numeric,
recepcion_nacional numeric,
envio_internacional numeric,
recepcion_internacional numeric
);


CREATE OR REPLACE FUNCTION patmir3rem(date,date)
  RETURNS SETOF rpatmir3rem AS
$BODY$
declare

  r rpatmir3rem%rowtype;
  pfechai alias for $1;
  pfechac alias for $2;

begin
  

    for r in
        select
        --FOLIO IF
        14,
        --CLAVE SOCIO/CLIENTE
        s.clavesocioint,
        '' as TRANSACCION,
        0 as monto,
        '' as tipo,
        sum(sd.envio_nacional),
        sum(sd.recepcion_nacional),
        sum(sd.envio_internacional),
        sum(sd.recepcion_internacional)

        from socio s, sujeto  su, solicitudingreso si, 

        (select mc.socioid, sum(mp.debe) as envio_nacional, sum(mp.haber) as recepcion_nacional,0 as envio_internacional ,0 as recepcion_internacional from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid ='RG' and p.polizaid = mc.polizaid  and p.fechapoliza > pfechai and p.fechapoliza < pfechac+1  group by mc.socioid  union 
        select mc.socioid,0 as envio_nacional,0 as recepcion_nacional, sum(mp.debe) as envio_internacional, sum(mp.haber) as recepcion_internacional from movicaja mc, movipolizas mp, tipomovimiento tm, polizas p where mp.movipolizaid=mc.movipolizaid and tm.tipomovimientoid=mc.tipomovimientoid and mc.tipomovimientoid ='EC' and p.polizaid = mc.polizaid  and p.fechapoliza > pfechai and p.fechapoliza < pfechac+1  group by mc.socioid 

        ) sd

        where  s.fechaalta >= pfechai and s.fechaalta < pfechac+1 and  s.sujetoid=su.sujetoid and s.socioid=si.socioid and s.socioid=sd.socioid 
 
        group by  s.clavesocioint order by s.clavesocioint

        loop

            return next r;

        end loop;

return;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;


CREATE or replace FUNCTION patmir3remc(date,date) RETURNS SETOF rpatmir3rem
    AS '
declare

  r rpatmir3rem%rowtype;

  pfechai alias for $1;
  pfechaf alias for $2;
  
  f record;

  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente=''S''
 loop
        raise notice ''Conectando sucursal % % '',f.basededatos,f.esquema;

        dblink1:=''host=''||f.host||'' dbname=''||f.basededatos||'' user=''||f.usuariodb||'' password=''||f.passworddb;
        dblink2:=''set search_path to public,''||f.esquema||'';select * from  patmir3rem(''||''''''''||pfechai||''''''''||'',''||''''''''||pfechaf||''''''''||'');'';

--        raise notice ''dblink % % '',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(
               folio_if integer,
               --CLAVE SOCIO/CLIENTE
               clave_socio_ciente character(15),
               --Envio Recpcion
               TRANSACCION character(10),
               MONTO numeric,
               --Nacional internacional
               TIPO character(15),
               envio_nacional numeric,
               recepcion_nacional numeric,
               envio_internacional numeric,
              recepcion_internacional numeric
              )
        loop
                return next r;
        end loop;

 end loop;

return;
end
'
language 'plpgsql' security definer;

