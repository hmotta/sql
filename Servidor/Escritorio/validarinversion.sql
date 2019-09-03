drop TYPE rvalidarinversion cascade;
CREATE TYPE rvalidarinversion AS (
	sucursal character(4),
	clave_socio_cliente character varying(18), 
        nombre character varying(100),
	inversionid numeric,
        fechainversion date,
	fechavencimiento date,
 	tasainteresnormalinversion numeric,
	plazo integer,
	deposito numeric,
	dias integer,
	ultimopago date,
	interes numeric,	
	tipo character(10),
	fechactual date,
	status character varying(100),
	montominporprodu numeric,
	montomaxporprodu numeric,
	tasaporprodu numeric,
	plazoporprodu numeric,
	descporprodu character varying(100)
	);
CREATE or replace FUNCTION spsvalidarinversion(date) RETURNS SETOF rvalidarinversion
    AS $_$
declare

	pfecha  alias for $1;
	
  r rvalidarinversion%rowtype;
  pmultiplica numeric;
  pnombre character varying(40);
  i int;
begin

  i:=1;
  for r in
       select
	--1 sucursal
		substring(v.clavesocioint,1,4),
	--2 clave socio
		v.clavesocioint,
	--3 nombre socio
		v.nombresocio,
	--4 inverionid
		v.inversionid,
	--5 fecha de inversion
		v.fechainversion,
	--6 fecha de vencimiento
		v.fechavencimiento,
	--7 tasa de interes normal de inversion
		v.tasainteresnormalinversion,
	--8 plazo
		v.plazo,
	--9 deposito
		v.deposito,
	--10 dias de vencimiento
		v.diasvencimiento,
	--11 clave socio
		v.fechapagoanterior,
	--12 clave socio
		v.interes,
	--13 clave socio
		v.tipoinversionid,
	--fecha actual
        	(select substr(now(),1,10)),
	--status
		'' as status,
	---monto minimo propuesto por tipo inversion
		(select montominimo from tipoinversion  where tipoinversionid=v.tipoinversionid),
	---monto maximo propuesto por tipo inversion
		(select montomaximo from tipoinversion  where tipoinversionid=v.tipoinversionid),
	---tasa propuesto por tipo inversion
		(select tasa_normal_inversion from tipoinversion  where tipoinversionid=v.tipoinversionid),
	---tasa propuesto por tipo inversion
		(select plazo from tipoinversion  where tipoinversionid=v.tipoinversionid),
	---descripcion de  inversion
		(select desctipoinversion   from tipoinversion  where tipoinversionid=v.tipoinversionid)

			from inversionesxfecha(pfecha) v

		


    loop
   	IF r.fechavencimiento<= r.fechactual THEN
		r.status='Falta Reinvertir';
	
	ELSE
	r.status='Bien';
	END IF;
	
        
	
    return next r;
  end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION spsvalidarinversionc(date) RETURNS SETOF rvalidarinversion
    AS $_$
declare

  pfechaingreso alias for $1;
 
  r rvalidarinversion%rowtype;

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
	dblink2:='set search_path to public,'||f.esquema||';select * from  spsvalidarinversion('||''''||pfechaingreso||''''||');';
        --dblink2:='set search_path to public,'||f.esquema||';select * from  spscreditopatmir('||''''||pfecha||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	sucursal character(4),
	clave_socio_cliente character varying(18), 
        nombre character varying(100),
	inversionid numeric,
        fechainversion date,
	fechavencimiento date,
 	tasainteresnormalinversion numeric,
	plazo integer,
	deposito numeric,
	dias integer,
	ultimopago date,
	interes numeric,	
	tipo character(10),
	fechactual date,
	status character varying(100),
	montominporprodu numeric,
	montomaxporprodu numeric,
	tasaporprodu numeric,
	plazoporprodu numeric,
	descporprodu character varying(100)


	
)
        loop

          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

