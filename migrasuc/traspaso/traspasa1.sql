-- Ejemplo si deseamos pasar un socio de la sucursal1 a la 6
-- En la sucursal 6 tecleamos : select * from traspasasocio('001-00002-02','localhost','cajin01','sucursal1','Z');

drop function traspasasocio(char(15),varchar(40),varchar(20),varchar(20),char(2));

create or replace function traspasasocio(char(15),varchar(40),varchar(20),varchar(20),char(2))
returns int4 as
$_$
declare
  pclavesocioint alias for $1;
  phost alias for $2;
  pdb alias for $3;
  psucursal alias for $4;
  pserie alias for $5;

  lsujetoid int4;
  ldomicilioid int4;
  lsocioid int4;
  lssocioid int4;
  lclavesocioint char(15);
  lsolicitudingresoid int4;
  spersonaautorizadaid int4;
  spersonaautorizadaid1 int4;

  sconyugeid int4;
  sconyugeid1 int4;
  snosolicitud int4;
  psocioid int4;
  spaterno varchar(20);
  smaterno varchar(20);
  snombre varchar(40);
  srfc char(16);
  sresujetoid int4;
  sresujetoid1 int4;
  lrelacionid int4;
  lresujetoid int4;
  lavalid int4;
  savsujetoid int4;
  savsujetoid1 int4;
  pdepositomov numeric;

  lprestamoid int4;

  r prestamos%rowtype;
  --  m movicaja%rowtype;
  m record;
  re record;
  msaldomov numeric;
  iv record;
  va record;
  ar record;

  scuentacaja char(24);

  pnumero_poliza int4;
  preferencia int4;
  lpolizaid int4;
  lmovipolizaid int4;
  lmovicaja int4;
  lestatussocio char(2);

  setdomicilio int4;
  setsujeto int4;
  setsocio int4;
  setrelacion int4;
  setsolingreso int4;

  sreferenciaprestamo CHAR(18);
  psaldocalculado numeric;
  pfechaultimopago date;
  psaldaprestamo int4;
  pmovinversion int4;

  -- fecha de movimientos
  pfechamovi date;
  pretirosocio integer;
  pgrupo char(25);
  pocupacion char(40);
  ptiposocioid char(2);
  
begin

  pfechamovi := current_date;
 
