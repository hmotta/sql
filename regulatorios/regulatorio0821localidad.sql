
--alter table captaciontotal ALTER COLUMN localidad TYPE character(10);

--update captaciontotal set localidad = (select coalesce(co.localidadcnbv,'1274002') from socio s, sujeto su, domicilio d, colonia co where s.socioid=captaciontotal.socioid and  s.sujetoid=su.sujetoid and su.sujetoid=d.sujetoid and d.coloniaid=co.coloniaid) where localidad is null;

drop TYPE tresumencaptacion cascade;

CREATE TYPE tresumencaptacion AS (
        fechadegeneracion date,
	sucursal character(4),
	desctipoinversion character(30),
	clavesocioint character(18),
	nombresocio character varying(80),
	inversionid integer,
	fechainversion date,
	fechavencimiento date,
	tasainteresnormalinversion numeric,
	plazo integer,
	deposito numeric,
	diasvencimiento integer,
	formapagorendimiento integer,
	intdevmensual numeric,
	intdevacumulado numeric,
	saldototal numeric,
	saldopromedio numeric,
	fechapagoinversion date,
	tipomovimientoid character(2),
        cuentaid         char(24),
        localidad        char(10),
        socioid          int4,
        grupo            char(25),
        diaspromedio     integer,
        isr              numeric,
        nocontrato       integer        
);



CREATE or replace FUNCTION resumencaptacion(date, character) RETURNS SETOF tresumencaptacion
    AS $_$
declare

  r tresumencaptacion%rowtype;
  pfecha alias for $1;
  psucursal alias for $2;

  dfechai date;
  idiasanuales int;
  pdiafecha numeric;

begin

    select diasanualesinversion into idiasanuales
      from empresa where empresaid=1;

    -- Inicio de mes
    dfechai := pfecha - cast(extract(day from pfecha) as integer);
    raise notice 'Fecha inicio de mes %',dfechai;
---
---

    for r in

 select pfecha,psucursal,substring(t.desctipoinversion,1,30),s.clavesocioint,
        su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
        mc.inversionid, i.fechainversion, i.fechavencimiento,
        i.tasainteresnormalinversion, t.plazo, SUM((case when mp.cuentaid=t.cuentapasivo
                 then mp.haber-mp.debe
                 else 0 end)) AS deposito,
        (case when i.fechavencimiento-pfecha>0
              then i.fechavencimiento-pfecha
              else 0 end),
        t.plazo as formapagorendimiento,
        0 as intdevmensual,
(( pfecha -
       COALESCE(MAX(case when mp.cuentaid=t.cuentaintinver
               then (case when p.fechapoliza<=pfecha
                          then p.fechapoliza
                          else i.fechainversion end)
               else i.fechainversion end),i.fechainversion))*i.tasainteresnormalinversion/100/idiasanuales*SUM((case when mp.cuentaid=t.cuentapasivo
                 then mp.haber-mp.debe
                 else 0 end))) as intdevacumulado,
        0 as saldototal,
        0 as saldopromedio,COALESCE(MAX(case when mp.cuentaid=t.cuentaintinver
               then (case when p.fechapoliza<=pfecha
                          then p.fechapoliza
                          else i.fechainversion end) else i.fechainversion end),i.fechainversion)
        ,mc.tipomovimientoid,tm.cuentadeposito,co.localidadcnbv,s.socioid,(select grupo from solicitudingreso where socioid=s.socioid) as grupo,0 as diaspromedio, 0 as isr,0 as nocontrato
   from movicaja mc, socio s, polizas p, movipolizas mp, inversion i, 
        tipoinversion t,sujeto su, domicilio d, colonia co, tipomovimiento tm
  where mc.inversionid is not null and
        s.socioid = mc.socioid and        
        p.polizaid = mc.polizaid and        
        p.fechapoliza<pfecha+1 and
        i.inversionid = mc.inversionid and
        i.fechainversion<pfecha+1 and

        t.tipoinversionid = i.tipoinversionid and
        mp.polizaid =mc.polizaid and
        su.sujetoid = s.sujetoid and
        d.sujetoid = su.sujetoid and
        d.coloniaid = co.coloniaid and 
        tm.tipomovimientoid = mc.tipomovimientoid

group by psucursal,substring(t.desctipoinversion,1,30),s.clavesocioint,su.nombre||' '||su.paterno||' '||su.materno, mc.inversionid, i.fechainversion,i.fechavencimiento,i.tasainteresnormalinversion, t.plazo,i.fechapagoinversion,mc.tipomovimientoid,tm.cuentadeposito,d.ciudadmexid,s.socioid
having   SUM((case when mp.cuentaid=t.cuentapasivo
                 then mp.haber-mp.debe
                 else 0 end))>0 order by clavesocioint
    loop

      
      --
      -- Calcular devengamiento mensual
      --
      -- dfechai = primero del mes

      if r.fechapagoinversion<=dfechai then

        if r.fechavencimiento>=pfecha then
          r.intdevmensual:=(pfecha-dfechai)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;
        else
          if r.fechavencimiento>dfechai-1 then
            r.intdevmensual:=(r.fechavencimiento-dfechai)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;
          else
            r.intdevmensual:=0;
          end if;         
        end if;

      else

        if r.fechavencimiento>=pfecha then
          r.intdevmensual:=(pfecha-r.fechapagoinversion)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;

        else
          r.intdevmensual:=(r.fechavencimiento-r.fechapagoinversion)*r.tasainteresnormalinversion/idiasanuales/100*r.deposito;

        end if;

      end if;

      if r.intdevmensual<0 then
        raise exception 'El interes mensual no puede ser negativo %',r.clavesocioint;
      end if;
      
      r.intdevmensual := round(r.intdevmensual,2);

      -- Calcular devengamiento acumulado
      -- desde el inicio de la inversion
      
      r.intdevacumulado:= round(r.intdevacumulado,2);

      pdiafecha:=cast(extract(day from pfecha) as numeric);

      r.saldototal:=r.deposito+r.intdevacumulado;

     
      r.saldopromedio:=r.deposito+round((r.intdevmensual/pdiafecha)*((pdiafecha+1)/2),2);

     
      return next r;

    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

    
