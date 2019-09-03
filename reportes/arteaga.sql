drop TYPE tcapitalsocialcnbv cascade;
CREATE TYPE tcapitalsocialcnbv AS (
	clave_socio_cliente character varying(18),
	nombresocio character varying(80),
	rfc character(16), 
	curp character(20),
	sucursal character varying(16),
	fechaingreso character(10),
	tipo_de_deposito_cuenta_o_producto character varying(30),
	monto_del_ahorro_o_deposito_plazo_capital numeric,
	num_certificados numeric
	);

CREATE or replace FUNCTION spscapitalsocialcnbv(date, date) RETURNS SETOF tcapitalsocialcnbv
    AS $_$
declare
	pfechaingreso alias for $1;
	pfechacierre alias for $2;
  
  r tcapitalsocialcnbv%rowtype;
  psucid char(4);

begin
select sucid into psucid from empresa where empresaid=1;
	for r in
select
--2clave de socio
Rtrim(captaciontotal.clavesocioint),
--3nombre del socio  
Rtrim(nombresocio), 
--4 rfc 
su.rfc,
--5 curp
(case when length(su.curp)<18 then '' else su.curp end),
--5sucursal 
(select Rtrim(sucid) from empresa where empresaid=1),  
--27 fecha ingreso
(select fechaingreso from solicitudingreso so where so.socioid=captaciontotal.socioid),
--7tipo de depsoito 
Rtrim(desctipoinversion),
--13monto de ahorro  
deposito, 
--Numero de Certificados 
(case when tipomovimientoid in ('P3') then deposito/500 else (case when desctipoinversion in ('PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT') then deposito/500 else 0 end) end)

from captaciontotal, solicitudingreso so, socio s, sujeto su
	where fechadegeneracion=pfechacierre 
	and s.tiposocioid in ('01','02','05')  ----modificado el 07 de Septiembre del 2012
	and s.socioid=captaciontotal.socioid
	and s.sujetoid=su.sujetoid
	and fechaingreso>=pfechaingreso
	and sucursal=psucid 
	and so.socioid=captaciontotal.socioid
	--and tipomovimientoid in ('PA','P3','PB','IN')
	and deposito>0
	and desctipoinversion in ('PARTE SOCIAL','PARTE SOCIAL P3','PARTE SOCIAL ADICIONAL','PARTE SOCIAL ADICIONAL VOLUNTA','PARTE SOCIAL ADICIONAL OBLIGAT')
	order by captaciontotal.clavesocioint, tipomovimientoid

loop 
  
  return next r;

end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--ALTER FUNCTION public.spscapitalsocialcnbv(date, date) OWNER TO sistema;

--
-- Name: spscaptacionpatmirc(date, date); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE or replace FUNCTION spscapitalsocialcnbvc(date, date) RETURNS SETOF tcapitalsocialcnbv
    AS $_$
declare


	pfechaingreso alias for $1;
	pfechacierre alias for $2;



  r tcapitalsocialcnbv%rowtype;

  f record;

  dblink1 text;
  dblink2 text;

  i int;
begin

i:=1;

for f in
 select * from sucursales where vigente='S'
 
  loop

        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        --dblink2:='set search_path to public,'||f.esquema||';select * from  spscapitalsocialcnbv('||''''||pfecha||''''||');';
        dblink2:='set search_path to public,'||f.esquema||';select * from  spscapitalsocialcnbv('||''''||pfechaingreso||''''||','||''''||pfechacierre||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	clave_socio_cliente character varying(18),
	nombresocio character varying(80),
	rfc character(16), 
	curp character(20),
	sucursal character varying(16),
	fechaingreso character(10),
	tipo_de_deposito_cuenta_o_producto character varying(30),
	monto_del_ahorro_o_deposito_plazo_capital numeric,
	num_certificados numeric
	)

        loop
            return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--ALTER FUNCTION public.spscapitalsocialcnbvc(date, date) OWNER TO sistema;

--SET search_path = sucursal10, pg_catalog;

--
-- Name: cargoprestamo; Type: TABLE; Schema: sucursal10; Owner: sistema; Tablespace: 
--

