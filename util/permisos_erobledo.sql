--update permisosmodulos set permiso='S' where clavemodulo='CCABOV' and usuarioid='erobledo';
--update permisosmodulos set permiso='S' where clavemodulo='CCAEFEC' and usuarioid='erobledo';
--insert into modulos values ('ESRESULT','Estado de resultados');
--insert into permisosmodulos (clavemodulo,usuarioid,permiso) values ('ESRESULT','erobledo','S')
--update permisosmodulos set permiso='S' where clavemodulo='ESRESULT' and usuarioid='erobledo';
insert into modulos values ('0602','consulta de saldos siopera');
delete from permisosmodulos where clavemodulo='0602';
insert into permisosmodulos (clavemodulo,usuarioid,permiso) values ('0602','erobledo','S');

insert into modulos values ('0802','inversiones otorgadas y vencidas');
delete from permisosmodulos where clavemodulo='0802';
insert into permisosmodulos (clavemodulo,usuarioid,permiso) values ('0802','erobledo','S');