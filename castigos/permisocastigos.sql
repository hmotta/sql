

insert into modulos(clavemodulo,descripcionmodulos) values ('CASTIGO','CASTIGAR PRESTAMOS');
select fillpermisos();
update permisosmodulos  set permiso='N' where clavemodulo='CASTIGO';
update permisosmodulos  set permiso='S' where clavemodulo='CASTIGO' and usuarioid in ('supervisor','hmota');
