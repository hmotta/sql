--
-- PostgreSQL database dump
--

-- Dumped from database version 8.2.7
-- Dumped by pg_dump version 9.2.19
-- Started on 2017-10-17 22:17:30

SET statement_timeout = 0;
SET client_encoding = 'LATIN1';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 6 (class 2615 OID 77277522)
-- Name: sucursal3; Type: SCHEMA; Schema: -; Owner: sistema
--

CREATE SCHEMA sucursal3;


ALTER SCHEMA sucursal3 OWNER TO sistema;

--
-- TOC entry 3755 (class 2612 OID 77277525)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 2707 (class 1247 OID 77277527)
-- Name: cartera; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE cartera AS (
	descripcionfinalidad character varying(30),
	desctipoprestamo character(30),
	total numeric,
	menor30 numeric,
	dias1_7 numeric,
	dias8_30 numeric,
	dias31_60 numeric,
	dias61_90 numeric,
	dias91_120 numeric,
	dias121_180 numeric,
	mayor180 numeric
);


ALTER TYPE public.cartera OWNER TO sistema;

--
-- TOC entry 2756 (class 1247 OID 77277529)
-- Name: carterac; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE carterac AS (
	clavefinalidad character(3),
	tipoprestamoid character(3),
	diasvencidos integer,
	saldoprestamo numeric
);


ALTER TYPE public.carterac OWNER TO sistema;

--
-- TOC entry 2757 (class 1247 OID 77277531)
-- Name: datoaval; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE datoaval AS (
	nombre character varying,
	domicilio character varying,
	nombreciudadmex character varying(20),
	nombreestadomex character varying(20),
	interes numeric,
	moratorio numeric,
	capital numeric,
	diasint integer,
	montoprestamo numeric,
	fecha_otorga date,
	referenciaprestamo character(18)
);


ALTER TYPE public.datoaval OWNER TO sistema;

--
-- TOC entry 2758 (class 1247 OID 77277533)
-- Name: dblink_pkey_results; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE dblink_pkey_results AS (
	"position" integer,
	colname text
);


ALTER TYPE public.dblink_pkey_results OWNER TO postgres;

--
-- TOC entry 2759 (class 1247 OID 77277535)
-- Name: inversiones; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE inversiones AS (
	clavesocioint character(15),
	nombresocio character varying(80),
	inversionid integer,
	fechainversion date,
	fechavencimiento date,
	tasainteresnormalinversion numeric,
	plazo integer,
	deposito numeric,
	diasvencimiento integer,
	fechapagoanterior date,
	interes numeric,
	tipoinversionid character(3),
	socioid integer,
	grupo character(25)
);


ALTER TYPE public.inversiones OWNER TO sistema;

--
-- TOC entry 2760 (class 1247 OID 77277537)
-- Name: inversionesxtipo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE inversionesxtipo AS (
	tipoinversionid character(3),
	cuentapasivo character(24),
	clavesocioint character(15),
	nombresocio character varying(80),
	inversionid integer,
	fechainversion date,
	fechavencimiento date,
	tasainteresnormalinversion numeric,
	plazo integer,
	deposito numeric,
	diasvencimiento integer,
	fechapagoanterior date,
	interes numeric
);


ALTER TYPE public.inversionesxtipo OWNER TO sistema;

--
-- TOC entry 2761 (class 1247 OID 77277539)
-- Name: inversiongarantia; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE inversiongarantia AS (
	garantiainversionid integer,
	referenciaprestamo character varying(18),
	inversionid integer,
	desctipoinversion character varying(30),
	depositoinversion numeric,
	montocomprometido numeric,
	montodisponible numeric
);


ALTER TYPE public.inversiongarantia OWNER TO sistema;

--
-- TOC entry 2762 (class 1247 OID 77277541)
-- Name: inversiontipo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE inversiontipo AS (
	tipomovimientoid character(2),
	serie character(2),
	referencia integer,
	numero_poliza integer,
	fecha date,
	saldoinicial numeric,
	depositos numeric,
	retiros numeric,
	interes numeric,
	saldofinal numeric,
	inversionid numeric,
	isr numeric,
	desctipoinversion character varying
);


ALTER TYPE public.inversiontipo OWNER TO sistema;

