drop function spssujetopld(character varying);

create type rsujetopld as (
	sucursal character (3), 
sujetoid integer,
paterno character varying(20),
materno character varying(20),
nombre character varying(40),
rfc character(16),
curp character(20),
edad numeric,
fecha_nacimiento date,
razonsocial character varying(60)
);

CREATE or replace FUNCTION spssujetopld(character varying) RETURNS SETOF rsujetopld
    AS $_$
declare
  r rsujetopld%rowtype;
  pclave alias for $1;
  filtro text;
begin

    filtro := pclave || '%';
    for r in
      select (select substr(sucid,1,3) from sucursales limit 1),s.sujetoid,s.paterno,s.materno,s.nombre,s.rfc,s.curp,s.edad,
             s.fecha_nacimiento,s.razonsocial
        from sujeto s
       where
             (upper(s.nombre||' '||s.paterno||' '||s.materno) like upper(filtro) or
              upper(s.paterno||' '||s.materno||' '||s.nombre) like upper(filtro) or
			  upper(s.paterno||' '||s.materno) like upper(filtro) or
			  upper(s.materno||' '||s.paterno) like upper(filtro) or
             upper(s.nombre)  like upper(filtro) or
             upper(s.paterno) like upper(filtro) or
             upper(s.materno) like upper(filtro) or
			 upper(s.rfc) like upper(filtro))
    loop
      return next r;
    end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;