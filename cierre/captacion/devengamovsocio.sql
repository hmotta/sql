CREATE or replace FUNCTION devengamovsocio(character, character, date, date) RETURNS numeric
    AS $_$
declare
  pclavesocioint alias for $1;
  ptipomovimientoid alias for $2;
  pfecha1 alias for $3;
  pfecha2 alias for $4;

  r record;

  finteres numeric;
  lsocioid int4;
  gdiasanualesmov int4;
begin

    select diasanualesmov
      into gdiasanualesmov
      from empresa
     where empresaid=1;

  select socioid into lsocioid
    from socio where clavesocioint=pclavesocioint;


SELECT SUM(round((case when p.fechapoliza<pfecha1 then
             mp.haber-mp.debe else 0 end)*(pfecha2-pfecha1)*t.tasainteres/100/gdiasanualesmov,2)) +
       SUM(round(case when p.fechapoliza>pfecha1-1 then
              mp.haber*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
            else 0 end,2)) -
       SUM(round(case when p.fechapoliza>pfecha1-1 then
               mp.debe*(pfecha2-p.fechapoliza)*t.tasainteres/100/gdiasanualesmov
             else 0 end,2)) as interes
  into finteres
  FROM movicajag m, polizas p, movipolizas mp, tipomovimiento t
 WHERE p.fechapoliza between '1900-01-01' and pfecha2 and
       mp.polizaid = p.polizaid and
       (mp.cuentaid = t.cuentadeposito or mp.cuentaid=t.cuentaretiro) and
       m.polizaid = p.polizaid and
       m.tipomovimientoid=ptipomovimientoid and    
       t.tipomovimientoid = m.tipomovimientoid and
       t.tasainteres > 0 and m.socioid=lsocioid;

  finteres := coalesce(finteres,0);

return finteres;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;