--
-- TOC entry 2763 (class 1247 OID 77277543)
-- Name: movimientos; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE movimientos AS (
	cuentaid character(24),
	serie character(7),
	numero_poliza integer,
	referencia integer,
	fecha date,
	concepto character varying(255),
	saldoinicial numeric,
	debe numeric,
	haber numeric,
	saldofinal numeric,
	tipo_poliza character(1)
);


ALTER TYPE public.movimientos OWNER TO sistema;

--
-- TOC entry 2764 (class 1247 OID 77277545)
-- Name: pdatoaval; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE pdatoaval AS (
	aval character varying,
	domicilio character varying,
	telefono character varying(20),
	socioid integer,
	claveaval character varying(15)
);


ALTER TYPE public.pdatoaval OWNER TO sistema;

--
-- TOC entry 2765 (class 1247 OID 77277547)
-- Name: planinversion; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE planinversion AS (
	inversionid integer,
	depositoinversion numeric,
	fechainteres date,
	tasainteres numeric,
	fechavencimiento date,
	interes numeric,
	isr numeric,
	total numeric,
	dias integer
);


ALTER TYPE public.planinversion OWNER TO sistema;

--
-- TOC entry 2766 (class 1247 OID 77277549)
-- Name: precortec; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE precortec AS (
	clavefinalidad character(3),
	tipoprestamoid character(3),
	diasvencidos integer,
	reservacalculada numeric,
	saldoprestamo numeric
);


ALTER TYPE public.precortec OWNER TO sistema;

--
-- TOC entry 2767 (class 1247 OID 77277551)
-- Name: prestamogrupal; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE prestamogrupal AS (
	prestamoid integer,
	tipoprestamoid character(3),
	monto numeric,
	comision numeric,
	grupo character(25),
	contratogrupo integer
);


ALTER TYPE public.prestamogrupal OWNER TO sistema;

--
-- TOC entry 2768 (class 1247 OID 77277553)
-- Name: prestamosxt; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE prestamosxt AS (
	essubtotal integer,
	clavesocioint character(15),
	referenciaprestamo character(18),
	montoprestamo numeric,
	saldoprestamo numeric,
	tipoprestamoid character(3),
	fecha_otorga date,
	fecha_vencimiento date
);


ALTER TYPE public.prestamosxt OWNER TO sistema;

--
-- TOC entry 2769 (class 1247 OID 77277555)
-- Name: prestamoxtipo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE prestamoxtipo AS (
	essubtotal integer,
	clavesocioint character(15),
	referenciaprestamo character(18),
	montoprestamo numeric,
	saldoprestamo numeric,
	tipoprestamoid character(3),
	fecha_otorga date,
	fecha_vencimiento date,
	nombre character varying(82)
);


ALTER TYPE public.prestamoxtipo OWNER TO sistema;

--
-- TOC entry 2770 (class 1247 OID 77277557)
-- Name: primer; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE primer AS (
	primer numeric,
	ultimo numeric
);


ALTER TYPE public.primer OWNER TO sistema;

--
-- TOC entry 2771 (class 1247 OID 77277559)
-- Name: raltasbajas; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE raltasbajas AS (
	clavesocioint character(15),
	nombre character varying(80),
	fechaalta date,
	fechabaja date,
	tipo character(1)
);


ALTER TYPE public.raltasbajas OWNER TO sistema;

--
-- TOC entry 2772 (class 1247 OID 77277561)
-- Name: raltassioef; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE raltassioef AS (
	sucursal character(4),
	clave_socio_cliente character varying(18),
	grupo character varying(25),
	nombre character varying(100),
	domicilio character varying(150),
	comunidad character varying(150),
	cp integer,
	fecha_alta date,
	fecha_baja date,
	tiposocio character varying(12),
	estatusocio character varying(12),
	sexo character varying(10),
	fecha_nacimiento date,
	ocupacion character varying(40),
	saldopa numeric,
	socioid numeric,
	fechaopera date
);


ALTER TYPE public.raltassioef OWNER TO sistema;

