-- Function: spicobrolegal(integer, integer, date, integer, character, text, text)

DROP FUNCTION spicobrolegal(integer, integer, date, integer, character, text, text);

CREATE OR REPLACE FUNCTION spicobrolegal(integer, integer, date, integer, character, text, text)
  RETURNS integer AS
$BODY$
declare
  pprestamoid alias for $1;
  pabogadoid alias for $2;
  pfechacobrolegal alias for $3;
  ptipocobrolegalid alias for $4;
  prealiza alias for $5;
  ptextocobrolegal alias for $6;
  ptextoresultado alias for $7;

  preferenciaprestamo char(18);
  psocioid integer;
  

begin

  select referenciaprestamo,socioid into preferenciaprestamo,psocioid from prestamos where prestamoid=pprestamoid;

  insert into cobrolegal( prestamoid,abogadoid,fechacobrolegal,tipocobrolegalid,realiza,textocobrolegal,textoresultado,socioid,referenciaprestamo )
  values ( pprestamoid,pabogadoid,pfechacobrolegal,ptipocobrolegalid,prealiza,ptextocobrolegal,ptextoresultado,psocioid,preferenciaprestamo );

return currval('cobrolegal_cobrolegalid_seq');

end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
--ALTER FUNCTION spicobrolegal(integer, date, integer, character, text, text) OWNER TO sistema;

