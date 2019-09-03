CREATE OR REPLACE FUNCTION spsinversion(integer) RETURNS SETOF inversion
    AS $_$
declare
  r inversion%rowtype;
  pclave alias for $1;

  icalculoid int;

  sformula text;
  rec record;
  idias int;

  dfecha date;

  ssolodiaspactados char(1);
 

begin

    select solodiaspactados
      into ssolodiaspactados
      from empresa
    where empresaid=1;

    for r in
      -- Solo las no canceladas
      select * from inversion where inversionid=pclave and depositoinversion>0
    loop
      
      select max(p.fechapoliza)
        into dfecha
        from movicaja m, polizas p
       where m.inversionid=r.inversionid and m.estatusmovicaja='A' and
             p.polizaid = m.polizaid;

      --raise notice ' fecha pago anterior %',dfecha;

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

        if r.noderenovaciones= 3 then

           select interesgeneradoinversion into r.interesinversion from interesgeneradoinversion(r.inversionid);

        else 

          select interesgeneradoinversionvencimiento into r.interesinversion from interesgeneradoinversionvencimiento(r.inversionid);

        end if;

        if r.interesinversion<0 then
          r.interesinversion:=0;
        end if;

        --raise notice ' % ', r.interesinversion;

      return next r;
    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
