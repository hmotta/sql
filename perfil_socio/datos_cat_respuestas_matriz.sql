delete from cat_respuestas_matriz;
--1 Qué tipo de operaciones realizará en la Cooperativa:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (1, 'PRESTAMOS', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (1, 'AHORRO-INVERSION', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (1, 'REMESAS-DISPERSION DE FONDOS', 3, 3, 1);

--2 Qué tipo de servicios va a utilizar de la Cooperativa:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'VENTANILLA', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'CAJEROS AUTOMÁTICOS', 2, 2, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'TRANSFERENCIAS ELECTRÓNICAS NACIONALES', 3, 3, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'ORDENES DE PAGO NACIONALES', 4, 4, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'COMPRA-VENTA DE DIVISAS', 5, 5, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'CHEQUES DE VIAJERO', 6, 6, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'COMPRAS DE MONEDAS DE ORO, PLATA, PLATINO', 7, 7, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'BANCA POR INTERNET', 8, 8, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'BANCA MÓVIL', 9, 9, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'CAJA DE SEGURIDAD', 10, 10, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'TRANSFERENCIAS ELECTRÓNICAS AL EXTRANJERO', 11, 11, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'REMESAS SOBRE EL EXTRANJERO', 12, 12, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (2, 'ORDENES DE PAGO INTERNACIONALES', 13, 13, 1);

--3 Zona Geográfica. Lugar de Nacimiento:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (3, 'ZONA SUR', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (3, 'ZONA CENTRO', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (3, 'ZONA NORTE', 3, 3, 1);

--4 Nacionalidad:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (4, 'MEXICANA', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (4, 'EXTRANJERA', 2, 2, 1);

--5 Edad:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (5, '31 A 50 AÑOS', 31, 50, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (5, 'MÁS DE 50 AÑOS', 51, 150, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (5, 'DE 18 A 30 AÑOS', 18, 30, 1);

--6 Estado Civil:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (6, 'SOLTERO(A)', 0, 0, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (6, 'CASADO(A)', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (6, 'DIVORCIADO(A)', 2, 2, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (6, 'VIUDO(A)', 3, 3, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (6, 'UNIÓN LIBRE', 4, 4, 2);

--7 Tiempo laborando en su actual empleo:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (7, 'MENOS DE 2 AÑOS', 1, 1, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (7, 'DE 2 A 5 AÑOS', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (7, 'MAS DE 5 AÑOS', 3, 3, 3);

--8 Monto aproximado mensual de las Operaciones:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (8, 'MENOS DE $15000', 1, 14999, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (8, 'DE $15000 A $50000', 15000, 50000, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (8, 'MÁS DE $50000', 50001, 1000000, 1);

--9 Actividad principal:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (9, 'EMPLEADO ASALARIADO', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (9, 'PENSIONADO/JUBILADO', 2, 2, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (9, 'EMPRESARIO FORMAL', 3, 3, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (9, 'SERVIDOR PÚBLICO', 4, 4, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (9, 'EMPRESARIO INFORMAL', 5, 5, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (9, 'DESEMPLEADO/DEPENDIENTE ECONÓMICO', 6, 6, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (9, 'AMA DE CASA/ESTUDIANTE/BECADO', 7, 7, 1);

--10 Sector Económico:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (10, 'AGRICULTURA/EXPLOTACIÓN FORESTAL/GANADERÍA/MINERÍA/PESCA', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (10, 'CONSTRUCCIÓN/ INDUSTRIA MANUFACTURERA', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (10, 'COMERCIO/SERVICIO/TRANSPORTE', 3, 3, 1);

--11 Estado(s) de cobertura de la actividad económica:

--12 Cobertura geográfica de la Actividad Económica desarrollada:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (12, 'LOCAL/REGIONAL', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (12, 'ESTATAL/NACIONAL', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (12, 'INTERNACIONAL', 3, 3, 1);

--13 Ingreso Total Mensual:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (13, 'DE $1 A $25,000', 1, 25000, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (13, 'DE $25001 A $50000', 25001, 50000, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (13, 'MÁS DE $50000', 50000, 1000000, 1);

--14 Instrumento Monetario:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (14, 'EFECTIVO', 1, 1, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (14, 'CHEQUE', 2, 2, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (14, 'TRANSFERENCIA', 3, 3, 2);

--15 Frecuencia de Operaciones al mes:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (15, 'DE 1 A 4', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (15, 'DE 5 A 6', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (15, 'MAS DE 6', 3, 3, 1);

--16 Periodicidad de las operaciones:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (16, 'ESPORÁDICA', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (16, 'SEMESTRAL', 2, 2, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (16, 'BIMESTRAL', 3, 3, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (16, 'MENSUAL', 4, 4, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (16, 'QUINCENAL', 5, 5, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (16, 'SEMANAL', 6, 6, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (16, 'DIARIA', 7, 7, 1);

--17 Propiedad de los Recursos:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (17, 'PROPIOS', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (17, 'FAMILIAR', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (17, 'OTRAS PERSONAS', 3, 3, 1);

--18 Origen de los Recursos:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'SUELDO', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'ACTIVIDAD COMERCIAL', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'ACTIVIDAD PROFESIONAL', 3, 3, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'REMESAS DE FAMILIARES', 4, 4, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'PENSIÓN POR JUBILACIÓN', 5, 5, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'RENTAS', 6, 6, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'INGRESOS DE TERCEROS', 7, 7, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (18, 'VENTA DE UN ACTIVO', 8, 8, 1);

--19 Mecanismos de comprobación de ingresos:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'RECIBOS DE PAGO', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'DECLARACIÓN DE IMPUESTOS', 2, 2, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'RECIBOS DE HONORARIOS O DE NOMINA', 3, 3, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'RECIBO DE ARRENDAMIENTO', 4, 4, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'CONSTANCIA DE INGRESOS EMITIDA POR EL PATRÓN EN HOJA MEMBRETADAS', 5, 5, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'ESTADO DE CUENTA', 6, 6, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'CONTRATO DE COMPRA-VENTA NOTARIADOS', 7, 7, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'TESTAMENTO', 8, 8, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'ESTADOS FINANCIEROS FIRMADOS POR UN CONTADOR TITULADO', 9, 9, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'NOTAS DE REMISIÓN FOLIADAS Y/O MEMBRETADAS', 10, 10, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'FACTURAS', 11, 11, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'COMPROBANTE DE PAGO DE REMESA', 12, 12, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'FORMATO CING-0326 COMPROBACIÓN DE INGRESOS', 13, 13, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'CONTRATO DE COMPRA-VENTA DE PREDIO ENTE PARTICULARES', 14, 14, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'CONTRATO DE COMPRA-VENTA DE BIENES', 15, 15, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'CONTRATO DE PRESTACIÓN DE SERVICIOS', 16, 16, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'NO QUIERE PRESENTAR O NO CUENTA CON COMPROBANTES DE INGRESOS', 17, 17, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (19, 'NOTAS DE REMISIÓN SENCILLAS', 18, 18, 1);

--20 Posible destino de los recursos:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (20, 'GASTOS PERSONALES', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (20, 'GASTOS FAMILIARES', 2, 2, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (20, 'INVERSIÓN EN PROPIEDADES', 3, 3, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (20, 'INVERSIÓN CAPITAL DE TRABAJO', 4, 4, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (20, 'INVERSIÓN EN ACTIVOS DEL NEGOCIO', 5, 5, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (20, 'OTROS', 6, 6, 1);

--21 Tipo de Residencia:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (21, 'RENTADA', 0, 0, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (21, 'PROPIA', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (21, 'FAMILIAR', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (21, 'COMPARTIDA', 3, 3, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (21, 'OTRA', 4, 4, 1);

--22 Ingreso del Cónyuge:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (22, 'SIN INGRESOS', 0, 0, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (22, 'DE $1 A $25,000', 1, 25000, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (22, 'DE $25,001 A $50,000', 25001, 50000, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (22, 'MÁS DE $50,000', 50001, 1000000, 1);

--23 Antigüedad de la relación comercial con el socio:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (23, 'DE 0 A 6 MESES', 0, 179, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (23, 'DE 6 A 12 MESES', 180, 360, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (23, 'MAYOR DE 12 MESES', 361, 1000000, 1);

--24 A Tenido algún puesto público? PEPs:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (24, 'NO', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (24, 'SI/NACIONAL', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (24, 'SI/EXTRANJERO', 3, 3, 1);


--25 Algún familiar de usted, hasta segundo grado, ¿ocupa algún puesto público?:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (25, 'NO', 1, 1, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (25, 'SI/NACIONAL', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (25, 'SI/EXTRANJERO', 3, 3, 1);

--26 Tipo de Personalidad Jurídica:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (26, 'PERSONA FISICA', 1, 1, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (26, 'PERSONA FISICA CON ACTVIDAD EMPRESARIAL', 2, 2, 2);

--27 Tiempo de Residencia en el Estado:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (27, 'MENOR A 2 AÑOS', 1, 1, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (27, 'DE 2 A 5 AÑOS', 2, 2, 2);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (27, 'MAS DE 5 AÑOS', 3, 3, 3);

--28 Antigüedad domiciliaria:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (28, 'MENOS DE 2 AÑOS', 0, 1, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (28, 'MÁS DE 5 AÑOS', 6, 150, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (28, 'DE 2 A 5 AÑOS', 2, 5, 2);

--29 Se encuentra en la Lista de la OFAC:
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (29, 'SI NOMBRE(IDENTICO)', 1, 1, 1);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (29, 'NO', 2, 2, 3);
INSERT INTO cat_respuestas_matriz(preguntaid, descripcion_respuesta, valor_respuesta_minimo, valor_respuesta_maximo, nivelriesgoid) VALUES (29, 'NOMBRE PARECIDO O SIMILAR', 3, 3, 2);