--
-- TOC entry 2773 (class 1247 OID 77277563)
-- Name: ramortizacionesxgrupo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE ramortizacionesxgrupo AS (
	grupo character(25),
	referenciaprestamo character(18),
	numamortizacion integer,
	fechadepago date,
	importeamortizacion numeric,
	interesnormal numeric,
	iva numeric,
	totalpago numeric,
	prestamoid integer,
	clavesocioint character(15),
	nombresocio character(40),
	vencapital numeric,
	veninteres numeric,
	venmoratorio numeric,
	veniva numeric,
	ventotal numeric
);


ALTER TYPE public.ramortizacionesxgrupo OWNER TO sistema;

--
-- TOC entry 2774 (class 1247 OID 77277565)
-- Name: rantiguedad; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rantiguedad AS (
	menor90 numeric,
	mayor90 numeric
);


ALTER TYPE public.rantiguedad OWNER TO sistema;

--
-- TOC entry 2775 (class 1247 OID 77277567)
-- Name: rautorizabonifica; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rautorizabonifica AS (
	inormal numeric,
	imoratorio numeric,
	cobranza numeric,
	seguro numeric,
	comision numeric,
	ahorro numeric,
	totalbonificacion numeric
);


ALTER TYPE public.rautorizabonifica OWNER TO sistema;

--
-- TOC entry 2776 (class 1247 OID 77277569)
-- Name: ravalados; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE ravalados AS (
	clavesocioint character(15),
	referenciaprestamo character(18),
	nombre character varying(80),
	monto numeric,
	saldo numeric,
	atraso numeric
);


ALTER TYPE public.ravalados OWNER TO sistema;

--
-- TOC entry 2777 (class 1247 OID 77277571)
-- Name: ravisos; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE ravisos AS (
	avisoid integer,
	tipoavisoid integer,
	prestamoid integer,
	fechaenvio date,
	fechacontestacion date,
	diasatrasoprestamo integer,
	amortizacionesvencidas integer,
	capitalvencido numeric,
	interesvencido numeric,
	observacionaviso text,
	estatusaviso character(1),
	clavesocioint character(15),
	nombresocio character varying(80),
	referenciaprestamo character(18),
	descripciontipoaviso character varying(60)
);


ALTER TYPE public.ravisos OWNER TO sistema;

--
-- TOC entry 2778 (class 1247 OID 77277573)
-- Name: rbajassioef; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rbajassioef AS (
	sucursal character(4),
	clave_socio_cliente character varying(18),
	grupo character varying(25),
	nombre text,
	domicilio text,
	comunidad text,
	cp integer,
	fecha_alta date,
	fecha_baja date,
	motivobaja text,
	tiposocio text,
	estatusocio text,
	sexo text,
	fecha_nacimiento date,
	ocupacion text
);


ALTER TYPE public.rbajassioef OWNER TO sistema;

--
-- TOC entry 2779 (class 1247 OID 77277575)
-- Name: rbitacoracobranza; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rbitacoracobranza AS (
	consecutivo integer,
	etapa character varying(30),
	clavesocioint character varying(15),
	nombre character varying(50),
	telefono character varying(30),
	saldoactual numeric,
	montomoroso numeric,
	abonosvencidos integer,
	diasmora integer,
	fechagestion date,
	nombreatiende character varying(50),
	acuerdo text
);


ALTER TYPE public.rbitacoracobranza OWNER TO sistema;

--
-- TOC entry 2780 (class 1247 OID 77277577)
-- Name: rbuscasucursal; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rbuscasucursal AS (
	host character varying(40),
	basededatos character varying(20),
	esquema character varying(20)
);


ALTER TYPE public.rbuscasucursal OWNER TO sistema;

--
-- TOC entry 2781 (class 1247 OID 77277579)
-- Name: rcalculadiasmora; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcalculadiasmora AS (
	amortizacionid integer,
	numamortizacion integer,
	diasmora integer,
	fechapago date,
	fechapagoreal date
);


ALTER TYPE public.rcalculadiasmora OWNER TO sistema;

--
-- TOC entry 2782 (class 1247 OID 77277581)
-- Name: rcaptacion811; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcaptacion811 AS (
	nivel integer,
	concepto text,
	a numeric,
	b numeric,
	c numeric,
	d numeric,
	e numeric,
	cuentasiti character(24),
	tiposaldoa character(3),
	tiposaldob character(3),
	tiposaldoc character(3),
	tiposaldod character(3),
	tiposaldoe character(3)
);


