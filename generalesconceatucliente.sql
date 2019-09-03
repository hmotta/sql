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

 Date: 04/03/2019 17:44:22
*/


-- ----------------------------
-- Table structure for generalesconceatucliente
-- ----------------------------
DROP TABLE IF EXISTS "public"."generalesconceatucliente";
CREATE TABLE "public"."generalesconceatucliente" (
  "solicitudingresoid" int4,
  "socioid" int4,
  "personajuridicaid" int4,
  "docindentificacion" int4,
  "numidentificacion" char(15),
  "estatustiposocio" int4,
  "nacionalidad" int4,
  "familiarenempresa" int4,
  "nombrefamiliarenempresa" varchar(50),
  "parentescofamiliar" varchar(21),
  "puestofamiliar" varchar(50),
  "descomprobantedom" varchar(150),
  "refubicadom" text,
  "poblacionindigena" int4,
  "localidadresidencia" varchar(200),
  "direccionextranjero" text,
  "otranacionalidad" text
)
;

-- ----------------------------
-- Uniques structure for table generalesconceatucliente
-- ----------------------------
ALTER TABLE "public"."generalesconceatucliente" ADD CONSTRAINT "generalesconceatucliente_socioid_key" UNIQUE ("socioid");
ALTER TABLE "public"."generalesconceatucliente" ADD CONSTRAINT "generalesconceatucliente_solicitudingresoid_key" UNIQUE ("solicitudingresoid");

-- ----------------------------
-- Foreign Keys structure for table generalesconceatucliente
-- ----------------------------
ALTER TABLE "public"."generalesconceatucliente" ADD CONSTRAINT "generalesconceatucliente_socioid_fkey" FOREIGN KEY ("socioid") REFERENCES "socio" ("socioid") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."generalesconceatucliente" ADD CONSTRAINT "generalesconceatucliente_solicitudingresoid_fkey" FOREIGN KEY ("solicitudingresoid") REFERENCES "solicitudingreso" ("solicitudingresoid") ON DELETE NO ACTION ON UPDATE NO ACTION;
