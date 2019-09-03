CREATE FUNCTION spssociopatmircv2(date, date) RETURNS SETOF rformatosociopatmirv2
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
	folio_if character varying(5),							--01
	clave_socio_cliente character varying(18),				--02
	primer_apellido character varying(26),					--03
	segundo_apellido character varying(26),					--04
	nombre character varying(100),							--05
	sexo character varying(10),   							--06
	fecha_de_nacimiento character(10),						--07
	lengua character varying(15),							--08
	ocupacion character varying(40),						--09
	actividad_productiva character varying(40),				--10
	estado_civil character varying(14),						--11
	escolaridad character varying(12),						--12
	fecha_alta_en_sistema character(10),					--13
	calle character varying(90),							--14
	numero_exterior character varying(15),					--15
	numero_interior character varying(15),					--16
	colonia character varying(100),							--17
	codigo_postal character(5),								--18
	localidad character varying(49),						--19
	municipio character varying(40),						--20
	estado character varying(50),							--21
	capital_social_requerido character varying(12),					--22
	--requerido character varying(12),						--23
	saldo_de_aportacion_requerido character varying(12),	--24
	saldo_de_aportacion_excedente character varying(12),	--25
	saldo_de_aportacion_voluntario character varying(12),	--26
	sucursal character varying(35),							--27
	usuario_captura character varying(20),					--28
	fecha_baja character(10),								--29
	persona_moral character(10)								--30
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