ALTER TYPE public.rcaptacion811 OWNER TO sistema;

--
-- TOC entry 2783 (class 1247 OID 77277583)
-- Name: rcaptacion815; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcaptacion815 AS (
	nivel integer,
	concepto text,
	a numeric,
	b numeric,
	cuentasiti character(24),
	tiposaldoa character(3),
	tiposaldob character(3)
);


ALTER TYPE public.rcaptacion815 OWNER TO sistema;

--
-- TOC entry 2784 (class 1247 OID 77277585)
-- Name: rcarteracomunidad; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcarteracomunidad AS (
	tiposocioid integer,
	prestamoid integer,
	socioid integer,
	sujetoid integer,
	clavesocioint character(15),
	referenciaprestamo character(18),
	tipoprestamo character(3),
	nombre character varying(80),
	paterno character varying(80),
	materno character varying(80),
	calle character varying(80),
	numeroext character varying(20),
	numeroint character varying(20),
	colonia character varying(80),
	ciudad character varying(80),
	estado character varying(80),
	telefono character varying(30),
	comunidad character varying(80),
	cp character varying(7),
	rfc character(20),
	curp character(25),
	sexo character(3),
	totalingresos numeric,
	ocupacion character varying(60),
	finalidad character varying(30),
	fecha_otorga date,
	fecha_vencimiento date,
	fecha_ultimopago date,
	fecha_nacimiento date,
	fecha_de_ingreso date,
	mesesavencer numeric,
	montoprestamo numeric,
	saldoprest numeric,
	cantidadpagada numeric,
	diasatraso numeric,
	amortizacion numeric,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	vencidas numeric,
	ahorro numeric,
	ahorro_reci numeric,
	caval1 character(15),
	nombreaval1 character varying(80),
	calleaval1 character varying(50),
	numeroextaval1 character(10),
	numerointaval1 character(10),
	coloniaaval1 character varying(50),
	comunidadaval1 character varying(50),
	ciudadaval1 character varying(50),
	estadoaval1 character varying(50),
	telefonoaval1 character(20),
	caval2 character(15),
	nombreaval2 character varying(80),
	calleaval2 character varying(50),
	numeroextaval2 character(10),
	numerointaval2 character(10),
	coloniaaval2 character varying(50),
	comunidadaval2 character varying(50),
	ciudadaval2 character varying(50),
	estadoaval2 character varying(50),
	telefonoaval2 character(20),
	caval3 character(15),
	nombreaval3 character varying(80),
	calleaval3 character varying(50),
	numeroextaval3 character(10),
	numerointaval3 character(10),
	coloniaaval3 character varying(50),
	comunidadaval3 character varying(50),
	ciudadaval3 character varying(50),
	estadoaval3 character varying(50),
	telefonoaval3 character(20),
	caval4 character(15),
	nombreaval4 character varying(80),
	calleaval4 character varying(50),
	numeroextaval4 character(10),
	numerointaval4 character(10),
	coloniaaval4 character varying(50),
	comunidadaval4 character varying(50),
	ciudadaval4 character varying(50),
	estadoaval4 character varying(50),
	telefonoaval4 character(20)
);


ALTER TYPE public.rcarteracomunidad OWNER TO sistema;

--
-- TOC entry 2785 (class 1247 OID 77277587)
-- Name: rcatalogominimo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcatalogominimo AS (
	cmcuenta character(24),
	cmacumulable character(24),
	ordenpresentacion integer,
	c1 character varying,
	c2 character varying,
	c3 character varying,
	c4 character varying,
	c5 character varying,
	saldo numeric,
	naturaleza character(10),
	rubro character(10),
	cuentasiti character(24)
);


ALTER TYPE public.rcatalogominimo OWNER TO sistema;

--
-- TOC entry 2786 (class 1247 OID 77277589)
-- Name: rcatalogosocio; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcatalogosocio AS (
	clavesocioint character(15),
	nombresocio character varying(80),
	domicilio character varying(150),
	telefono character varying(20),
	ciudad character varying(35),
	fechaingreso date,
	fechabaja date,
	tipo character(1),
	edad numeric
);


