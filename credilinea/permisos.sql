insert into modulos(clavemodulo,descripcionmodulos) values ('CANCLIN','Cancela Linea');
insert into modulos(clavemodulo,descripcionmodulos) values ('ARQDIARIO','Arqueo Diario');

select fillpermisos();
update permisosmodulos set permiso='N' where  clavemodulo='CANCLIN';
update permisosmodulos set permiso='N' where  clavemodulo='ARQDIARIO';