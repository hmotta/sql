CREATE OR REPLACE FUNCTION "public"."nextsociogenerico"()
  RETURNS "pg_catalog"."bpchar" AS $BODY$
declare
  lsocioid int4;
  lsocio int4;
  snextsocio char(15);
  smaxsocio char(15);
  ssucid char(4);
begin

  select sucid into ssucid from empresa where empresaid=1;
  
  select MAX(cast(substr(trim(both '-' from clavesocioint),5,5) as int4))+1
    into lsocioid
    from socio
   where tiposocioid='07' and
         substr(clavesocioint,1,4)=ssucid;

  lsocioid = coalesce(lsocioid,1);

  snextsocio:=trim(ssucid)||trim(to_char(lsocioid,'00000')||'-07');

return snextsocio;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100