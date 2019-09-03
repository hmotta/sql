alter table recorresucursales add column nombresuc character (20);
update recorresucursales set nombresuc='YOLOMECATL'  where sucursalid=1;
update recorresucursales set nombresuc='NOCHIXTLAN'  where sucursalid=2;
update recorresucursales set nombresuc='OAXACA'  where sucursalid=3;
update recorresucursales set nombresuc='HUAJUAPAN'  where sucursalid=5;
update recorresucursales set nombresuc='NICANANDUTA'  where sucursalid=6;
update recorresucursales set nombresuc='COIXTLAHUACA'  where sucursalid=7;
update recorresucursales set nombresuc='TEPELMEME'  where sucursalid=8;
update recorresucursales set nombresuc='TEZOATLAN'  where sucursalid=10;
INSERT INTO recorresucursales values (12,'localhost','cajayolo12','sucursal12','sistema','1sc4pslu2','S','','012-','sucursal12.cyolomecatl.com','','AJALPAN');

