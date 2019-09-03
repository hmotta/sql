-- Function: reportecaptacionc(date)

-- DROP FUNCTION reportecaptacionc(date);

CREATE OR REPLACE FUNCTION reportecaptacionc(date)
  RETURNS SETOF treportecaptacion AS
$BODY$
declare
  pfechacierre alias for $1;

  r treportecaptacion%rowtype;

  f record;

  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from  reportecaptacion('||''''||to_char(pfechacierre,'yyyy-mm-dd')||''''||');';
        for r in
        SELECT * FROM
        dblink(dblink1,
               dblink2) as
               t2(
                sucursal character(4),
    desctipoinversion character(30),
    clavesocioint character(18),
    nombresocio character varying(80),
    inversionid integer,
    fechainversion date,
    fechavencimiento date,
    tasainteresnormalinversion numeric,
    plazo integer,
    deposito numeric,
    diasvencimiento integer,
    formapagorendimiento integer,
    intdevmensual numeric,
    intdevacumulado numeric,
    saldototal numeric,
    saldopromedio numeric,
    fechapagoinversion date,
    tipomovimientoid character(2),
    cuentaid character(24),
    localidad integer,
    grupo character(25),
    nocontrato integer,    
    socioid integer,
    diaspromedio integer,
    isr numeric
  )
  loop

    return next r;

  end loop;

end loop;
 
return;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
ALTER FUNCTION reportecaptacionc(date) OWNER TO crediweb;

