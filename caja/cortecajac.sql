CREATE OR REPLACE FUNCTION cortecajac(character, date, integer) RETURNS SETOF rcortecaja
    AS $_$
declare
 pserie alias for $1;
 pfecha alias for $2;
 presumido alias for $3;
 r rcortecaja%rowtype;
 f record;
 dblink1 text;
 dblink2 text;

begin
 for f in
   SELECT *from sucursales where vigente='S'
 loop
     raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

     dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
     dblink2:='set search_path to public,'||f.esquema||'; select * from cortecaja('||''''||pserie||''''||',
     '||''''||to_char(pfecha,'yyyy-mm-dd')||''''||','||''''||presumido||''''||');';
     for r in
      SELECT * FROM
        dblink(dblink1,dblink2) as t2 (folio integer,
	referencia integer,
	serie character(2),
	socioid integer,
	clavesocioint character(15),
	fecha date,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	deposito numeric,
	retiro numeric,
	tipomovimientoid character(2),
	tipoprestamoid character(3),
	cobranza numeric)


     loop
       return next r;
     end loop;

 end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;