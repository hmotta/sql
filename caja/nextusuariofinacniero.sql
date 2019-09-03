CREATE or replace FUNCTION nextusuariofinanciero() RETURNS character
    AS $$
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
   where tiposocioid='06' and
         substr(clavesocioint,1,4)=ssucid;

  lsocioid = coalesce(lsocioid,1);

  snextsocio:=trim(ssucid)||trim(to_char(lsocioid,'00000')||'-06');

return snextsocio;
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;
