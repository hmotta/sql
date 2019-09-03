CREATE or replace FUNCTION existeciudad(integer) RETURNS integer
    AS $_$
declare
  pciudadmexid alias for $1;
  pciudadmexidn int4;
begin

  select ciudadmexid into pciudadmexidn from ciudadesmex where ciudadmexid=pciudadmexid;
  
  pciudadmexidn:= coalesce(pciudadmexidn,14);

return pciudadmexidn;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
