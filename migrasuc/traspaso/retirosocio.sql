
--Query para retirar un socio especifico,
--select * from retirosocios('Clavesocioint','Z','2007-05-27'); 


drop function retirosocios(char,char,date);

create or replace function retirosocios(char,char,date) returns int4 as
'
declare  
  r record;
  m record;
  pr record;
  iv record;
  psocioi alias for $1;
  pserie alias for $2;
  pfecha alias for $3;


  sociotraspaso int4;
  j int4;
  
  scuentacaja char(24);
  msaldomov numeric;
  pretiromov numeric;
  psaldocalculado numeric;
  pmovprestamo int4;
  pmovinversion int4;
  pfechamovi date;

begin

pfechamovi := pfecha;

select cuentacaja into scuentacaja from parametros where serie_user=pserie;

j:=0;

for r in
    select s.clavesocioint,su.nombre||'' ''||su.paterno||'' ''||su.materno as nombre,substr(d.calle||'' ''||d.numero_ext||'' ''||d.comunidad,1,60) as domicilio,s.socioid    from  socio s, sujeto su, domicilio d
    where
         s.clavesocioint=psocioi and  
         s.sujetoid = su.sujetoid and su.sujetoid=d.sujetoid
    order by s.clavesocioint
    loop

      raise notice '' Retirando Socio %'',r.clavesocioint;

      j:=j+1;

      update socio set estatussocio = 1 where clavesocioint=r.clavesocioint;
   
      -- Insertar retiros de movimientos

      raise notice ''Voy aqui '';

      for m in
      select tipomovimientoid from tipomovimiento where aplicasaldo=''S''
      and tipomovimientoid <> ''IN'' order by tipomovimientoid

      loop
          select saldomov into msaldomov from
          saldomov(r.socioid,m.tipomovimientoid,current_date);
          msaldomov := COALESCE (msaldomov,0);
          if msaldomov <> 0 then 
                select retiromov into pretiromov
                from retiromov(r.clavesocioint,current_date,msaldomov,m.tipomovimientoid,pserie,scuentacaja);
                raise notice '' Retirando movimiento % % % '',r.clavesocioint,m.tipomovimientoid,msaldomov;
          end if;
      end loop;

      -- Pago de prestamos

      for pr in
      select referenciaprestamo,fecha_otorga,prestamoid from prestamos where socioid=r.socioid and claveestadocredito = ''001''
      loop

          select saldo into psaldocalculado from saldocalculado(pr.prestamoid);
          psaldocalculado := COALESCE (psaldocalculado,0);

          select movprestamo into pmovprestamo from movprestamo(r.clavesocioint,pr.referenciaprestamo,pfechamovi,psaldocalculado,0,0,0,scuentacaja,pserie);
          raise notice ''Retirando prestamo % '',pr.referenciaprestamo;

      end loop;

  -- Retiro de la inversion

     for iv in
     select p.inversionid,p.tipoinversionid,p.fechainversion,p.fechavencimiento,p.socioid,
     p.depositoinversion,p.retiroinversion,p.interesinversion  from inversion p, socio s
     where s.clavesocioint=r.clavesocioint and s.socioid=p.socioid and p.depositoinversion > p.retiroinversion and p.inversionid in (select inversionid from movicaja where socioid=p.socioid )
 
     loop

          select movinversion into pmovinversion from movinversion(''2'',iv.inversionid,iv.tipoinversionid,pserie,pfechamovi,r.clavesocioint,iv.depositoinversion,scuentacaja,0,iv.fechainversion,iv.fechavencimiento);
  
          raise notice ''Inversionid Retiro % Fecha %'',iv.depositoinversion,iv.fechainversion;

      end loop;

    end loop;

    -- retirando al socio

    update socio set estatussocio = 2,  fechabaja=pfechamovi where clavesocioint=r.clavesocioint; 

return j;
end
'
language 'plpgsql' security definer;


drop function retirosocios(char,char);

create or replace function retirosocios(char,char) returns int4 as
'
declare  
  r record;
  m record;
  pr record;
  iv record;
  psocioi alias for $1;
  pserie alias for $2;

  sociotraspaso int4;
  j int4;
  
  scuentacaja char(24);
  msaldomov numeric;
  pretiromov numeric;
  psaldocalculado numeric;
  pmovprestamo int4;
  pmovinversion int4;
  pfechamovi date;

begin

pfechamovi := current_date;

select cuentacaja into scuentacaja from parametros where serie_user=pserie;

j:=0;

for r in
    select s.clavesocioint,su.nombre||'' ''||su.paterno||'' ''||su.materno as nombre,substr(d.calle||'' ''||d.numero_ext||'' ''||d.comunidad,1,60) as domicilio,s.socioid    from  socio s, sujeto su, domicilio d
    where
         s.clavesocioint=psocioi and 
         s.sujetoid = su.sujetoid and su.sujetoid=d.sujetoid
    order by s.clavesocioint
    loop

      raise notice '' Retirando Socio %'',r.clavesocioint;

      j:=j+1;

      update socio set estatussocio = 1 where clavesocioint=r.clavesocioint;
   
      -- Insertar retiros de movimientos

      raise notice ''Voy aqui '';

      for m in
      select tipomovimientoid from tipomovimiento where aplicasaldo=''S''
      and tipomovimientoid <> ''IN'' order by tipomovimientoid

      loop
          select saldomov into msaldomov from
          saldomov(r.socioid,m.tipomovimientoid,current_date);
          msaldomov := COALESCE (msaldomov,0);
          if msaldomov <> 0 then 
                select retiromov into pretiromov
                from retiromov(r.clavesocioint,current_date,msaldomov,m.tipomovimientoid,pserie,scuentacaja);
                raise notice '' Retirando movimiento % % % '',r.clavesocioint,m.tipomovimientoid,msaldomov;
          end if;
      end loop;

      -- Pago de prestamos

      for pr in
      select referenciaprestamo,fecha_otorga,prestamoid from prestamos where socioid=r.socioid and claveestadocredito = ''001''
      loop

          select saldo into psaldocalculado from saldocalculado(pr.prestamoid);
          psaldocalculado := COALESCE (psaldocalculado,0);

          select movprestamo into pmovprestamo from movprestamo(r.clavesocioint,pr.referenciaprestamo,pfechamovi,psaldocalculado,0,0,0,scuentacaja,pserie);
          raise notice ''Retirando prestamo % '',pr.referenciaprestamo;

      end loop;

  -- Retiro de la inversion

     for iv in
     select p.inversionid,p.tipoinversionid,p.fechainversion,p.fechavencimiento,p.socioid,
     p.depositoinversion,p.retiroinversion,p.interesinversion  from inversion p, socio s
     where s.clavesocioint=r.clavesocioint and s.socioid=p.socioid and p.depositoinversion > p.retiroinversion and p.inversionid in (select inversionid from movicaja where socioid=p.socioid )
 
     loop

          select movinversion into pmovinversion from movinversion(''2'',iv.inversionid,iv.tipoinversionid,pserie,pfechamovi,r.clavesocioint,iv.depositoinversion,scuentacaja,0,iv.fechainversion,iv.fechavencimiento);
  
          raise notice ''Inversionid Retiro % Fecha %'',iv.depositoinversion,iv.fechainversion;

      end loop;

    end loop;

    -- retirando al socio

    update socio set estatussocio = 2,  fechabaja=pfechamovi where clavesocioint=r.clavesocioint; 

return j;
end
'
language 'plpgsql' security definer;


