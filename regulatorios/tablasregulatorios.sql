-- Table: sucursal1.prestamobancario

drop table carteracomunidadfecha; 
create table carteracomunidadfecha (
 carteraid           serial,
 fechadegeneracion   date,
 prestamoid          int4,
 clavesocioint       char(15),
 grupo               char(25),
 referenciaprestamo  char(18),
 tipoprestamo        char(3),
 nombre              varchar(80),
 direccion           varchar(80),
 colonia             varchar(80),
 telefono            varchar(20),
 comunidad           varchar(60),
 rfc                 char(16),
 curp                char(20),
 sexo                char(3),
 totalingresos       numeric,
 ocupacion           varchar(60),
 finalidaddefault    varchar(30),
 finalidadcredito    varchar(30),
 fecha_otorga        date,
 fecha_vencimiento   date,
 fecha_ultimopago    date,
 fecha_nacimiento    date,
 mesesavencer        numeric,
 montoprestamo       numeric,
 saldoprest          numeric,
 cantidadpagada      numeric,
 diasatraso          integer,
 amortizacion        numeric,
 capital             numeric,
 interes             numeric,
 moratorio           numeric,
 iva                 numeric,
 vencidas            integer,
 caval1              char(15),
 nombreaval1         varchar(80),
 direccionaval1      varchar(130),
 caval2              char(15),
 nombreaval2         varchar(80),
 direccionaval2      varchar(130),
 caval3              char(15),
 nombreaval3         varchar(80),
 direccionaval3      varchar(130),
 caval4              char(15),
 nombreaval4         varchar(80),
 direccionaval4      varchar(130)
);


CREATE TABLE prestamobancario
(
  prestamobancarioid serial,
  fondeador char(40),
  banco char(40),
  fechapagare date,
  fechavencimiento date,
  montooriginal numeric,
  saldoinsoluto numeric,
  saldoinsolutoredescontado numeric,
  tasa char(10),
  conredescuento char(2),
  garantiaefectiva numeric,
  estatus char(1)
);


CREATE TABLE catalogominimo2 (
    catalogoid serial,
    cuentasiti char(24),
    c1 character varying,
    c2 character varying,
    c3 character varying,
    c4 character varying,
    nivel integer,
    cuentaid character(24)
);
