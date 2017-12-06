CREATE OR REPLACE FUNCTION carteracrediticiasioefc(integer, integer) RETURNS SETOF tcarteracrediticia
    AS $_$
declare
  pejercicio alias for $1;
  pperiodo   alias for $2;

  r tcarteracrediticia%rowtype;

 f record;
  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop

  raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

  dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
  dblink2:='set search_path to public,'||f.esquema||';
     select * from carteracrediticiasioef('||pejercicio||','||pperiodo||');';
  for r in
   select * from
    dblink(dblink1,dblink2) as 
t (
 clavesocioint      char(15),
 referenciaprestamo char(18),
 ejercicio          int4,
 periodo            int4,
 fechacierre        date,
 diasvencidos       int4,
 porcentajeaplicado numeric,
 factoraplicado     numeric,
 saldoprestamo      numeric,
 reservacalculada   numeric,
 interesdevengadomenoravencido numeric,
 interesdevengadomayoravencido numeric,
 pagocapitalenperiodo numeric,
 pagointeresenperiodo numeric,
 pagomoratorioenperiodo numeric,
 bonificacionenperiodo numeric,
 bonificacionmorenperiodo numeric,
 noamorvencidas     int4,
 saldovencidomernoavencido numeric,
 saldovencidomayoravencido numeric,
 fechaultamorpagada date,
 tipocredito   char(30),
 montoprestamo      numeric,
 fecha_vencimiento  date,
 tantos             int4,
 depositogarantia   numeric,
 tasanormal         numeric,
 tasa_moratoria     numeric,
 nombresocio        char(82),
 calle              varchar(30),
 numero_ext         varchar(15),
 colonia            varchar(50),
 comunidad          varchar(50),
 codpostal          int4,
 nombreciudadmex    varchar(50),
 ultimoabono        date,
 diastraspasoavencida int4,
 ultimoabonointeres   date,
 numero_de_amor       int4,
 fecha_otorga         date,
 descripcionfinalidad varchar(30),
 diasrestantes        int4,
 frecuencia           numeric,
 interesdevmormenor   numeric,
 interesdevmormayor   numeric,
 condiciones         varchar(50),
 estacion            varchar(30),
 dias_cobro          int4,
 prestamodescontado  char(2),
 estacion1            varchar(30),
 norenovaciones       int4,
 clavegarantia        char(3),
 monto_garantia        numeric,
 interesanterior      numeric,
 devengadovigente     numeric,
 devengadovencido     numeric,
 primerincumplimiento date,
 fecha_1er_pago date, rfc    character(16),
 fechavaluaciongarantia date,
 numeroavales   integer,
 sujetoidrelacionado integer,
 clasificacioncontable varchar(24),
 tipocobranza varchar(50),
 personajuridica varchar(10),reservaidnc numeric,
 diascapital integer,
 diasinteres integer,
 tipoprestamoid character(3),
 calculonormalid varchar(30),
 desfinalidad character(120),
 disposicion character(120),
 fondeadora character(120),
 suc                char(4),
 desctipoprestamo character(30),
 devengadomoravigente     numeric,
 devengadomoravencido     numeric,
 devengadoctasorden       numeric)

  loop

    return next r;

  end loop;


end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;