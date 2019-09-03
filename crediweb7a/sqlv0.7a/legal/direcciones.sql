

CREATE or replace FUNCTION spidireccionadicional(integer, integer, character, character, character, character, character, integer, character, character, character) RETURNS integer
    AS $_$
declare
  psocioid      alias for $1;
  pprioridad    alias for $2;
  pdescripcion     alias for $3;
  pcalle  alias for $4;
  pnumero_ext  alias for $5;
  pnumero_int  alias for $6;
  pcolonia  alias for $7;
  pcodpostal  alias for $8;
  pcomunidad  alias for $9;
  pmunicipio  alias for $10;
  pobservacion  alias for $11;
  

  ldomicilioid int4;
  
begin

insert into domicilioadicional(socioid,prioridad,descripcion_corta,calle,numero_ext,numero_int,colonia,codpostal,comunidad,municipio,observacion) values (psocioid,pprioridad,pdescripcion,pcalle,pnumero_ext,pnumero_int,pcolonia,pcodpostal,pcomunidad,pmunicipio,pobservacion);

select currval('domicilioadicional_domicilioadicionalid_seq') into ldomicilioid;

return ldomicilioid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE or replace FUNCTION spitelefonoadicional(integer, integer, character, character) RETURNS integer
    AS $_$
declare
  psocioid      alias for $1;
  pprioridad    alias for $2;
  ptelefono     alias for $3;
  pobservacion  alias for $4;

  ltelefonoid int4;
  
begin

insert into telefonosadicional(socioid,prioridad,telefono,observacion) values (psocioid,pprioridad,ptelefono,pobservacion);

select currval('telefonosadicional_telefonoadicionalid_seq') into ltelefonoid;

return ltelefonoid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
