alter table conoceatucliente add estatus character varying(20) default 'Socio';
alter table empresa add vicepresidenteadmon character varying(80);
alter table empresa add secreadmon character varying(80);
alter table empresa add prosecreadmon character varying(80);
alter table empresa add vocaladmon character varying(80);
alter table empresa add presidentevigilancia character varying(80);
alter table empresa add secrevigilancia character varying(80);
alter table empresa add vocalvigilancia character varying(80);

drop type rstatusconocecliente cascade;
CREATE TYPE rstatusconocecliente AS (
	clavesocioint character(15)
);

CREATE or replace FUNCTION estatusconoceclientec(character) RETURNS SETOF rstatusconocecliente
    AS $_$
declare
 tipo alias for $1;

 r rstatusconocecliente%rowtype;
 f record;
 dblink1 text;
 dblink2 text;

begin
 for f in
   SELECT *from sucursales where vigente='S'   
 loop
     raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

     dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
     dblink2:='set search_path to public,'||f.esquema||'; select trim(clavesocioint) from socio s,conoceatucliente c where s.socioid=c.socioid and c.estatus='''||tipo||''';';
     for r in
      SELECT * FROM
        dblink(dblink1,dblink2) as t2 (socioid char(15))
     loop
       return next r;
     end loop;
 end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


drop type tcobrador cascade;
CREATE TYPE tcobrador AS (
	cobradorid integer,
	sujetoid integer,
	paterno character varying(20),
	materno character varying(20),
	nombre character varying(40),
	razonsocial character varying(80)
);

CREATE or replace FUNCTION spscobradormensaje(text) RETURNS SETOF tcobrador
    AS $_$
declare
  pfiltro alias for $1; 
  r tcobrador%rowtype;
  filtro text;
begin
    filtro := pfiltro || '%';
    for r in
      select c.cobradorid,j.sujetoid,j.paterno,j.materno,j.nombre,j.razonsocial
        from cobradores c, sujeto j
       where j.sujetoid = c.sujetoid and         
             (j.sujetoid like filtro or
              (j.nombre||' '||j.paterno||' '||j.materno) like filtro or
              (j.paterno||' '||j.materno||' '||j.nombre) like filtro or
	      j.razonsocial like filtro)
      order by j.sujetoid
    loop
      return next r;
    end loop;
return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

DROP TABLE cobradores;
CREATE TABLE cobradores (
    cobradorid integer primary key,
    sujetoid integer references sujeto(sujetoid)
);

DROP TABLE carteracobrador;
CREATE TABLE carteracobrador (
    cobradorid integer references cobradores(cobradorid),
    prestamoid integer references prestamos (prestamoid) 
);

CREATE or replace FUNCTION spicobradores(character,character,character,character) RETURNS integer
    AS $_$
declare
 
  ppaterno alias for $1;
  pmaterno alias for $2;
  pnombre  alias for $3;
  prazonsoc alias for $4;

  pcobradorid integer;
  psujetoid integer;
begin

  insert into sujeto(paterno,materno,nombre,razonsocial) values(ppaterno,pmaterno,pnombre,prazonsoc);
  select max(sujetoid) into psujetoid from sujeto;
  select coalesce(max(cobradorid),0)+1 into pcobradorid from cobradores;

  insert into cobradores(cobradorid,sujetoid) values (pcobradorid,psujetoid);
return 1;
end
$_$
    LANGUAGE plpgsql;

CREATE or replace FUNCTION spucobradores(integer,character,character,character,character) RETURNS integer
    AS $_$
declare
 
  pcobradorid alias for $1;
  ppaterno alias for $2;
  pmaterno alias for $3;
  pnombre  alias for $4;
  prazonsoc alias for $5;

  psujetoid integer;
begin

  select coalesce(sujetoid,0) into psujetoid from cobradores where cobradorid=pcobradorid;

  update sujeto set paterno=ppaterno,materno=pmaterno,nombre=pnombre,razonsocial=prazonsoc where sujetoid=psujetoid;
return 1;
end
$_$
    LANGUAGE plpgsql;

CREATE or replace FUNCTION spdcobradores(integer) RETURNS integer
    AS $_$
declare
 
  pcobradorid alias for $1;

  psujetoid integer;
begin

  select coalesce(sujetoid,0) into psujetoid from cobradores where cobradorid=pcobradorid;
  delete from cobradores where cobradorid=pcobradorid;
  delete from sujeto where sujetoid=psujetoid;  

return 1;
end
$_$
    LANGUAGE plpgsql;

drop type tcarteracobrador cascade;
CREATE TYPE tcarteracobrador AS (
	prestamoid integer,
	referenciaprestamo character varying(18),
	montoprestamo numeric
);

CREATE or replace FUNCTION spicarteracobrador(integer,character) RETURNS integer
    AS $_$
declare 
  pcobradorid alias for $1;
  preferenciaprestamo alias for $2;

  pprestamoid integer;
  pprestamoid1 integer;
begin
  select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo and claveestadocredito<>'002' and claveestadocredito<>'008';
  if found then
    select prestamoid into pprestamoid1 from carteracobrador where cobradorid=pcobradorid and prestamoid=pprestamoid;
    if not found then   
        insert into carteracobrador(cobradorid,prestamoid) values(pcobradorid,pprestamoid);
  	end if;
  end if;
return 1;
end
$_$
    LANGUAGE plpgsql;

CREATE or replace FUNCTION spdcarteracobrador(integer) RETURNS integer
    AS $_$
declare 
  pprestamoid alias for $1;

  pcobradorid integer;
begin
  select cobradorid into pcobradorid from carteracobrador where prestamoid=pprestamoid;
  if found then
     delete from carteracobrador where cobradorid=pcobradorid and prestamoid=pprestamoid;
  end if;
return 1;
end
$_$
    LANGUAGE plpgsql;
