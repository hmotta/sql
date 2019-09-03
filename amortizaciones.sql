/*
 Navicat Premium Data Transfer

 Source Server         : Oficinas
 Source Server Type    : PostgreSQL
 Source Server Version : 80207
 Source Host           : sucursal15.cyolomecatl.com:5432
 Source Catalog        : cajayolo03
 Source Schema         : sucursal3

 Target Server Type    : PostgreSQL
 Target Server Version : 80207
 File Encoding         : 65001

 Date: 18/09/2018 10:24:08
*/


-- ----------------------------
-- Table structure for amortizaciones
-- ----------------------------
DROP TABLE IF EXISTS "sucursal3"."amortizaciones";
CREATE TABLE "sucursal3"."amortizaciones" (
  "amortizacionid" int4 NOT NULL DEFAULT nextval('"sucursal3".amortizaciones_amortizacionid_seq'::regclass),
  "prestamoid" int4 NOT NULL,
  "numamortizacion" int4 NOT NULL,
  "fechadepago" date NOT NULL,
  "importeamortizacion" numeric NOT NULL,
  "interesnormal" numeric NOT NULL,
  "saldo_absoluto" numeric NOT NULL,
  "interespagado" numeric NOT NULL,
  "abonopagado" numeric NOT NULL,
  "ultimoabono" date NOT NULL,
  "iva" numeric,
  "totalpago" numeric,
  "ahorro" numeric DEFAULT 0,
  "ahorropagado" numeric DEFAULT 0,
  "cobranza" numeric DEFAULT 0,
  "cobranzapagado" numeric DEFAULT 0,
  "moratoriopagado" numeric
)
;

-- ----------------------------
-- Indexes structure for table amortizaciones
-- ----------------------------
CREATE INDEX "amortizaciones_fkindex1" ON "sucursal3"."amortizaciones" USING btree (
  "prestamoid" "pg_catalog"."int4_ops"
);

-- ----------------------------
-- Triggers structure for table amortizaciones
-- ----------------------------
CREATE TRIGGER "trigger_amortizacion" BEFORE INSERT OR UPDATE ON "sucursal3"."amortizaciones"
FOR EACH ROW
EXECUTE PROCEDURE "public"."trigger_insert_update_amortizacion"();

-- ----------------------------
-- Primary Key structure for table amortizaciones
-- ----------------------------
ALTER TABLE "sucursal3"."amortizaciones" ADD CONSTRAINT "amortizaciones_pk" PRIMARY KEY ("amortizacionid");

-- ----------------------------
-- Foreign Keys structure for table amortizaciones
-- ----------------------------
ALTER TABLE "sucursal3"."amortizaciones" ADD CONSTRAINT "prestamosamortizaciones" FOREIGN KEY ("prestamoid") REFERENCES "prestamos" ("prestamoid") ON DELETE NO ACTION ON UPDATE NO ACTION;
