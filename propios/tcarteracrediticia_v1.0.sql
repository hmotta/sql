DROP TYPE tcarteracrediticia CASCADE;
CREATE TYPE tcarteracrediticia AS (
	clavesocioint character(15),
	referenciaprestamo character(18),
	ejercicio integer,
	periodo integer,
	fechacierre date,
	diasvencidos integer,
	porcentajeaplicado numeric,
	factoraplicado numeric,
	saldoprestamo numeric,
	reservacalculada numeric,
	interesdevengadomenoravencido numeric,
	interesdevengadomayoravencido numeric,
	pagocapitalenperiodo numeric,
	pagointeresenperiodo numeric,
	pagomoratorioenperiodo numeric,
	bonificacionenperiodo numeric,
	bonificacionmorenperiodo numeric,
	noamorvencidas integer,
	saldovencidomernoavencido numeric,
	saldovencidomayoravencido numeric,
	fechaultamorpagada date,
	desctipoprestamo character(30),
	montoprestamo numeric,
	fecha_vencimiento date,
	tantos integer,
	depositogarantia numeric,
	tasanormal numeric,
	tasa_moratoria numeric,
	nombresocio character(82),
	calle character varying(30),
	numero_ext character varying(15),
	colonia character varying(50),
	comunidad character varying(50),
	codpostal integer,
	nombreciudadmex character varying(50),
	ultimoabono date,
	diastraspasoavencida integer,
	ultimoabonointeres date,
	numero_de_amor integer,
	fecha_otorga date,
	descripcionfinalidad character varying(30),
	diasrestantes integer,
	frecuencia numeric,
	interesdevmormenor numeric,
	interesdevmormayor numeric,
	condiciones character varying(50),
	estacion character varying(30),
	dias_cobro integer,
	prestamodescontado character(2),
	estacion1 character varying(30),
	norenovaciones integer,
	clavegarantia character(3),
	monto_garantia numeric,
	interesanterior numeric,
	devengadovigente numeric,
	devengadovencido numeric,
	primerincumplimiento date,
	fecha_1er_pago date,
	rfc character(16),
	fechavaluaciongarantia date,
	numeroavales integer,
	sujetoidrelacionado integer,
	clasificacioncontable character varying(24),
	tipocobranza character varying(50),
	personajuridica character varying(10),
	reservaidnc numeric,
	diascapital integer,
	diasinteres integer,
	tipoprestamoid character(3),
	calculonormalid varchar(30));


ALTER TYPE public.tcarteracrediticia OWNER TO sistema;
