CREATE OR REPLACE FUNCTION "public"."generasocio"(int4, bpchar)
  RETURNS "pg_catalog"."int4" AS $BODY$
declare

  lnosolicitud alias for $1;
  pclavesocioint alias for $2;
  sclavesocioint char(15);
  lsocioid int4;

  lsujetoid int4;
  stiposocioid char(2);
  lsolicitudingresoid int4;
  fsocioid int4;

  sgenerasocio char(1);

  stmp varchar;
begin

  select generasocio into sgenerasocio
   from empresa where empresaid=1;

if sgenerasocio='S' then

  select coalesce(socioid,0)
    into fsocioid
    from solicitudingreso
   where nosolicitud=lnosolicitud;

  raise notice 'SocioID %',fsocioid;

  if fsocioid=0 then

    raise notice 'Empieza la generacion ';

    select sujetoid,tiposocioid,solicitudingresoid
      into lsujetoid,stiposocioid,lsolicitudingresoid
      from solicitudingreso
     where nosolicitud=lnosolicitud;

     if stiposocioid='01' then
       select nextsociom()
         into sclavesocioint;
     else
	if stiposocioid='06' then
		select nextusuariofinanciero()
         	into sclavesocioint;
	elsif stiposocioid='07' then
		select nextsociogenerico()
         	into sclavesocioint;
	else
       		raise notice 'Generando socio ...';
       		select nextsocio()
         	into sclavesocioint;
	end if;
     end if;

     -- Insertar el socio
     select * into lsocioid from
       spisocio(lsocioid,lsujetoid,stiposocioid,sclavesocioint,
                CURRENT_DATE,NULL,1,lsolicitudingresoid,NULL);

     update solicitudingreso
        set socioid=lsocioid
      where nosolicitud=lnosolicitud;
  else
      lsocioid := fsocioid;
  end if;
else

  stmp := ltrim(rtrim(pclavesocioint));  
  if char_length(stmp)>8 then

    -- No lo genera automaticamente
    select coalesce(max(socioid),0)
      into fsocioid
      from socio
     where clavesocioint=pclavesocioint;

    if fsocioid=0 then
      select sujetoid,tiposocioid,solicitudingresoid
        into lsujetoid,stiposocioid,lsolicitudingresoid
        from solicitudingreso
       where nosolicitud=lnosolicitud;


      -- Insertar el socio
       select * into lsocioid from
         spisocio(lsocioid,lsujetoid,stiposocioid,pclavesocioint,
                  CURRENT_DATE,NULL,1,lsolicitudingresoid,NULL);

       update solicitudingreso
          set socioid=lsocioid
        where nosolicitud=lnosolicitud; 

    else
      raise exception 'La clave % ya existe asignada a otro socio!',pclavesocioint;
    end if;
  else
    raise exception 'La clave % proporcionada es incorrecta!',pclavesocioint;
  end if;

end if;




return lsocioid;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100