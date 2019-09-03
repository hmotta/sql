/*
 Navicat Premium Data Transfer

 Source Server         : 192.168.0.135
 Source Server Type    : PostgreSQL
 Source Server Version : 80223
 Source Host           : 192.168.0.135:5432
 Source Catalog        : cajayolo03
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 80223
 File Encoding         : 65001

 Date: 04/03/2019 17:51:15
*/


-- ----------------------------
-- Table structure for ingresoegresoconceatucliente
-- ----------------------------
DROP TABLE IF EXISTS "public"."ingresoegresoconceatucliente";
CREATE TABLE "public"."ingresoegresoconceatucliente" (
  "solicitudingresoid" int4,
  "socioid" int4,
  "actividadgeneral" int4,
  "actividadprincipal" varchar(200),
  "salariomensual" numeric,
  "otrosingresos" numeric,
  "ingresosfamiliares" numeric,
  "ingresototal" numeric,
  "egresomensual" numeric,
  "ahorromensual" numeric,
  "sectoreconomico" int4,
  "estadosactividad" varchar(32),
  "coberturageografica" int4,
  "origenrecursos" varchar(8),
  "ventaactivo" int4,
  "destinorecursos" varchar(6),
  "otrodestino" text
)
;

-- ----------------------------
-- Uniques structure for table ingresoegresoconceatucliente
-- ----------------------------
ALTER TABLE "public"."ingresoegresoconceatucliente" ADD CONSTRAINT "ingresoegresoconceatucliente_socioid_key" UNIQUE ("socioid");
ALTER TABLE "public"."ingresoegresoconceatucliente" ADD CONSTRAINT "ingresoegresoconceatucliente_solicitudingresoid_key" UNIQUE ("solicitudingresoid");

-- ----------------------------
-- Foreign Keys structure for table ingresoegresoconceatucliente
-- ----------------------------
ALTER TABLE "public"."ingresoegresoconceatucliente" ADD CONSTRAINT "ingresoegresoconceatucliente_socioid_fkey" FOREIGN KEY ("socioid") REFERENCES "socio" ("socioid") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."ingresoegresoconceatucliente" ADD CONSTRAINT "ingresoegresoconceatucliente_solicitudingresoid_fkey" FOREIGN KEY ("solicitudingresoid") REFERENCES "solicitudingreso" ("solicitudingresoid") ON DELETE NO ACTION ON UPDATE NO ACTION;
