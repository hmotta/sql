cajayolo03=# select socioid from captaciontotal where fechadegeneracion='2015-12-31' and tipomovimientoid='PA' and socioid not in (select ct.socioid from captaciontotal ct, socio s,sujeto su, domicilio d,colonia c  where fechadegeneracion = '2015-12-31' and tipomovimientoid='PA' and ct.socioid=s.socioid and su.sujetoid=s.sujetoid and d.sujetoid=su.sujetoid and c.coloniaid=d.coloniaid);
 socioid
---------
    9389
    9391
    9422
(3 filas)

select setval('colonia_coloniaid_seq',max(coloniaid)) from colonia;
insert into colonia (ciudadmexid,nombrecolonia,cp,tipoasentamientoid,claveconapo) values(1172,'BENITO JUAREZ DEL PROGRESO',68600,2,'201770031');

cajayolo03=# select max(coloniaid) from colonia;
  max
-------
 82032

 update domicilio set coloniaid=82032 where domicilioid=34172;
 
 
 
 insert into colonia (ciudadmexid,nombrecolonia,cp,tipoasentamientoid,claveconapo) values(1172,'GRANDE',68607,2,'');
 
 cajayolo03=# select max(coloniaid) from colonia;
  max
-------
 82033
 
 update domicilio set coloniaid = 82033 where domicilioid=21811;
 
 
 
 insert into colonia (ciudadmexid,nombrecolonia,cp,tipoasentamientoid,claveconapo) values(1547,'VALERIO TRUJANO',68672,28,'');
 cajayolo03=# select max(coloniaid) from colonia;
  max
-------
 82034

update domicilio set coloniaid = 82034 where domicilioid=27358;
 