--select setval('domicilio_domicilioid_seq',max(domicilioid)) into setdomicilio from domicilio;
--select setval('socio_socioid_seq',max(socioid)) into setsocio from socio;
--select setval('sujeto_sujetoid_seq',max(sujetoid)) into setsujeto from sujeto;
--select setval('relacion_relacionid_seq',max(relacionid)) into setrelacion from relacion;
--select setval ('solicitudingreso_solicitudingresoid_seq',max(solicitudingresoid)) into setsolingreso from solicitudingreso;

  -- Sacar la cuenta de caja
  select cuentacaja into scuentacaja from parametros where serie_user=pserie;

  select paterno,materno,nombre,rfc,sujetoid,socioid,estatussocio,grupo,ocupacion,tiposocioid into spaterno,smaterno,snombre,srfc,sresujetoid1,psocioid,lestatussocio,pgrupo,pocupacion,ptiposocioid  from
     dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2','set search_path to public,'||''''||psucursal||''''||';
                   select paterno,materno,nombre,rfc,su.sujetoid,s.socioid,s.estatussocio,si.grupo,si.ocupacion,s.tiposocioid from sujeto su, socio s, solicitudingreso si 
                    where s.clavesocioint='||''''||pclavesocioint||''''||' and
                          su.sujetoid=s.sujetoid and su.sujetoid=si.sujetoid;')
            as t(paterno varchar(20), materno varchar(20), nombre varchar(40),rfc char(16), sujetoid int4, socioid int4, estatussocio char(2), grupo char(25), ocupacion char(40), tiposocioid char(2));

  if lestatussocio = '2' then
   
        raise exception ' Socio retirado Nombre: % % %',spaterno,smaterno,snombre;

  end if;

  raise notice ' Nombre: % % %',spaterno,smaterno,snombre;

  select su.sujetoid,d.domicilioid into lsujetoid,ldomicilioid from sujeto su, domicilio d  where su.paterno=spaterno and su.materno=smaterno and su.nombre=snombre and rfc=srfc and su.sujetoid=d.sujetoid;

  lsujetoid := COALESCE ( lsujetoid, 0 );  

  if lsujetoid= 0  then

           -- Migrando Sujeto
            raise notice 'Migrando sujeto';

           insert into sujeto (paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial)
           SELECT paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,su.rfc,su.curp,su.edad,
                          su.fecha_nacimiento,su.razonsocial
                     from socio s,sujeto su
                    where s.clavesocioint='||''''||pclavesocioint||''''||' and
                          su.sujetoid=s.sujetoid;')
            as t(paterno varchar(20),materno varchar(20),nombre varchar(40),
                 rfc char(16),curp char(20),edad numeric,fecha_nacimiento date,
                 razonsocial varchar(60));

            lsujetoid:=currval('sujeto_sujetoid_seq');
            raise notice 'SujetoID= %',lsujetoid;

            -- Migrando Domicilio
            raise notice 'Migrando Domicilio';

            insert into domicilio (ciudadmexid,sujetoid,calle,numero_ext,numero_int,colonia,
                         codpostal,comunidad,teldomicilio,coloniaid)
            SELECT existeciudad(ciudadmexid),lsujetoid,calle,numer_ext,numero_int,colonia,codpostal,
            comunidad,teldomicilio,coloniaid
            FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select d.ciudadmexid,d.sujetoid,d.calle,d.numero_ext,d.numero_int,
                          d.colonia,d.codpostal,d.comunidad,d.teldomicilio,d.coloniaid
                     from socio s,domicilio d
                    where s.clavesocioint='||''''||pclavesocioint||''''||' and
                          d.sujetoid=s.sujetoid;')
            as t(ciudadmexid int4,sujetoid int4,calle varchar(40),numer_ext varchar(15),
                 numero_int varchar(15),colonia varchar(30),codpostal int4,
                 comunidad varchar(50),teldomicilio varchar(20),coloniaid int4);   

            ldomicilioid:=currval('domicilio_domicilioid_seq');
            raise notice 'DomicilioID= %',ldomicilioid;

  end if;

  --se busca el sujeto en la base local para no duplicarlos si ya existe
  select s.socioid into lssocioid from sujeto su, socio s where su.paterno=spaterno and su.materno=smaterno and su.nombre=snombre and rfc=srfc and su.sujetoid=s.sujetoid;

  lssocioid := COALESCE ( lssocioid, 0 );       
   
  if lssocioid= 0 then 

  -- Migrando Socio
    raise notice 'Migrando socio';

    insert into socio (sujetoid,tiposocioid,clavesocioint,fechaalta,fechabaja,estatussocio)
     SELECT lsujetoid,tiposocioid,existeclave(pclavesocioint,ptiposocioid),fechaalta,fechabaja,estatussocio
     FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select sujetoid,tiposocioid,clavesocioint,fechaalta,fechabaja,
                          estatussocio
                     from socio s
                    where clavesocioint='||''''||pclavesocioint||''''||';')
            as t(sujetoid int4,tiposocioid char(2),clavesocioint char(15),fechaalta date,fechabaja date,estatussocio int4);

    lsocioid:=currval('socio_socioid_seq');
    raise notice 'SocioID= %',lsocioid;

    select clavesocioint into lclavesocioint from socio where socioid=lsocioid;


    -- Migrando Solicitudingreso

    raise notice 'Migrando solicitudingreso';

    -- Persona autorizada 
    select paterno,materno,nombre,personaautorizadaid into spaterno,smaterno,snombre,spersonaautorizadaid1 from
       dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,so.personaautorizadaid
                     from sujeto su, solicitudingreso so, socio s
                    where so.sujetoid=su.sujetoid and so.socioid=s.socioid and s.clavesocioint='||''''||pclavesocioint||''''||';')
                    
            as t(paterno varchar(20), materno varchar(20), nombre varchar(40), personaautorizadaid int4);

  if spersonaautorizadaid1 is not null then 

     select sujetoid into spersonaautorizadaid from sujeto where paterno=spaterno and materno=smaterno and nombre=snombre;

     spersonaautorizadaid := COALESCE ( spersonaautorizadaid, 0 );

     if spersonaautorizadaid = 0 then
   
           insert into sujeto (paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial)
           SELECT paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,su.rfc,su.curp,su.edad,
                          su.fecha_nacimiento,su.razonsocial
                     from sujeto su
                    where su.sujetoid='||spersonaautorizadaid1||';')
            as t(paterno varchar(20),materno varchar(20),nombre varchar(40),
                 rfc char(16),curp char(20),edad numeric,fecha_nacimiento date,
                 razonsocial varchar(60));

           spersonaautorizadaid:=currval('sujeto_sujetoid_seq');
 
           insert into domicilio (ciudadmexid,sujetoid,calle,numero_ext,numero_int,colonia,
                         codpostal,comunidad,teldomicilio,coloniaid)
           SELECT existeciudad(ciudadmexid),spersonaautorizadaid,calle,numer_ext,numero_int,colonia,codpostal,
           comunidad,teldomicilio,coloniaid
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select d.ciudadmexid,d.sujetoid,d.calle,d.numero_ext,d.numero_int,
                          d.colonia,d.codpostal,d.comunidad,d.teldomicilio,d.coloniaid
                     from domicilio d
                    where d.sujetoid='||spersonaautorizadaid1||';')
            as t(ciudadmexid int4,sujetoid int4,calle varchar(40),numer_ext varchar(15),
                 numero_int varchar(15),colonia varchar(30),codpostal int4,
                 comunidad varchar(50),teldomicilio varchar(20),coloniaid int4);
     End if;
  else
    spersonaautorizadaid:=spersonaautorizadaid1;
  End if;


  -- Conyuge 

  select paterno,materno,nombre,conyugeid into spaterno,smaterno,snombre,sconyugeid1 from
     dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,so.conyugeid
                     from sujeto su, solicitudingreso so, socio s
                    where so.sujetoid=su.sujetoid and so.socioid=s.socioid and s.clavesocioint='||''''||pclavesocioint||''''||';')
                    
            as t(paterno varchar(20), materno varchar(20), nombre varchar(40), conyugeid int4);

  if sconyugeid1 is not null then 

     select sujetoid into sconyugeid from sujeto where paterno=spaterno and materno=smaterno and nombre=snombre;

     sconyugeid := COALESCE ( sconyugeid, 0 );

     if sconyugeid = 0 then
   
           insert into sujeto (paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial)
           SELECT paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,su.rfc,su.curp,su.edad,
                          su.fecha_nacimiento,su.razonsocial
                     from sujeto su
                    where su.sujetoid='||sconyugeid1||';')
            as t(paterno varchar(20),materno varchar(20),nombre varchar(40),
                 rfc char(16),curp char(20),edad numeric,fecha_nacimiento date,
                 razonsocial varchar(60));

           sconyugeid:=currval('sujeto_sujetoid_seq');
 
           insert into domicilio (ciudadmexid,sujetoid,calle,numero_ext,numero_int,colonia,
                         codpostal,comunidad,teldomicilio,coloniaid)
           SELECT existeciudad(ciudadmexid),sconyugeid,calle,numer_ext,numero_int,colonia,codpostal,
           comunidad,teldomicilio,coloniaid
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select d.ciudadmexid,d.sujetoid,d.calle,d.numero_ext,d.numero_int,
                          d.colonia,d.codpostal,d.comunidad,d.teldomicilio,d.coloniaid
                     from domicilio d
                    where d.sujetoid='||sconyugeid1||';')
            as t(ciudadmexid int4,sujetoid int4,calle varchar(40),numer_ext varchar(15),
                 numero_int varchar(15),colonia varchar(30),codpostal int4,
                 comunidad varchar(50),teldomicilio varchar(20),coloniaid int4);
     End if;
  else
    sconyugeid:=sconyugeid1;
  End if;
	--raise notice 'grupo=%',pgrupo;
    if not exists (select grupo from grupo where grupo=pgrupo) then
      insert into grupo (grupo) values (pgrupo);
      
    end if;

    if not exists (select ocupacion from ocupacion  where ocupacion =pocupacion ) then
      insert into ocupacion (ocupacion) values (pocupacion);
    
    end if;

  select max(nosolicitud)+1 into snosolicitud from solicitudingreso;
  snosolicitud := COALESCE ( snosolicitud, 1 );

  

  insert into solicitudingreso ( nosolicitud,  fechasolicitud, fechaingreso,socioid,sujetoid,ciudadmexid, sexo, nivelestudiosid, profesion, ocupacion,  tipocasaid, estadocivilid,conyugeid,  regimenmatrimonial, tiempovivirendomicilio, motivoingresoid, medioseenteroid,  perteneceaotracaja,  otracaja,  claveescuela,  nombreescuela , personaautorizadaid, usuarioid,  lastusuarioid, lastupdate,  tiposocioid, observaciones,  doccompleta ,  docfaltante,  personajuridicaid, grupo, cta)
   SELECT snosolicitud,  fechasolicitud, fechaingreso,lsocioid,lsujetoid,existeciudad(ciudadmexid), sexo, nivelestudiosid, profesion, ocupacion,  tipocasaid, estadocivilid,sconyugeid,  regimenmatrimonial, tiempovivirendomicilio, motivoingresoid, medioseenteroid,  perteneceaotracaja,  otracaja,  claveescuela,  nombreescuela , spersonaautorizadaid, usuarioid,  lastusuarioid, lastupdate,  tiposocioid, observaciones,  doccompleta ,  docfaltante,  personajuridicaid,grupo,cta 
     FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select nosolicitud,  fechasolicitud, fechaingreso,so.socioid,so.sujetoid,ciudadmexid, sexo, nivelestudiosid, profesion, ocupacion,  tipocasaid, estadocivilid,conyugeid,  regimenmatrimonial, tiempovivirendomicilio, motivoingresoid, medioseenteroid,  perteneceaotracaja,  otracaja,  claveescuela,  nombreescuela , personaautorizadaid,'||''''||'supervisor'||''''||','||''''||'supervisor'||''''||' , lastupdate,  so.tiposocioid, observaciones,  doccompleta ,  docfaltante,  personajuridicaid, grupo,cta
                     from solicitudingreso so, socio s
                    where so.socioid=s.socioid and s.clavesocioint='||''''||pclavesocioint||''''||';')
            as t ( 
    nosolicitud integer ,
    fechasolicitud date ,
    fechaingreso date,
    socioid integer,
    sujetoid integer ,
    ciudadmexid integer ,
    sexo integer ,
    nivelestudiosid integer ,
    profesion character varying(40),
    ocupacion character varying(40),
    tipocasaid integer ,
    estadocivilid integer ,
    conyugeid integer,
    regimenmatrimonial integer,
    tiempovivirendomicilio character varying(15),
    motivoingresoid integer ,
    medioseenteroid integer ,
    perteneceaotracaja integer ,
    otracaja character varying(40),
    claveescuela character varying(20),
    nombreescuela character varying(50),
    personaautorizadaid integer,
    usuarioid character(20) ,
    lastusuarioid character(20) ,
    lastupdate date ,
    tiposocioid character(2) ,
    observaciones text,
    doccompleta integer,
    docfaltante text,
    personajuridicaid integer,
    grupo character(25),
    cta character(25)
);

  lsolicitudingresoid:=currval('solicitudingreso_solicitudingresoid_seq');
  raise notice 'SolicitudingresoID= %',lsolicitudingresoid;


    -- Pasar Relaciones

    raise notice 'Migrando Relaciones';

    for re in
       select * from
 dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select  rel.solicitudingresoid,rel.sujetoid,rel.socioid,rel.parentesco,rel.porcentaje,rel.esbenficiario,rel.esreferenciapersonal,rel.esrepresentante
                     from relacion rel, solicitudingreso so, socio s
                    where rel.solicitudingresoid=so.solicitudingresoid and so.socioid=s.socioid and s.clavesocioint='||''''||pclavesocioint||''''||';')
            as t(solicitudingresoid int4, sujetoid int4, socioid int4, 
parentesco varchar(20), porcentaje numeric,esbenficiario integer,esreferenciapersonal integer,esrepresentante integer)

     loop
   
       select paterno,materno,nombre,sujetoid into spaterno,smaterno,snombre,sresujetoid1  from
       dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select paterno,materno,nombre,sujetoid
                     from sujeto 
                    where sujetoid='||re.sujetoid||';')
            as t(paterno varchar(20), materno varchar(20), nombre varchar(40), sujetoid int4);

        raise notice ' Nombre: % % % %',spaterno,smaterno,snombre,sresujetoid1;

        select sujetoid into sresujetoid from sujeto where paterno=spaterno and materno=smaterno and nombre=snombre;

        sresujetoid := COALESCE ( sresujetoid, 0 );

        if sresujetoid= 0 then

           insert into sujeto (paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial)
           SELECT paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,su.rfc,su.curp,su.edad,
                          su.fecha_nacimiento,su.razonsocial
                     from sujeto su
                    where su.sujetoid='||sresujetoid1||';')
            as t(paterno varchar(20),materno varchar(20),nombre varchar(40),
                 rfc char(16),curp char(20),edad numeric,fecha_nacimiento date,
                 razonsocial varchar(60));

           sresujetoid:=currval('sujeto_sujetoid_seq');

           raise notice 'Relacion sujetoid= %',sresujetoid;

           insert into domicilio (ciudadmexid,sujetoid,calle,numero_ext,numero_int,colonia,
                         codpostal,comunidad,teldomicilio,coloniaid)
           SELECT existeciudad(ciudadmexid),sresujetoid,calle,numer_ext,numero_int,colonia,codpostal,
           comunidad,teldomicilio,coloniaid
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select d.ciudadmexid,d.sujetoid,d.calle,d.numero_ext,d.numero_int,
                          d.colonia,d.codpostal,d.comunidad,d.teldomicilio,d.coloniaid
                     from domicilio d
                    where d.sujetoid='||sresujetoid1||';')
            as t(ciudadmexid int4,sujetoid int4,calle varchar(40),numer_ext varchar(15),
                 numero_int varchar(15),colonia varchar(30),codpostal int4,
                 comunidad varchar(50),teldomicilio varchar(20),coloniaid int4);

         End if;

         if not exists (select relacionid from relacion  where solicitudingresoid=lsolicitudingresoid and sujetoid=sresujetoid) then
   
            insert into relacion (solicitudingresoid,sujetoid,parentesco,porcentaje,esbenficiario,esreferenciapersonal,esrepresentante) values (lsolicitudingresoid,sresujetoid,re.parentesco,re.porcentaje,re.esbenficiario,re.esreferenciapersonal,re.esrepresentante);

           lrelacionid:=currval('relacion_relacionid_seq');
           raise notice 'Relacionid= %',lrelacionid;
           
         End if; 
    end loop;

    raise notice 'Termine Relaciones';

  else

    --en caso de que el socio exista migrar sus movimientos.

    select clavesocioint into lclavesocioint from socio where socioid=lssocioid;

  end if;

