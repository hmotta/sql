drop type rpfolioscancelados cascade;
CREATE TYPE rpfolioscancelados AS (
	referencia integer,
	serie character(2),
	numero_poliza integer,
	tipomovimientoid character(2),
	clavesocioint character(15),
	fecha date,
	concepto character(40)
);

CREATE or replace FUNCTION rptfolioscancelados(date, date, character) RETURNS SETOF rpfolioscancelados
    AS $_$
declare
  r rpfolioscancelados%rowtype;
  pfechai alias for $1;
  pfechaf alias for $2;
  pserie  alias for $3;

begin

    if pserie = '  ' then 
     for r in
       select mc.referenciacaja,mc.seriecaja,p.numero_poliza,mc.tipomovimientoid,s.clavesocioint,p.fechapoliza,p.concepto_poliza           
         from movicaja mc, socio s, polizas p
        where mc.estatusmovicaja='C' and mc.polizaid=p.polizaid and p.fechapoliza between pfechai and pfechaf and mc.socioid = s.socioid           
      order by mc.seriecaja, mc.referenciacaja
     loop      
       return next r;
     end loop;
    else 
      for r in
       select mc.referenciacaja,mc.seriecaja,p.numero_poliza,mc.tipomovimientoid,s.clavesocioint,p.fechapoliza,p.concepto_poliza           
         from movicaja mc, socio s, polizas p
        where mc.estatusmovicaja='C' and mc.seriecaja=pserie and mc.polizaid=p.polizaid and p.fechapoliza between pfechai and pfechaf and mc.socioid = s.socioid           
      order by mc.seriecaja, mc.referenciacaja
     loop      
       return next r;
     end loop;
    end if;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
    
    
CREATE or replace FUNCTION rptfolioscanceladosc(date, date) RETURNS SETOF rpfolioscancelados
    AS $_$
declare

  pfechainicio alias for $1;
  pfechafinal alias for $2;
  r rformatosociopatmirv2%rowtype;

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
        dblink2:='set search_path to public,'||f.esquema||';select * from  spssociopatmirv2('||''''||pfechainicio||''''||','||''''||pfechafinal||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	folio_if character varying(5),
	clave_socio_cliente character varying(18),
	primer_apellido character varying(26),
	segundo_apellido character varying(26),
	nombre character varying(150),
	sexo character varying(15),
	fecha_de_nacimiento character(15),
	lengua character varying(20),
	ocupacion character varying(40),
	actividad_productiva character varying(40),
	estado_civil character varying(14),
	escolaridad character varying(12),
	fecha_alta_en_sistema character(15),
	calle character varying(90),
	numero_exterior character varying(15),
	numero_interior character varying(15),
	colonia character varying(150),
	codigo_postal character(5),
	localidad character varying(49),
	municipio character varying(40),
	estado character varying(50),
	capital_social_requerido character varying(12),
	saldo_de_aportacion_requerido character varying(12),
	saldo_de_aportacion_excedente character varying(12),
	saldo_de_aportacion_voluntario character varying(12),
	sucursal character varying(35),
	usuario_captura character varying(20),
	fecha_baja character(15),
	persona_moral character(15),
	telefono 	character varying(20)								--30
)
	
        loop
       --   r.clave:=i;
        --  i:=i+1;
          return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
