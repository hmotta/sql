
CREATE or replace FUNCTION spiinversion(integer, character, integer, character, numeric, numeric, numeric, date, date, date, integer, numeric, numeric, date, date, character, numeric, numeric, integer, integer) RETURNS integer
    AS $_$
declare
  psocioid                       alias for $1;
  ptipoinversionid               alias for $2;
  preferenciainver               alias for $3;
  pserieinver                    alias for $4;
  pdepositoinversion             alias for $5;
  pretiroinversion               alias for $6;
  pinteresinversion              alias for $7;
  pfechainversion                alias for $8;
  pfechavencimiento              alias for $9;
  pultimarenovacion              alias for $10;
  pnoderenovaciones              alias for $11;
  ptasainteresnormalinversion    alias for $12;
  ptasainteresmoratorioinversion alias for $13;
  pfechapagoinversion            alias for $14;
  pfechapagoanterior             alias for $15;
  preinversionautomatica         alias for $16;
  pdepositoanteside              alias for $17;
  pide                           alias for $18;
  pinversionanterior             alias for $19;
  pmanejo                        alias for $20;
   
  r record;
  
  pref int4;

  sclavesocioint char(15);
  stiposocioid char(2);

  iclasificacionid int4;

  linversionid int4;
  lfoliocertificado int4;
  
  lindicadorid int4;
  fpuntos numeric;
  ftasacalculada numeric;
  fvalor numeric;
 
  
begin

  select clavesocioint,tiposocioid
    into sclavesocioint,stiposocioid
    from socio
   where socioid=psocioid;

   if stiposocioid='01' then
     --raise exception 'El socio menor no puede realizar este tipo de movimiento.';
   end if;



   
   ftasacalculada := ptasainteresnormalinversion ;
      
   --select coalesce(max(referenciainversion),0) into pref
   --  from inversion
   -- where serieinversion=pserieinver;

   --  pref := pref + 1;
   pref := preferenciainver;
   
   insert into inversion(tipoinversionid,socioid,referenciainversion,serieinversion,depositoinversion,retiroinversion,interesinversion,fechainversion,fechavencimiento,ultimarenovacion,noderenovaciones,tasainteresnormalinversion,tasainteresmoratorioinversion,fechapagoinversion,fechapagoanterior,reinversionautomatica,depositoanteside,ide,inversionanteriorid,manejo)
    values( ptipoinversionid,
            psocioid,
            pref,
            pserieinver,
            pdepositoinversion,
            pretiroinversion,
            pinteresinversion,
            pfechainversion,
            pfechavencimiento,
            pultimarenovacion,
            pnoderenovaciones,
            ftasacalculada,
            ptasainteresmoratorioinversion,
            pfechapagoinversion,
            pfechapagoanterior,
            preinversionautomatica,pdepositoanteside,pide,pinversionanterior,pmanejo);

select currval('inversion_inversionid_seq') into linversionid;

-- Agregar los beneficiarios

for r in select * from beneficiario where inversionid=pinversionanterior
loop 

     insert into beneficiario(inversionid,socioid,sujetoid,parentesco,porcentajebeneficiario)
     values( linversionid,
            r.socioid,
            r.sujetoid,
            r.parentesco,
            r.porcentajebeneficiario);
            
end loop;

-- Verificar si es certificado

  if iclasificacionid=1 then
    select max(foliocertificado)
      into lfoliocertificado
      from certificado;

    lfoliocertificado:=coalesce(lfoliocertificado,0);
    lfoliocertificado:=lfoliocertificado+1;

    insert into certificado values (linversionid,lfoliocertificado);

  end if;


return linversionid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


 CREATE or replace FUNCTION spiinversion(integer, character, integer, character, numeric, numeric, numeric, date, date, date, integer, numeric, numeric, date, date, character, numeric, numeric, integer) RETURNS integer
    AS $_$
declare
  psocioid                       alias for $1;
  ptipoinversionid               alias for $2;
  preferenciainver               alias for $3;
  pserieinver                    alias for $4;
  pdepositoinversion             alias for $5;
  pretiroinversion               alias for $6;
  pinteresinversion              alias for $7;
  pfechainversion                alias for $8;
  pfechavencimiento              alias for $9;
  pultimarenovacion              alias for $10;
  pnoderenovaciones              alias for $11;
  ptasainteresnormalinversion    alias for $12;
  ptasainteresmoratorioinversion alias for $13;
  pfechapagoinversion            alias for $14;
  pfechapagoanterior             alias for $15;
  preinversionautomatica         alias for $16;
  pdepositoanteside              alias for $17;
  pide                           alias for $18;
  pmanejo                        alias for $19;
   
  r record;
  
  pref int4;

  sclavesocioint char(15);
  stiposocioid char(2);

  iclasificacionid int4;

  linversionid int4;
  lfoliocertificado int4;
  
  lindicadorid int4;
  fpuntos numeric;
  ftasacalculada numeric;
  fvalor numeric;
  fmontominimo numeric;
  fmontomaximo numeric;

  
begin

  select clavesocioint,tiposocioid
    into sclavesocioint,stiposocioid
    from socio
   where socioid=psocioid;

   
   select clasificacionid,montomaximo,montominimo into iclasificacionid,fmontomaximo,fmontominimo
     from tipoinversion where tipoinversionid=ptipoinversionid;

   if pdepositoinversion > fmontomaximo then
      raise exception 'El deposito excede el monto maximo';
   end if;
   
   if pdepositoinversion < fmontominimo then
      raise exception 'El deposito es menor al monto maximo';
   end if;
   
   
   if stiposocioid='01' then
     --raise exception 'El socio menor no puede realizar este tipo de movimiento.';
   end if;

   ftasacalculada := ptasainteresnormalinversion ;
  
   --select coalesce(max(referenciainversion),0) into pref
   --  from inversion
   -- where serieinversion=pserieinver;

   --  pref := pref + 1;
   
   pref := preferenciainver;
   
   insert into inversion(tipoinversionid,socioid,referenciainversion,serieinversion,depositoinversion,retiroinversion,interesinversion,fechainversion,fechavencimiento,ultimarenovacion,noderenovaciones,tasainteresnormalinversion,tasainteresmoratorioinversion,fechapagoinversion,fechapagoanterior,reinversionautomatica,depositoanteside,ide,manejo)
    values( ptipoinversionid,
            psocioid,
            pref,
            pserieinver,
            pdepositoinversion,
            pretiroinversion,
            pinteresinversion,
            pfechainversion,
            pfechavencimiento,
            pultimarenovacion,
            pnoderenovaciones,
            ftasacalculada,
            ptasainteresmoratorioinversion,
            pfechapagoinversion,
            pfechapagoanterior,
            preinversionautomatica,pdepositoanteside,pide,pmanejo);

select currval('inversion_inversionid_seq') into linversionid;


-- Verificar si es certificado

  if iclasificacionid=1 then
    select max(foliocertificado)
      into lfoliocertificado
      from certificado;

    lfoliocertificado:=coalesce(lfoliocertificado,0);
    lfoliocertificado:=lfoliocertificado+1;

    insert into certificado values (linversionid,lfoliocertificado);

  end if;


return linversionid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
   
