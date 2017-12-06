CREATE OR REPLACE FUNCTION spidesbhuella( integer, character, integer, character, character, character) RETURNS integer
    AS $_$
declare
   preferenciacaja	alias for $1;
   pseriecaja		alias for $2;
   pmovibancoid		alias for $3;
   pmotivo			alias for $4;
   ptexto			alias for $5;
   pusuario			alias for $6;
   
begin

   insert into desbhuella (referenciacaja,seriecaja,movibancoid,motivo,descripcion,usuariodesbloquea) values (preferenciacaja,pseriecaja,pmovibancoid,pmotivo,ptexto,pusuario);   
	return currval('desbhuella_desbhuellaid_seq');
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;