--Modificacion a la tabla CAPACIDAD DE PAGO
alter table analisiscapacidad add column pagoburo numeric;
alter table analisiscapacidad add column capacidadreal numeric

CREATE TABLE califdocotorgada (
    califdocotorgadaid serial NOT NULL,
    docid numeric,
    sujetoid numeric,
    es_socio numeric,
    es_aval numeric,
    solicitudprestamoid numeric,
    calificacionotorgada numeric,
    motivo numeric
);


CREATE TABLE calificacionsolicitud (
    calificacionsolicitud serial NOT NULL,
    solicitudprestamoid integer,
    calificacion numeric,
    usuarioid text,
    observaciones text,
    fecha date
);

CREATE TABLE catalogocalifdoc (
    docid serial NOT NULL,
    documento text,
    etapa numeric,
    calificacion numeric,
    documentoid numeric
);


CREATE TABLE validamesacontrol (
    validamesacontrolid serial NOT NULL,
	prestamoid integer,
	contrato integer,
    pagare integer,
	planpag integer,
    disposicion integer,
    garantias integer,
	calificacion numeric,
	observaciones text
    );
	
	
	COPY catalogocalifdoc (docid, documento, etapa, calificacion, documentoid) FROM stdin;
1	ACTA DE NACIMIENTO	1	3	4
2	COMP.DE DOM	1	3	0
3	CURP	1	2	5
4	IDENTIFICACION	1	3	0
16	REPORTE DE INVESTIGACION DE CREDITO	5	5	26
17	CROQUIS DE LOCALIZACION	5	3	27
18	FOTOGRAFIA DE DOMICILIO FACHADA	5	2	28
19	FOTOGRAFIA DE DOMICILIO INTERIOR	5	2	29
20	FOTOGRAFIA DE NEGOCIO FACHADA	5	2	30
21	FOTOGRAFIA DE NEGOCIO INTERIOR	5	2	31
22	BURO DE CREDITO	5	4	32
36	GARANTIA PREND. (CONTRATO DE COMPRA VENTA)	4	4	21
37	GARANTIA PREND. (ACTA DE POSESION)	4	3	22
38	GARANTIA PREND. (FACTURA DE BIEN)	4	3	23
39	GARANTIA PREND. (OTRO)	4	2	24
40	GARANTIA HIP. (AVALUO DE LA PROPIEDAD)	4	4	25
41	GARANTIA HIP. (LIBERTAD DE GRAVAMEN)	4	4	26
23	IDENTIFICACION	3	2	0
24	ACTA DE NACIMIENTO	3	2	5
25	CURP	3	2	6
26	COMP. DE DOM	3	2	0
27	AUTORIZACION DE CONSULTA DE BURO DE CREDITO 	3	1	20
28	CROQUIS DE LOCALIZACION	3	1	28
29	FOTOGRAFIA DE DOMICILIO FACHADA	3	1	29
30	FOTOGRAFIA DE DOMICILIO INTERIOR	3	1	30
31	FOTOGRAFIA DE NEGOCIO FACHADA	3	1	31
32	FOTOGRAFIA DE NEGOCIO INTERIOR	3	1	32
33	BURO DE CREDITO	3	2	33
34	REPORTE DE INVESTIGACION DE CREDITO	3	2	27
35	COMPROBANTE DE INGRESOS	3	2	19
8	AUTORIZACION DE CONSULTA DE BURO DE CREDITO	2	2	19
7	COMPROBANTE DE INGRESOS	2	3	18
6	SOLICITUD DE CREDITO	2	6	17
5	CONTRATO DE DEPOSITO DE DINERO	2	3	12
\.