ALTER TYPE public.rcatalogosocio OWNER TO sistema;

--
-- TOC entry 2787 (class 1247 OID 77277591)
-- Name: rclasificacion; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rclasificacion AS (
	clavesocioint character(15),
	nombre character varying(80),
	pagospactados integer,
	pagosenmora integer,
	creditospagados integer,
	creditosvigentes integer,
	saldototal numeric,
	diasatrasomaximo integer,
	montoultimocred numeric,
	montomaximocred numeric,
	correccionxanios numeric,
	anios numeric,
	calificacion numeric,
	clasificacion character(3),
	ultimocred character(3),
	descultimocred character varying(30)
);


ALTER TYPE public.rclasificacion OWNER TO sistema;

--
-- TOC entry 2788 (class 1247 OID 77277593)
-- Name: rclientefinafim; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rclientefinafim AS (
	org_id character varying(15),
	acred_id character varying(15),
	curp character varying(20),
	ife character varying(20),
	primer_ap character varying(30),
	segundo_ap character varying(30),
	nombre character varying(30),
	fecha_nac character(10),
	edo_nac character varying(20),
	sexo character varying(6),
	tel character(10),
	cve_edo_civil character varying(15),
	edo_res character varying(20),
	municipio character varying(50),
	localidad character varying(50),
	calle character varying(30),
	numero_exterior character varying(15),
	numero_interior character varying(15),
	colonia character varying(100),
	cp character(5),
	metodologia character varying(15),
	nom_grupo character varying(25),
	estudios character varying(20),
	actividad character varying(90),
	fecha_inicio_act_productiva character(10),
	ubicacion_negocio character varying(40),
	personas_trabajando integer,
	ingreso_semanal numeric,
	rol_en_hogar character varying(20),
	sucursal character varying(15)
);


ALTER TYPE public.rclientefinafim OWNER TO sistema;

--
-- TOC entry 2789 (class 1247 OID 77277595)
-- Name: rcobranza; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcobranza AS (
	cobranza numeric,
	ivacobranza numeric
);


ALTER TYPE public.rcobranza OWNER TO sistema;

--
-- TOC entry 2790 (class 1247 OID 77277597)
-- Name: rcobranzaesperada; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcobranzaesperada AS (
	prestamoid integer,
	clavesocioint character(15),
	nombre character varying(80),
	referenciaprestamo character(18),
	fechadepago date,
	amortizacion numeric,
	vencidas numeric,
	diasint numeric,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	total numeric
);


ALTER TYPE public.rcobranzaesperada OWNER TO sistema;

--
-- TOC entry 2791 (class 1247 OID 77277599)
-- Name: rcobroporgrupo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcobroporgrupo AS (
	prestamoid integer,
	clavesocioint character(16),
	nombresocio character varying(80),
	referenciaprestamo character(18),
	ahorrocompromiso numeric,
	pago numeric
);


ALTER TYPE public.rcobroporgrupo OWNER TO sistema;

--
-- TOC entry 2792 (class 1247 OID 77277601)
-- Name: rcomision; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcomision AS (
	comision numeric,
	ivacomision numeric
);


ALTER TYPE public.rcomision OWNER TO sistema;

--
-- TOC entry 2793 (class 1247 OID 77277603)
-- Name: rcomite; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcomite AS (
	comiteid integer,
	titulo character varying(25),
	nombre character varying(120)
);


ALTER TYPE public.rcomite OWNER TO sistema;

--
-- TOC entry 2794 (class 1247 OID 77277605)
-- Name: rconsultaburo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rconsultaburo AS (
	consultaid integer,
	numerodecontrol character(15),
	producto character(3),
	responsabilidad character(1),
	contrato character(2),
	paterno character varying(20),
	materno character varying(20),
	primer_nombre character varying(26),
	segundo_nombre character varying(26),
	fecha_nacimiento date,
	rfc character varying(13),
	edo_civil character(1),
	genero character(1),
	no_ife character varying(20),
	curp character(18),
	direccion1 character varying(40),
	direccion2 character varying(40),
	colonia character varying(40),
	ciudad character varying(40),
	estado character varying(4),
	cp character(5),
	fecha_residencia date,
	telefono character varying(10),
	tipo_domicilio character(1),
	fecha date,
	hora time without time zone,
	usuarioid character(20)
);


