CREATE FUNCTION movimientos(character, character, date, date, character, character) RETURNS SETOF movimientos
    AS $_$
declare
  pcuentai    alias for $1;
  pcuentaf    alias for $2;
  pfechai     alias for $3;
  pfechaf     alias for $4;
  psoloconmov alias for $5;
  pacumulaporfecha alias for $6;

  r movimientos%rowtype;
  s movimientos%rowtype;

  rc record;

  a record;

  lsaldoinicial numeric;
  ldebe  numeric;
  lhaber numeric;

  scuentaid char(24);
  bfound bool;
begin

  ldebe :=0;
  lhaber :=0;
  scuentaid := ' '; 

  if pacumulaporfecha='N' then
     bfound:=false;
     for r in

SELECT m.cuentaid,p.seriepoliza as serie,p.numero_poliza,
       referenciapoliza(p.polizaid) as referencia,
       p.fechapoliza as fecha,m.descripcion as concepto,
       0 AS saldoinicial,m.debe,m.haber,0 as saldofinal,
       p.tipo_poliza
  FROM polizas p, movipolizas m
 WHERE p.fechapoliza BETWEEN pfechai AND pfechaf AND
       m.polizaid = p.polizaid AND
       m.cuentaid>=pcuentai AND m.cuentaid<=pcuentaf
ORDER BY m.cuentaid,p.fechapoliza,p.seriepoliza,p.numero_poliza

     loop
       bfound:=true;      
       if scuentaid<>r.cuentaid then
         if scuentaid<>'  ' then
           s.cuentaid := scuentaid;
           s.serie := 'AA';
           s.numero_poliza := -1;

           select sum(m.debe)-sum(m.haber)
             into lsaldoinicial
             from polizas p, movipolizas m
            where p.fechapoliza < pfechai and
                  m.polizaid = p.polizaid and
                  m.cuentaid = scuentaid;

           lsaldoinicial := coalesce(lsaldoinicial,0);
           s.saldoinicial := lsaldoinicial;
           s.debe := ldebe;
           s.haber := lhaber;
           s.saldofinal := lsaldoinicial + ldebe - lhaber;
           s.fecha := '2000-01-01';

           return next s;
         end if;
         scuentaid := r.cuentaid;
         ldebe := 0;
         lhaber := 0;
       end if;


       ldebe := ldebe + r.debe;
       lhaber := lhaber + r.haber;
       return next r;

     end loop;


     if not bfound then
       scuentaid := pcuentai;
     end if;

     s.cuentaid := scuentaid;
     s.serie := 'AA';
     s.numero_poliza := -1;
     s.fecha := '2000-01-01';      
     select sum(m.debe)-sum(m.haber)
       into lsaldoinicial
       from polizas p, movipolizas m
      where p.fechapoliza < pfechai and
            m.polizaid = p.polizaid and
            m.cuentaid = scuentaid;

     lsaldoinicial := coalesce(lsaldoinicial,0);
     s.saldoinicial := lsaldoinicial;
     s.debe := ldebe;
     s.haber := lhaber;
     s.saldofinal := lsaldoinicial + ldebe - lhaber;

     return next s;


     if pcuentai<>pcuentaf then

     for rc in
       select c.cuentaid
         from catalogo_ctas c
        where c.cuentaid>=pcuentai AND c.cuentaid<=pcuentaf AND
              c.cuentaid not in (
                SELECT m.cuentaid
                  FROM polizas p, movipolizas m
                 WHERE p.fechapoliza BETWEEN pfechai AND pfechaf AND
                       m.polizaid = p.polizaid AND
                       m.cuentaid>=pcuentai AND m.cuentaid<=pcuentaf
                GROUP BY m.cuentaid
              ) AND
              c.tipo_cta='A'
     loop

       s.cuentaid := rc.cuentaid;
       s.serie := 'AA';
       s.numero_poliza := -1;
       s.fecha := '2000-01-01';

     select sum(m.debe)-sum(m.haber)
       into lsaldoinicial
       from polizas p, movipolizas m
      where p.fechapoliza < pfechai and
            m.polizaid = p.polizaid and
            m.cuentaid = rc.cuentaid;
  
       lsaldoinicial := coalesce(lsaldoinicial,0);
       s.saldoinicial := lsaldoinicial;
       s.debe := 0;
       s.haber := 0;
       s.saldofinal := lsaldoinicial;
       if lsaldoinicial>0 then
         return next s;
       end if;
     end loop;

     end if;



  else


     bfound:=false;
     for a in

