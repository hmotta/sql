CREATE OR REPLACE FUNCTION spsinversiones(integer) RETURNS SETOF inversion
    AS $_$
declare
  r inversion%rowtype;
  pclave alias for $1;

  icalculoid int;
  idias int;


  sformula text;
  rec record;

  dfecha date;
  ssolodiaspactados char(1);
begin

    select solodiaspactados
      into ssolodiaspactados
      from empresa
    where empresaid=1;

    for r in
      select inversionid,socioid,tipoinversionid,referenciainversion,serieinversion,depositoinversion,retiroinversion,interesinversion,fechainversion,fechavencimiento,ultimarenovacion,noderenovaciones,tasainteresnormalinversion,tasainteresmoratorioinversion,fechapagoinversion,fechapagoanterior,reinversionautomatica,depositoanteside,ide,inversionanteriorid,isr from inversion
       where socioid=pclave and depositoinversion>retiroinversion  --and tipoinversionid<>'K3'
    loop

      select max(p.fechapoliza)
        into dfecha
        from movicaja m, polizas p
       where m.inversionid=r.inversionid and m.estatusmovicaja='A' and
             p.polizaid = m.polizaid;

      if r.fechapagoinversion<dfecha then

        r.fechapagoinversion := dfecha;
        update inversion
           set fechapagoinversion = dfecha
         where inversionid=r.inversionid;

      end if;

      select calculoid
        into icalculoid
        from tipoinversion
       where tipoinversionid = r.tipoinversionid;        
       
        idias := r.fechavencimiento - r.fechainversion;
        
        if idias<0 then
          idias := 0;
        end if;

        select interesgeneradoinversion into r.interesinversion from interesgeneradoinversion(r.inversionid);      
     
        r.interesinversion := coalesce(r.interesinversion,0);
        if r.interesinversion<0 then
          r.interesinversion:=0;
        end if;
        
        select isrinversionmes into r.isr from isrinversionmes(r.inversionid);      
     
        r.isr := coalesce(r.isr,0);
        if r.isr<0 then
          r.isr:=0;
        end if;

        r.interesinversion:=r.interesinversion-r.isr;        

        --raise notice ' % ', r.interesinversion;     

      return next r;
    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