CREATE or replace FUNCTION captaciontotal(date) RETURNS SETOF tresumencaptacion
    AS $_$
declare
  r tresumencaptacion%rowtype;
  pfecha alias for $1;
  psucursal char(4);

  dfechai date;
  idiasanuales int;

begin

    select diasanualesinversion,sucid into idiasanuales,psucursal
      from empresa where empresaid=1;

    -- Inicio de mes
    dfechai := pfecha - cast(extract(day from pfecha)-1 as integer);
    
    raise notice 'Fecha inicio de mes %',dfechai;

    for r in
      select * from resumencaptacion(pfecha,psucursal)
    loop
      return next r;
    end loop;

    for r in
      select pfecha,psucursal,substring(t.desctipomovimiento,1,30),s.clavesocioint,
             su.nombre||' '||su.paterno||' '||su.materno as nombresocio,
             0 as inversionid, pfecha as fechainversion,
             pfecha+1 as fechavencimiento, t.tasainteres, 1 as plazo,
             sum(mp.debe)-sum(mp.haber) as deposito, 1 as diasvencimiento,
             1 as formapagorendimiento,0 as  intdevmensual,
        0 as intdevacumulado,
        0 as saldototal,
        0 as saldopromedio,
        pfecha as fechapagoinversion,mc.tipomovimientoid,tm.cuentadeposito,co.localidadcnbv,s.socioid,(select grupo from solicitudingreso where socioid=s.socioid) as grupo,0 as diaspromedio, 0 as isr,0 as nocontrato
        from movicaja mc, movipolizas mp, polizas p, socio s,
             tipomovimiento t, sujeto su, domicilio d, colonia co, tipomovimiento tm
       where mc.tipomovimientoid in (select tipomovimientoid from tipomovimiento where tipomovimientoid<>'IN' and aplicasaldo='S') and
             p.polizaid = mc.polizaid and             
             p.fechapoliza<=pfecha and
             mp.movipolizaid=mc.movipolizaid and     
             s.socioid = mc.socioid and
             t.tipomovimientoid = mc.tipomovimientoid and
             su.sujetoid = s.sujetoid and 
             d.sujetoid = su.sujetoid and
             d.coloniaid = co.coloniaid and
             tm.tipomovimientoid = mc.tipomovimientoid
      group by substring(t.desctipomovimiento,1,30),s.clavesocioint,su.nombre,
               su.paterno,su.materno,t.tasainteres,mc.tipomovimientoid,t.aplicasaldo,tm.cuentadeposito,d.ciudadmexid,s.socioid
      having sum(mp.debe)-sum(mp.haber)<>0 
    loop
      if r.tipomovimientoid in (select tipomovimientoid from tipomovimiento where tipomovimientoid<>'IN' and aplicasaldo='S') then
      
         select saldopromedio,interesdevengado,isr into r.saldopromedio,r.intdevmensual,r.isr from  intdevengadomensual(r.clavesocioint,pfecha,r.tipomovimientoid);
         
      end if;
      return next r;
    end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


    
CREATE or replace FUNCTION captaciontotalc(date) RETURNS SETOF tresumencaptacion
    AS $_$
declare

  pfecha alias for $1;
  r tresumencaptacion%rowtype;
  f record;
  dblink1 text;
  dblink2 text;
  psucid char(4);


begin

select sucid into psucid from empresa where empresaid=1;

for f in
 select * from sucursales where vigente='S' and sucid <> psucid
 loop

  raise notice 'Conectando sucursal % % %',f.basededatos,f.esquema,psucid;

  dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
  dblink2:='set search_path to public,'||f.esquema||';select fechadegeneracion,	sucursal,desctipoinversion,clavesocioint,nombresocio,inversionid,fechainversion, fechavencimiento, tasainteresnormalinversion,	plazo,	deposito,diasvencimiento,formapagorendimiento,intdevmensual,intdevacumulado,saldototal,	saldopromedio,	fechapagoinversion,tipomovimientoid, cuentaid,localidad,socioid,grupo,diaspromedio,isr,nocontrato from captaciontotal where fechadegeneracion='||''''||pfecha||''''||' ;';

  for r in
    select * from
    dblink(dblink1,dblink2) as t(fechadegeneracion date,
    sucursal           char(4),
    desctipoinversion  char(30),
    clavesocioint      char(18),
    nombresocio        varchar(80),
    inversionid        int4,
    fechainversion     date,
    fechavencimiento   date,
    tasainteresnormalinversion numeric,
    plazo              int4,
    deposito           numeric,
    diasvencimiento    int4,
    formapagorendimiento int4,
    intdevmensual      numeric,
    intdevacumulado    numeric,
    saldototal         numeric,
    saldopromedio      numeric,
    fechapagoinversion date,
    tipomovimientoid char(2),
    cuentaid         char(24),
    localidad        char(10),
    socioid          int4,
    grupo            char(25),
    diaspromedio     integer,
    isr              numeric,
    nocontrato       integer)
    
  loop
    return next r;
  end loop;

end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