ALTER TYPE public.rconsultaburo OWNER TO sistema;

--
-- TOC entry 2795 (class 1247 OID 77277607)
-- Name: rconsultamov; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rconsultamov AS (
	clavesocioint character(15),
	nombresocio character varying(81),
	saldo1 numeric,
	saldo2 numeric,
	saldo3 numeric,
	saldo4 numeric,
	fecha1 date,
	fecha2 date,
	fecha3 date,
	fecha4 date
);


ALTER TYPE public.rconsultamov OWNER TO sistema;

--
-- TOC entry 2796 (class 1247 OID 77277609)
-- Name: rconvenios; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rconvenios AS (
	clavesocioint character(15),
	referenciaprestamo character(18),
	nombre character(80),
	usuarioid character(20),
	fechaconvenio date,
	lugar character(7)
);


ALTER TYPE public.rconvenios OWNER TO sistema;

--
-- TOC entry 2797 (class 1247 OID 77277611)
-- Name: rcortecaja; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcortecaja AS (
	folio integer,
	referencia integer,
	serie character(2),
	socioid integer,
	clavesocioint character(15),
	fecha date,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	deposito numeric,
	retiro numeric,
	tipomovimientoid character(2),
	tipoprestamoid character(3),
	cobranza numeric
);


ALTER TYPE public.rcortecaja OWNER TO sistema;

--
-- TOC entry 2798 (class 1247 OID 77277613)
-- Name: rcortecajabitacora; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcortecajabitacora AS (
	folio integer,
	referencia integer,
	serie character(2),
	socioid integer,
	clavesocioint character(15),
	fecha date,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	deposito numeric,
	retiro numeric,
	tipomovimientoid character(2),
	tipoprestamoid character(3),
	cobranza numeric,
	fechahora character varying(32),
	usuarioid character(20),
	nombresocio character varying(80)
);


ALTER TYPE public.rcortecajabitacora OWNER TO sistema;

--
-- TOC entry 2799 (class 1247 OID 77277615)
-- Name: rcortecajapdf; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcortecajapdf AS (
	folio integer,
	referencia integer,
	serie character(2),
	socioid integer,
	clavesocioint character(15),
	fecha date,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	deposito numeric,
	retiro numeric,
	tipomovimientoid character(2),
	tipoprestamoid character(3),
	cobranza numeric
);


ALTER TYPE public.rcortecajapdf OWNER TO sistema;

--
-- TOC entry 2800 (class 1247 OID 77277617)
-- Name: rcreditosfinafim; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcreditosfinafim AS (
	no_de_disposicion character(18),
	org_id character varying(11),
	acred_id character varying(15),
	credito_id character varying(11),
	destino_credito character varying(90),
	monto_credito numeric,
	fecha_entrega character(10),
	fecha_vencimiento character(10),
	tasa_mensual numeric,
	tipo_tasa character varying(20),
	frecuencia_pagos character varying(20),
	finalidad character varying(90),
	subfinalidad1 character varying(90),
	subfinalidad2 character varying(90)
);


ALTER TYPE public.rcreditosfinafim OWNER TO sistema;

--
-- TOC entry 2801 (class 1247 OID 77277619)
-- Name: rcuentasdesbloqueadassioef; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rcuentasdesbloqueadassioef AS (
	sucursal character(4),
	clave_socio_cliente character varying(18),
	nombre_socio character varying(35),
	tiposocio character varying(12),
	motivo character varying(40),
	fecha_desbloqueo date,
	usuario_desbloquea character varying(15),
	estatussocio character varying(15)
);


ALTER TYPE public.rcuentasdesbloqueadassioef OWNER TO sistema;

--
-- TOC entry 2802 (class 1247 OID 77277621)
-- Name: rdepositos; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rdepositos AS (
	clavesocioint character(15),
	paterno character varying(20),
	materno character varying(20),
	nombre character varying(40),
	depositos numeric,
	idecalculado numeric,
	ideretenido numeric,
	rfccaja character varying(20),
	nombrecaja character varying(80),
	razonsocial character varying(60),
	montoide numeric,
	idexrecaudar numeric,
	idexrecaudaranterior numeric,
	socioid integer
);