-- Saldo en Movimientos


for m in

 select * from
 dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select tipomovimientoid from tipomovimiento where aplicasaldo='||''''||'S'||''''||' and tipomovimientoid <> '||''''||'IN'||''''||';') as t(tipomovimientoid char(2))

loop

        select saldomov into msaldomov from
        dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2','set search_path to public,'||''''||psucursal||''''||';
        select * from saldomov('||psocioid||','||''''||m.tipomovimientoid||''''||','||''''||current_date||''''||');') as t(saldomov numeric);

        msaldomov := COALESCE ( msaldomov, 0);
        if msaldomov <> 0 then 
                select depositomov into pdepositomov from depositomov(lclavesocioint,pfechamovi,msaldomov,m.tipomovimientoid,pserie,scuentacaja);
                raise notice ' Traspasando movimiento % % % ',lclavesocioint,m.tipomovimientoid,msaldomov;
        end if;

end loop;

-- Pasando Prestamos

for r in
      select * from
 dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select prestamoid,tipoprestamoid,p.socioid,clavegarantia,claveestadocredito,'||''''||'supervisor'||''''||',clavefinalidad,calculonormalid,calculomoratorioid,referenciaprestamo,montoprestamo,saldoprestamo,numero_de_amor,fecha_otorga,fecha_vencimiento,tasanormal,tasa_moratoria,dias_de_cobro,meses_de_cobro,dia_mes_cobro,fecha_1er_pago,monto_garantia,fechaultimopago
                     from prestamos p, socio s
                    where s.clavesocioint='||''''||pclavesocioint||''''||' and s.socioid=p.socioid;')
            as t(  PrestamoID int4, 
  TipoPrestamoID CHAR(3), 
  SocioID INTEGER, 
  ClaveGarantia CHAR(3), 
  ClaveEstadoCredito CHAR(3), 
  UsuarioID CHAR(20), 
  ClaveFinalidad CHAR(3), 
  CalculoNormalID INTEGER, 
  CalculoMoratorioID INTEGER, 
  referenciaprestamo CHAR(18), 
  montoprestamo NUMERIC, 
  saldoprestamo NUMERIC, 
  numero_de_amor INTEGER, 
  fecha_otorga DATE, 
  fecha_vencimiento DATE, 
  tasanormal NUMERIC, 
  tasa_moratoria NUMERIC, 
  dias_de_cobro INTEGER, 
  meses_de_cobro INTEGER, 
  dia_mes_cobro INTEGER, 
  fecha_1er_pago DATE, 
  monto_garantia NUMERIC, 
  fechaultimopago DATE)
  
  loop

    select nextprestamo into sreferenciaprestamo from nextprestamo();

    if r.claveestadocredito = '001' then 
      select * into lprestamoid
      from spiprestamos(sreferenciaprestamo,
                        r.montoprestamo,
                        r.saldoprestamo,
                        r.numero_de_amor,
                        r.fecha_otorga,
                        r.fecha_vencimiento,
                        r.tipoprestamoid,
                        r.tasanormal,
                        r.tasa_moratoria,
                        lsocioid,
                        r.dias_de_cobro,
                        r.meses_de_cobro,
                        r.dia_mes_cobro,
                        r.fecha_1er_pago,
                        r.clavegarantia,
                        r.monto_garantia,
                        r.claveestadocredito,
                        r.usuarioid,
                        r.clavefinalidad,
                        r.calculonormalid,
                        r.calculomoratorioid,
                        0, NULL);


    -- Registro de los pagos del prestamo.

    select saldo,fechaultimopago into  psaldocalculado,pfechaultimopago from
        dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2','set search_path to public,'||''''||psucursal||''''||';
        select saldo,fechaultimopago from saldocalculado('||r.prestamoid||');') as t(saldo numeric, fechaultimopago date);

     pfechaultimopago := COALESCE ( pfechaultimopago, r.fecha_otorga);

     raise notice 'PrestamoID= % Saldo %  Ultimo pago %',lprestamoid,psaldocalculado,pfechaultimopago;

     SELECT saldaprestamo into psaldaprestamo from saldaprestamo(sreferenciaprestamo,r.montoprestamo-psaldocalculado,pfechaultimopago,r.montoprestamo,pserie,scuentacaja);

	for ar in 
		select * from
 dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select numamortizacion,fechadepago,importeamortizacion,interesnormal,saldo_absoluto,interespagado,abonopagado,ultimoabono,iva,totalpago,cobranza,cobranzapagado from amortizaciones where prestamoid='||''''||r.prestamoid||''''||' order by numamortizacion;')
				   as t(  numamortizacion integer,
						 fechadepago date ,
						 importeamortizacion numeric,
						 interesnormal numeric,
						 saldo_absoluto numeric,
						 interespagado numeric,
						 abonopagado numeric,
						 ultimoabono date,
						 iva numeric,
						 totalpago numeric,
						 cobranza numeric,
						 cobranzapagado numeric
						)
	loop
		update amortizaciones set fechadepago=ar.fechadepago,importeamortizacion=ar.importeamortizacion,interesnormal=ar.interesnormal,saldo_absoluto=ar.saldo_absoluto,interespagado=ar.interespagado,abonopagado=ar.abonopagado,ultimoabono=ar.ultimoabono,iva=ar.iva,totalpago=ar.totalpago,cobranza=ar.cobranza,cobranzapagado=ar.cobranzapagado where prestamoid=lprestamoid and numamortizacion=ar.numamortizacion;
	end loop;
   end if;

  end loop;



-- Pasar Avales

 raise notice 'Migrando Avales';

 for va in
      select * from
 dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2','set search_path to public,'||''''||psucursal||''''||';
           select  av.prestamoid,av.socioid,av.sujetoid,av.porcentajeavala,av.relacionconsocio,av.noaval,av.solicitudprestamoid from prestamos pr, avales av, socio s
           where av.prestamoid=pr.prestamoid and pr.socioid=s.socioid and s.clavesocioint='||''''||pclavesocioint||''''||';')
            as t(prestamoid int4, socioid int4, sujetoid int4, 
porcentajeaval numeric,relacionconsocio varchar(20),noaval integer,solicitudprestamoid int4)

  loop
   
     select paterno,materno,nombre,sujetoid into spaterno,smaterno,snombre,savsujetoid1  from
     dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select paterno,materno,nombre,sujetoid
                     from sujeto 
                    where sujetoid='||va.sujetoid||';')
            as t(paterno varchar(20), materno varchar(20), nombre varchar(40), sujetoid int4);

        raise notice ' Nombre: % % % %',spaterno,smaterno,snombre,savsujetoid1;

        select sujetoid into savsujetoid from sujeto where paterno=spaterno and materno=smaterno and nombre=snombre;

        savsujetoid := COALESCE(savsujetoid,0);

        if savsujetoid=0 then

           insert into sujeto (paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial)
           SELECT paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,su.rfc,su.curp,su.edad,
                          su.fecha_nacimiento,su.razonsocial
                     from sujeto su
                    where su.sujetoid='||savsujetoid1||';')
            as t(paterno varchar(20),materno varchar(20),nombre varchar(40),
                 rfc char(16),curp char(20),edad numeric,fecha_nacimiento date,
                 razonsocial varchar(60));

           savsujetoid:=currval('sujeto_sujetoid_seq');

           --raise notice 'Aval sujetoid= %',savsujetoid;

           insert into domicilio (ciudadmexid,sujetoid,calle,numero_ext,numero_int,colonia,
                         codpostal,comunidad,teldomicilio,coloniaid)
           SELECT existeciudad(ciudadmexid),savsujetoid,calle,numer_ext,numero_int,colonia,codpostal,
           comunidad,teldomicilio,coloniaid
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select d.ciudadmexid,d.sujetoid,d.calle,d.numero_ext,d.numero_int,
                          d.colonia,d.codpostal,d.comunidad,d.teldomicilio,d.coloniaid
                     from domicilio d
                    where d.sujetoid='||savsujetoid1||';')
            as t(ciudadmexid int4,sujetoid int4,calle varchar(40),numer_ext varchar(15),
                 numero_int varchar(15),colonia varchar(30),codpostal int4,
                 comunidad varchar(50),teldomicilio varchar(20),coloniaid int4);

         End if;

         if not exists (select avalid from avales  where prestamoid=lprestamoid and sujetoid=savsujetoid) then
   
            insert into avales (prestamoid,sujetoid,porcentajeavala,relacionconsocio,noaval) values (lprestamoid,savsujetoid,va.porcentajeaval,va.relacionconsocio,va.noaval);

            lavalid:=currval('avales_avalid_seq');
            raise notice 'Avalid= %',lavalid;
            
         end if;
         
  end loop;

raise notice 'Termine Avales';

  -- Registro de Inversiones

  for iv in
      select * from dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select inversionid,tipoinversionid,fechainversion,fechavencimiento,p.socioid,depositoinversion,retiroinversion,interesinversion
                     from inversion p, socio s
                    where s.clavesocioint='||''''||pclavesocioint||''''||' and s.socioid=p.socioid and p.depositoinversion > p.retiroinversion and p.inversionid in (select inversionid from movicaja where socioid=p.socioid);')
            as t(inversionid integer,  
  tipoinversionid CHAR(3),
  fechainversion date, 
  fechavencimiento date, 
  socioid integer, 
  depositoinversion numeric, 
  retiroinversion numeric, 
  interesinversion numeric)

  loop

    select movinversion into pmovinversion from movinversion('1',iv.inversionid,iv.tipoinversionid,pserie,pfechamovi,lclavesocioint,iv.depositoinversion,scuentacaja,iv.interesinversion,iv.fechainversion,iv.fechavencimiento);
  
  raise notice 'Inversionid deposito % Fecha % ',iv.depositoinversion,iv.fechainversion;

  end loop;

  -- Retirando al socio de la sucursal origen

  select retirosocios into pretirosocio from
        dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2','set search_path to public,'||''''||psucursal||''''||';
        select * from retirosocios('||''''||pclavesocioint||''''||','||''''||pserie||''''||');') as t(retirosocios integer);
 
  raise notice 'Retirando al socio: % ',pclavesocioint;