SELECT m.cuentaid,p.fechapoliza as fecha,SUM(m.debe) as debe,SUM(m.haber) as haber
  FROM polizas p, movipolizas m
 WHERE p.fechapoliza BETWEEN pfechai AND pfechaf AND
       m.polizaid = p.polizaid AND
       m.cuentaid>=pcuentai AND m.cuentaid<=pcuentaf
GROUP BY m.cuentaid,p.fechapoliza
ORDER BY m.cuentaid,p.fechapoliza

     loop
       bfound:=true; 
       if scuentaid<>a.cuentaid then
         if scuentaid<>'  ' then
           s.cuentaid := scuentaid;
           s.serie := 'AA';
           s.numero_poliza := -1;

           select sum(m.debe)-sum(m.haber)
             into lsaldoinicial
             from polizas p, movipolizas m
            where p.fechapoliza < pfechai and
                  m.polizaid = p.polizaid and
                  m.cuentaid = scuentaid;

           lsaldoinicial := coalesce(lsaldoinicial,0);
           s.saldoinicial := lsaldoinicial;
           s.debe := ldebe;
           s.haber := lhaber;
           s.saldofinal := lsaldoinicial + ldebe - lhaber;
           s.fecha := '2000-01-01';

           return next s;
         end if;
         scuentaid := a.cuentaid;
         ldebe := 0;
         lhaber := 0;
       end if;

       r.cuentaid := a.cuentaid;
       r.serie := 'ZZ';
       r.fecha := a.fecha;
       r.debe := a.debe;
       r.haber := a.haber;
       ldebe := ldebe + a.debe;
       lhaber := lhaber + a.haber;
       return next r;

     end loop;

     if not bfound then
       s.cuentaid := pcuentai;
       scuentaid := pcuentai;
     else
       s.cuentaid := scuentaid;
     end if;

     s.serie := 'AA';
     s.numero_poliza := -1;
     s.fecha := '2000-01-01';      
     select sum(m.debe)-sum(m.haber)
       into lsaldoinicial
       from polizas p, movipolizas m
      where p.fechapoliza < pfechai and
            m.polizaid = p.polizaid and
            m.cuentaid = scuentaid;

     lsaldoinicial := coalesce(lsaldoinicial,0);
     s.saldoinicial := lsaldoinicial;
     s.debe := ldebe;
     s.haber := lhaber;
     s.saldofinal := lsaldoinicial + ldebe - lhaber;

     return next s;

  end if;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.movimientos(character, character, date, date, character, character) OWNER TO sistema;

--
-- Name: movimientosc(character, character, date, date, character, character); Type: FUNCTION; Schema: public; Owner: sistema
--

CREATE FUNCTION movimientosc(character, character, date, date, character, character) RETURNS SETOF movimientos
    AS $_$
declare
  pcuentai    alias for $1;
  pcuentaf    alias for $2;
  pfechai     alias for $3;
  pfechaf     alias for $4;
  psoloconmov alias for $5;
  pacumulaporfecha alias for $6;

  r movimientos%rowtype;

  f record;
  dblink1 text;
  dblink2 text;

begin

raise notice 'Conectando sucursal';

for f in
 select * from sucursales where vigente='S'
 loop

  raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

  dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
  dblink2:='set search_path to public,'||f.esquema||'; select * from movimientos('||''''||pcuentai||''''||',
                              '||''''||pcuentaf||''''||',
                              '||''''||pfechai||''''||',
                              '||''''||pfechaf||''''||',
                              '||''''||psoloconmov||''''||',
                              '||''''||pacumulaporfecha||''''||');';

  for r in
    select * from
    dblink(dblink1,dblink2) as
    t (cuentaid                char(24),
       serie                   char(7),
       numero_poliza           int4,
       referencia              int4,
       fecha                   date,
       concepto                varchar(255),
       saldoinicial            numeric,
       debe                    numeric,
       haber                   numeric,
       saldofinal              numeric,
       tipo_poliza             char(1))

    loop
      return next r;
    end loop;

 end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


ALTER FUNCTION public.movimientosc(character, character, date, date, character, character) OWNER TO sistema;