ALTER TYPE public.rdepositos OWNER TO sistema;

--
-- TOC entry 2803 (class 1247 OID 77277623)
-- Name: rdepreciacion; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rdepreciacion AS (
	activoid integer,
	activoclave character(15),
	activodescripcion character varying(255),
	valormercado numeric,
	feciniciodepfiscal date,
	inpcprimeramitad numeric,
	inpcadquiscion numeric,
	factdeprec numeric,
	deprecactejerc numeric,
	factsaldo numeric,
	saldoxdeduc numeric,
	deprecactulizada numeric,
	baseimpac numeric
);


ALTER TYPE public.rdepreciacion OWNER TO sistema;

--
-- TOC entry 2804 (class 1247 OID 77277625)
-- Name: rdetallemovicaptacion; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE rdetallemovicaptacion AS (
	suc character(4),
	clavesocioint character(16),
	nombresocio character varying(80),
	fechamvto date,
	t_mvto character(2),
	desctipomovimiento character(30),
	deposito numeric,
	retiro numeric,
	s_pol character(30),
	usuarioid character(20),
	grupo character(25)
);


ALTER TYPE public.rdetallemovicaptacion OWNER TO sistema;

--
-- TOC entry 2805 (class 1247 OID 77277627)
-- Name: recsocio; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE recsocio AS (
	sucursal character(4),
	clavesocio character varying(20),
	nombre character varying(50),
	curp character varying(50),
	rfc character varying(50),
	edad integer,
	sexo character varying(50),
	fecha_nac character(50),
	tipo_socio character varying(50),
	ciudadmexid integer,
	comunidad character varying(50),
	colonia character varying(50),
	calle character varying(30),
	numero_ext character varying(50),
	numero_int character varying(50),
	tel_domicilio character varying(55),
	cod_postal character varying(50),
	ciudad_nac character varying(50),
	estado character varying(50),
	ocupacion character varying(50),
	profesion character varying(50),
	nivel_estudios character varying(50),
	fecha_ingreso character(50),
	grupo character varying(50),
	lastusuario character varying(50),
	lastupdate character varying(50),
	estadocivil character varying(50),
	fecha_solicitud character(50),
	tipo_casa character varying(50),
	pa character varying(50)
);


ALTER TYPE public.recsocio OWNER TO sistema;

--
-- TOC entry 2806 (class 1247 OID 77277629)
-- Name: redocta; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE redocta AS (
	numamortizacion integer,
	fechadepago date,
	ultimoabono date,
	importeamortizacion numeric,
	capital numeric,
	interes numeric,
	moratorio numeric,
	iva numeric,
	total numeric
);


ALTER TYPE public.redocta OWNER TO sistema;

--
-- TOC entry 2807 (class 1247 OID 77277631)
-- Name: redoctainversion; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE redoctainversion AS (
	tipomov character(5),
	inversionid integer,
	clavesocioint character(15),
	fechadepago date,
	capital numeric,
	interes numeric,
	isr numeric,
	proxfechainteres date,
	proxinteres numeric,
	proxisr numeric
);


ALTER TYPE public.redoctainversion OWNER TO sistema;

--
-- TOC entry 2808 (class 1247 OID 77277633)
-- Name: restadistico; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE restadistico AS (
	noprestamos integer,
	fechaultprestamo date,
	cumplimiento integer,
	observacion character(255)
);


ALTER TYPE public.restadistico OWNER TO sistema;

--
-- TOC entry 2809 (class 1247 OID 77277635)
-- Name: restadisticoctas; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE restadisticoctas AS (
	tipo character(3),
	descripcion character(30),
	nosocios integer,
	saldo numeric,
	ordenmov character(1)
);


ALTER TYPE public.restadisticoctas OWNER TO sistema;

--
-- TOC entry 2810 (class 1247 OID 77277637)
-- Name: restadisticoporsexo; Type: TYPE; Schema: public; Owner: sistema
--

CREATE TYPE restadisticoporsexo AS (
	sucid character(4),
	nombrecaja character varying(80),
	mujer integer,
	hombre integer,
	tipomov character(2),
	desctipomov ch