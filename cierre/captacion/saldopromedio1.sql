CREATE or replace FUNCTION saldopromedio(integer, date, date, character) RETURNS numeric
    AS $_$ 
DECLARE

  lsocioid alias for $1;
  dfechai alias for $2;
  dfechaf alias for $3;
  stipomovimientoid alias for $4;
  fpromedio numeric;

BEGIN 
  fpromedio:=0;

SELECT SUM(round((case when p.fechapoliza<dfechai then
             (mp.haber-mp.debe)*(dfechaf-dfechai) else 0 end),2)) +
       SUM(round(case when p.fechapoliza>dfechai-1 then
             (mp.haber-mp.debe)*(dfechaf-p.fechapoliza) else 0 end,2))
  INTO fpromedio
  FROM ( select ml.socioid, ml.tipomovimientoid, ml.polizaid,
                ml.referenciacaja, ml.seriecaja
           from movicaja ml
          where ml.socioid=lsocioid and
                ml.tipomovimientoid=stipomovimientoid
       GROUP BY ml.socioid, ml.tipomovimientoid, ml.polizaid,
                ml.referenciacaja, ml.seriecaja ) as m,
       polizas p, movipolizas mp, tipomovimiento t, socio s
 WHERE m.socioid=lsocioid and
       m.tipomovimientoid=stipomovimientoid and
       p.polizaid = m.polizaid and
       p.fechapoliza between '1900-01-01' and dfechaf and
       mp.polizaid = p.polizaid and
       (mp.cuentaid = t.cuentadeposito or mp.cuentaid=t.cuentaretiro) and
       t.tipomovimientoid = m.tipomovimientoid and
       t.tasainteres > 0 and 
       s.socioid = m.socioid and 
       (s.estatussocio=1 or s.estatussocio=3 or fechabaja > dfechaf);  

  fpromedio:=coalesce(fpromedio,0);

RETURN round(fpromedio/(dfechaf-dfechai),2); 
END; 
$_$
    LANGUAGE plpgsql SECURITY DEFINER;