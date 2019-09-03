CREATE OR REPLACE FUNCTION "public"."cbalanza"(int4, int4)
  RETURNS SETOF "saldos" AS $BODY$
declare
  pejercicio alias for $1;
  pperiodo   alias for $2;

  r saldos%rowtype;
  f record;
  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='select * from saldos where ejercicio='||to_char(pejercicio,9999)||' and periodo='||to_char(pperiodo,99);

        raise notice 'dblink % % ',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(saldoid int4, 
  CuentaID CHAR(24), 
  ejercicio INTEGER, 
  periodo INTEGER, 
  saldoinicialperiodo NUMERIC, 
  cargosdelperiodo NUMERIC, 
  abonosdelperiodo numeric)

 loop
   return next r;
 end loop;

 end loop;

return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER