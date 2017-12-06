
CREATE or replace FUNCTION traspasausuario(character, character varying, character varying, character varying) RETURNS integer
    AS $_$
declare
  pusuarioid alias for $1;
  phost alias for $2;
  pdb alias for $3;
  psucursal alias for $4;

  lusuarioid char(20);
  lsujetoid int4;
  ldomicilioid int4;

  spaterno varchar(20);
  smaterno varchar(20);
  snombre varchar(40);
  srfc char(16);
  sresujetoid int4;
  sresujetoid1 int4;
  lrelacionid int4;
  lresujetoid int4;

  setdomicilio int4;
  setsujeto int4;
  setsocio int4;
  setrelacion int4;
  setsolingreso int4;

begin

  select usuarioid into lusuarioid from usuarios where usuarioid=pusuarioid;
  lusuarioid := COALESCE ( lusuarioid,' ' );

  if lusuarioid = ' ' then

  select paterno,materno,nombre,rfc,sujetoid into spaterno,smaterno,snombre,srfc,sresujetoid1 from
     dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
        'set search_path to public,'||''''||psucursal||''''||';
                   select paterno,materno,nombre,rfc,su.sujetoid
                     from sujeto su, usuarios s 
                    where s.usuarioid='||''''||pusuarioid||''''||' and
                          su.sujetoid=s.sujetoid;')
            as t(paterno varchar(20), materno varchar(20), nombre varchar(40),rfc char(16), sujetoid int4);

  raise notice ' Nombre: % % %',spaterno,smaterno,snombre;

  select su.sujetoid,d.domicilioid into lsujetoid,ldomicilioid from sujeto su, domicilio d where paterno=spaterno and materno=smaterno and nombre=snombre and rfc=srfc and su.sujetoid=d.sujetoid;

  lsujetoid := COALESCE ( lsujetoid, 0 );

  if lsujetoid= 0 then

           -- Migrando Sujeto
            raise notice 'Migrando sujeto';

           insert into sujeto (paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial)
           SELECT paterno,materno,nombre,rfc,curp,edad,fecha_nacimiento,razonsocial
           FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select su.paterno,su.materno,su.nombre,su.rfc,su.curp,su.edad,
                          su.fecha_nacimiento,su.razonsocial
                     from usuarios s,sujeto su
                    where s.usuarioid='||''''||pusuarioid||''''||' and
                          su.sujetoid=s.sujetoid;')
            as t(paterno varchar(20),materno varchar(20),nombre varchar(40),
                 rfc char(16),curp char(20),edad numeric,fecha_nacimiento date,
                 razonsocial varchar(60));

            lsujetoid:=currval('sujeto_sujetoid_seq');
            raise notice 'SujetoID= %',lsujetoid;

            -- Migrando Domicilio
            raise notice 'Migrando Domicilio';

            insert into domicilio (ciudadmexid,sujetoid,calle,numero_ext,numero_int,colonia,
                         codpostal,comunidad,teldomicilio)
            SELECT existeciudad(ciudadmexid),lsujetoid,calle,numer_ext,numero_int,colonia,codpostal,
            comunidad,teldomicilio
            FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select d.ciudadmexid,d.sujetoid,d.calle,d.numero_ext,d.numero_int,
                          d.colonia,d.codpostal,d.comunidad,d.teldomicilio
                     from usuarios s,domicilio d
                    where s.usuarioid='||''''||pusuarioid||''''||' and
                          d.sujetoid=s.sujetoid;')
            as t(ciudadmexid int4,sujetoid int4,calle varchar(30),numer_ext varchar(15),
                 numero_int varchar(15),colonia varchar(30),codpostal int4,
                 comunidad varchar(50),teldomicilio varchar(20));   

            ldomicilioid:=currval('domicilio_domicilioid_seq');
            raise notice 'DomicilioID= %',ldomicilioid;

  end if;

-- Migrando Usuario
  raise notice 'Migrando Usuario';

  insert into usuarios(usuarioid,tipousuarioid,usu_usuarioid,contrasenia,email,dicola,obsusuario,sujetoid)
  SELECT usuarioid,tipousuarioid,usu_usuarioid,contrasenia,email,dicola,obsusuario,lsujetoid
  FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select usuarioid,tipousuarioid,usu_usuarioid,contrasenia,email,dicola,obsusuario,sujetoid
                   from usuarios s
                   where usuarioid='||''''||pusuarioid||''''||';')
            as t(usuarioid char(20),tipousuarioid char(3),usu_usuarioid char(20),contrasenia varchar(13), email varchar(30), dicola varchar(10), obsusuario varchar(254),sujetoid int4);

  raise notice 'Usuarioid = %',pusuarioid;


-- Migrando Parametros

  raise notice 'Migrando Parametros';

 insert into parametros(usuarioid,serie_user,cuentacaja,impresoracaja,impresorareporte,reporteslaser)
  SELECT usuarioid,serie_user,cuentacaja,impresoracaja,impresorareporte,reporteslaser
  FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select usuarioid,serie_user,cuentacaja,impresoracaja,impresorareporte,reporteslaser
                   from parametros s
                   where usuarioid='||''''||pusuarioid||''''||';')
            as t(usuarioid char(20),serie_user char(2),cuentacaja char(24),impresoracaja char(50), impresorareporte char(50), reporteslaser int4);

  raise notice ' Parametro Usuarioid = %',pusuarioid;

  -- Migrando Permisos modulos

  raise notice 'Migrando Permisos';

 insert into permisosmodulos(clavemodulo,usuarioid,permiso)
  SELECT clavemodulo,usuarioid,permiso
  FROM dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
                 'set search_path to public,'||''''||psucursal||''''||';
                   select clavemodulo,usuarioid,permiso
                   from permisosmodulos s
                   where usuarioid='||''''||pusuarioid||''''||';')
            as t(clavemodulo char(10),usuarioid char(20),permiso char(1));

  raise notice ' Permisos Usuarioid = %',pusuarioid;

  end if;

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;




CREATE or replace FUNCTION importausuarios(character varying, character varying, character varying) RETURNS integer
    AS $_$
declare
 
  phost alias for $1;
  pdb alias for $2;
  psucursal alias for $3;
  r record;
  ptraspasausuario int4;

begin

for r in 
     select usuarioid from
     dblink('host='||''''||phost||''''||' dbname='||''''||pdb||''''||' user=sistema password=1sc4pslu2',
     'set search_path to public,'||''''||psucursal||''''||';
           select usuarioid from usuarios order by usuarioid;')
           as t(usuarioid char(20))
  loop
     raise notice ' Usuario a traspasar %',r.usuarioid;

     select traspasausuario into ptraspasausuario from traspasausuario(r.usuarioid,phost,pdb,psucursal);

  end loop;
 
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

