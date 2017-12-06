drop table finalidad_destino_finafim cascade;
CREATE TABLE finalidad_destino_finafim (
	finalidad character varying (90),
	subfinalidad1 character varying (90),
	subfinalidad2 character varying (90),
	cve_destino_finafim integer,
	destino_finafim character varying (90)
	--PRIMARY KEY (ocupacion)
);
insert into finalidad_destino_finafim values('ADQUISICION DE MUEBLES PARA EL HOGAR','ELECTRODOMESTICOS VARIOS','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('ADQUISICION DE MUEBLES PARA EL HOGAR','ELECTRONICOS VARIOS','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('ADQUISICION DE MUEBLES PARA EL HOGAR','EQUIPOS Y ACCESORIOS DE COMPUTO','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('ADQUISICION DE MUEBLES PARA EL HOGAR','MUEBLES VARIOS','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('ADQUISICION DE MUEBLES PARA EL HOGAR','LINEA BLANCA VARIOS','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('COMPRA DE AUTOMOVIL Y/O CAMIONETA','NUEVO ','USO PARTICULAR',4,'COMPRAR LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE AUTOMOVIL Y/O CAMIONETA','NUEVO ','USO PUBLICO',4,'COMPRAR LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE AUTOMOVIL Y/O CAMIONETA','USADO','USO PARTICULAR',4,'COMPRAR LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE AUTOMOVIL Y/O CAMIONETA','USADO','USO PUBLICO',4,'COMPRAR LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE GANADO','PARA COMPRA Y VENTA','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('COMPRA DE GANADO','PARA INVERSION','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('COMPRA DE MAQUINARIA ','TRACTORES','',2,'COMPRAR MAQUINARIA, EQUIPO O HERRAMIENTAS');
insert into finalidad_destino_finafim values('COMPRA DE MAQUINARIA ','CAMIONES VOLTEO','',2,'COMPRAR MAQUINARIA, EQUIPO O HERRAMIENTAS');
insert into finalidad_destino_finafim values('COMPRA DE MAQUINARIA ','TRACTOCAMIONES','',2,'COMPRAR MAQUINARIA, EQUIPO O HERRAMIENTAS');
insert into finalidad_destino_finafim values('COMPRA DE MAQUINARIA ','CAMIONES ','',2,'COMPRAR MAQUINARIA, EQUIPO O HERRAMIENTAS');
insert into finalidad_destino_finafim values('COMPRA DE MAQUINARIA ','MAQUINARIA PESADA','',2,'COMPRAR MAQUINARIA, EQUIPO O HERRAMIENTAS');
insert into finalidad_destino_finafim values('COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','LLANTAS','',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','MOTOR','',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','REFACCIONES VARIAS','',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE REFACCIONES PARA AUTOMOVIL Y/O CAMIONETA','PARTES DE COLISION','',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE SEGURO COBERTURA AMPLIA','SERVICIO PUBLICO','',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE SEGURO COBERTURA AMPLIA','SERVICIO PRIVADO','',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('COMPRA DE TERRENO','COMUNAL','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('COMPRA DE TERRENO','EJIDAL','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('COMPRA DE TERRENO','PROPIEDAD PRIVADA','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','CASA NUEVA','CIMIENTOS',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','CASA NUEVA','PARA TERMINAR OBRA NEGRA',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','CASA NUEVA','PARA COLADO Y REPELLADO',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','CASA NUEVA','PARA TERMINADOS',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','CASA NUEVA','INICIO Y TERMINACION',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','CUARTO ADICIONAL',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','BARDA PERIMETRAL',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','CONSTRUCCION DE BAÑO',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','MANTENIMIENTO DE VIVIENDA',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','REMODELACION O AMPLIACION','MEJORAR CONDICIONES DE VIVIENDA',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','CIMIENTOS',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','PARA TERMINAR OBRA NEGRA',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','PARA COLADO Y REPELLADO',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','PARA TERMINADOS',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('GASTOS DE CONSTRUCCION','LOCALES COMERCIALES','INICIO Y TERMINACION',3,'AMPLIAR, ADECUAR O REPARAR EL LOCAL O VEHICULO');
insert into finalidad_destino_finafim values('GASTOS ESCOLARES','COMPRA DE UTILES','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS ESCOLARES','PAGO DE COLEGIATURAS','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS ESCOLARES','GASTOS DE CLAUSURA','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS ESCOLARES','PAGO DE INSCRIPCION','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS MEDICOS','DEL SOCIO','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS MEDICOS','DE FAMILIAR','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS MEDICOS','DE TERCEROS','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS NAVIDEÑO','COMPRA DE ARTICULOS NAVIDEÑOS','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS NAVIDEÑO','COMPRA DE CENA DE NAVIDAD','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS NAVIDEÑO','COMPRA DE REGALOS','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','INVERNADEROS NUEVOS','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','COMPOSTURA DE INVERNADEROS','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','SEMILLAS','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','FERTILIZANTES','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','HERBICIDAS, INCECTICIDAS','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','PREPARACION DE TERRENO','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','PAGO DE JORNALES','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PARA EL CAMPO','PAGO DE TRACTOR','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('GASTOS PERSONALES','GASTOS PERSONALES','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('INVERSION DE NEGOCIO','COMPRA DE MOBILIARIO','',2,'COMPRAR MAQUINARIA, EQUIPO O HERRAMIENTAS');
insert into finalidad_destino_finafim values('INVERSION DE NEGOCIO','COMPRA DE MAQUINARIA','',2,'COMPRAR MAQUINARIA, EQUIPO O HERRAMIENTAS');
insert into finalidad_destino_finafim values('INVERSION DE NEGOCIO','CAPITAL DE TRABAJO','',6,'OTRO FIN RELACIONADO');
insert into finalidad_destino_finafim values('INVERSION DE NEGOCIO','PAGO DE DEUDAS','',5,'PAGAR DEUDAS DEL NEGOCIO');
insert into finalidad_destino_finafim values('INVERSION DE NEGOCIO','NEGOCIO NUEVO','',1,'ADQUIRIR O COMPRAR MERCANCIA');
insert into finalidad_destino_finafim values('PAGO DE DEUDAS','A PARTICULARES','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('PAGO DE DEUDAS','EN LA COOPERATIVA','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('PAGO DE DEUDAS ','A OTRAS INSTITUCIONES','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('REESTRUCTURACION','CREDITOS CARTERA VIGENTE','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('REESTRUCTURACION','CREDITOS EN CARTERA MOROSA','',7,'FINES AJENOS AL NEGOCIO');
insert into finalidad_destino_finafim values('REESTRUCTURACION','CREDITOS EN CARTERA VENCIDA','',7,'FINES AJENOS AL NEGOCIO');