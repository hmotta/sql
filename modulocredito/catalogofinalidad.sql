drop table catalogofinalidad cascade;
CREATE TABLE catalogofinalidad
(
	--catalogofinalidadid serial not null,
	finalidadid integer not null,
	--subfinalidadid1 integer not null,
	--subfinalidadid2 integer not null,
	finalidad character varying (50) NOT NULL,
	subfinalidad1 character varying (31),
	subfinalidad2 character varying (31),
	unique(finalidad,subfinalidad1,subfinalidad2),
	primary key (finalidadid)
	--primary key (catalogofinalidadid)
);

insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (1,'ADQUISICION DE MUEBLES PARA EL HOGAR','ELECTRODOMESTICOS VARIOS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (2,'ADQUISICION DE MUEBLES PARA EL HOGAR','ELECTRONICOS VARIOS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (3,'ADQUISICION DE MUEBLES PARA EL HOGAR','EQUIPOS Y ACCESORIOS DE COMPUTO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (4,'ADQUISICION DE MUEBLES PARA EL HOGAR','LINEA BLANCA VARIOS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (5,'ADQUISICION DE MUEBLES PARA EL HOGAR','MUEBLES VARIOS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (6,'COMPRA DE AUTOMOVIL Y/O CAMIONETA','NUEVO ','USO PARTICULAR');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (7,'COMPRA DE AUTOMOVIL Y/O CAMIONETA','NUEVO ','USO PUBLICO');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (8,'COMPRA DE AUTOMOVIL Y/O CAMIONETA','USADO','USO PARTICULAR');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (9,'COMPRA DE AUTOMOVIL Y/O CAMIONETA','USADO','USO PUBLICO');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (10,'COMPRA DE GANADO','PARA COMPRA Y VENTA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (11,'COMPRA DE GANADO','PARA INVERSION','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (12,'COMPRA DE MAQUINARIA ','CAMIONES ','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (13,'COMPRA DE MAQUINARIA ','CAMIONES VOLTEO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (14,'COMPRA DE MAQUINARIA ','MAQUINARIA PESADA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (15,'COMPRA DE MAQUINARIA ','TRACTOCAMIONES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (16,'COMPRA DE MAQUINARIA ','TRACTORES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (17,'COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','LLANTAS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (18,'COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','MOTOR','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (19,'COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','PARTES DE COLISION','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (20,'COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','REFACCIONES VARIAS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (21,'COMPRA DE SEGURO COBERTURA AMPLIA','SERVICIO PRIVADO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (22,'COMPRA DE SEGURO COBERTURA AMPLIA','SERVICIO PUBLICO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (23,'COMPRA DE TERRENO','COMUNAL','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (24,'COMPRA DE TERRENO','EJIDAL','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (25,'COMPRA DE TERRENO','PROPIEDAD PRIVADA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (26,'GASTOS DE CONSTRUCCION','CASA NUEVA','CIMIENTOS');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (27,'GASTOS DE CONSTRUCCION','CASA NUEVA','INICIO Y TERMINACION');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (28,'GASTOS DE CONSTRUCCION','CASA NUEVA','PARA COLADO Y REPELLADO');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (29,'GASTOS DE CONSTRUCCION','CASA NUEVA','PARA TERMINADOS');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (30,'GASTOS DE CONSTRUCCION','CASA NUEVA','PARA TERMINAR OBRA NEGRA');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (31,'GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','CIMIENTOS');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (32,'GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','INICIO Y TERMINACION');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (33,'GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','PARA COLADO Y REPELLADO');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (34,'GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','PARA TERMINADOS');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (35,'GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','PARA TERMINAR OBRA NEGRA');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (36,'GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','BARDA PERIMETRAL');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (37,'GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','CONSTRUCCION DE BAÑO');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (38,'GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','CUARTO ADICIONAL');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (39,'GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','MANTENIMIENTO DE VIVIENDA');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (40,'GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','MEJORAR CONDICIONES DE VIVIENDA');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (41,'GASTOS ESCOLARES','COMPRA DE UTILES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (42,'GASTOS ESCOLARES','GASTOS DE CLAUSURA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (43,'GASTOS ESCOLARES','PAGO DE COLEGIATURAS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (44,'GASTOS ESCOLARES','PAGO DE INSCRIPCION','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (45,'GASTOS MEDICOS','DE FAMILIAR','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (46,'GASTOS MEDICOS','DE TERCEROS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (47,'GASTOS MEDICOS','DEL SOCIO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (48,'GASTOS NAVIDEÑO','COMPRA DE ARTICULOS NAVIDEÑOS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (49,'GASTOS NAVIDEÑO','COMPRA DE CENA DE NAVIDAD','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (50,'GASTOS NAVIDEÑO','COMPRA DE REGALOS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (51,'GASTOS PARA EL CAMPO','COMPOSTURA DE INVERNADEROS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (52,'GASTOS PARA EL CAMPO','FERTILIZANTES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (53,'GASTOS PARA EL CAMPO','HERBICIDAS, INCECTICIDAS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (54,'GASTOS PARA EL CAMPO','INVERNADEROS NUEVOS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (55,'GASTOS PARA EL CAMPO','PAGO DE JORNALES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (56,'GASTOS PARA EL CAMPO','PAGO DE TRACTOR','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (57,'GASTOS PARA EL CAMPO','PREPARACION DE TERRENO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (58,'GASTOS PARA EL CAMPO','SEMILLAS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (59,'GASTOS PERSONALES','GASTOS PERSONALES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (60,'INVERSION DE NEGOCIO','CAPITAL DE TRABAJO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (61,'INVERSION DE NEGOCIO','COMPRA DE MAQUINARIA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (62,'INVERSION DE NEGOCIO','COMPRA DE MOBILIARIO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (63,'INVERSION DE NEGOCIO','NEGOCIO NUEVO','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (64,'INVERSION DE NEGOCIO','PAGO DE DEUDAS','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (65,'PAGO DE DEUDAS','A PARTICULARES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (66,'PAGO DE DEUDAS','EN LA COOPERATIVA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (67,'PAGO DE DEUDAS','A OTRAS INSTITUCIONES','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (68,'REESTRUCTURACION','CREDITOS CARTERA VIGENTE','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (69,'REESTRUCTURACION','CREDITOS EN CARTERA MOROSA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (70,'REESTRUCTURACION','CREDITOS EN CARTERA VENCIDA','');
insert into catalogofinalidad (finalidadid,finalidad,subfinalidad1,subfinalidad2) values (71,'CREDITO PATMIR','CREDITO PATMIR','');