return 1;
end
$_$
language 'plpgsql' security definer;

-- select * from traspasasocio('X03-20823-02','192.168.1.1','finagam3','sucursal3','Z');

drop function existeciudad(int4);
create or replace function existeciudad(int4) returns int4 as
$_$
declare
  pciudadmexid alias for $1;
  pciudadmexidn int4;
begin

  select ciudadmexid into pciudadmexidn from ciudadesmex where ciudadmexid=pciudadmexid;

  -- Asignando Oaxaca de juarez por default

  pciudadmexidn:= coalesce(pciudadmexidn,29);

return pciudadmexidn;
end
$_$
language 'plpgsql' security definer;

drop function existeclave(char,char);
create or replace function existeclave(char,char) returns char as
$_$
declare
  pclavesocioint alias for $1;
  ptiposocioid alias for $2;
  pclavesociointn char(18);
  pclavesociointn2 char(18);
  psucid char(4);

begin

  select sucid into psucid from empresa where empresaid=1;
  
  pclavesociointn:=psucid||substring(pclavesocioint,5,8)||'C';
  --select clavesocioint into pclavesociointn from socio where clavesocioint=pclavesociointn2;

  --if pclavesociointn is null then
  --    pclavesociointn:= pclavesociointn2;
  --else
   --   if ptiposocioid='01' then
    --     select nextsociom into pclavesociointn from nextsociom();
     -- else
      --   select nextsocio into pclavesociointn from nextsocio();
      --end if;   
      --pclavesociointn:= psucid||substring(pclavesocioint,5,8)||'T';
  --end if;
  
return pclavesociointn;
end
$_$
language 'plpgsql' security definer;

