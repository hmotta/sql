
alter table parametros add fechacalculo date;

insert into modulos(clavemodulo,descripcionmodulos) values ('FECHACAL','CAMBIAR FECHA DE CALCULO');
select fillpermisos();
update permisosmodulos  set permiso='S' where clavemodulo='FECHACAL';
update permisosmodulos  set permiso='S' where clavemodulo='FECHACAL' and usuarioid in ('supervisor');

