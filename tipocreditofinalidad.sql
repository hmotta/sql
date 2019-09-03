/*
 Navicat Premium Data Transfer

 Source Server         : server-fap.ddns.net
 Source Server Type    : PostgreSQL
 Source Server Version : 90514
 Source Host           : server-fap.ddns.net:5432
 Source Catalog        : cajayolo03
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 90514
 File Encoding         : 65001

 Date: 24/04/2019 13:03:21
*/


-- ----------------------------
-- Table structure for tipocreditofinalidad
-- ----------------------------
DROP TABLE IF EXISTS "public"."tipocreditofinalidad";
CREATE TABLE "public"."tipocreditofinalidad" (
  "tipoprestamoid" char(3) COLLATE "pg_catalog"."default",
  "finalidadid" int4
)
;

-- ----------------------------
-- Uniques structure for table tipocreditofinalidad
-- ----------------------------
ALTER TABLE "public"."tipocreditofinalidad" ADD CONSTRAINT "tipocreditofinalidad_tipoprestamoid_key" UNIQUE ("tipoprestamoid", "finalidadid");

-- ----------------------------
-- Foreign Keys structure for table tipocreditofinalidad
-- ----------------------------
ALTER TABLE "public"."tipocreditofinalidad" ADD CONSTRAINT "tipocreditofinalidad_finalidadid_fkey" FOREIGN KEY ("finalidadid") REFERENCES "catalogofinalidad" ("finalidadid") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."tipocreditofinalidad" ADD CONSTRAINT "tipocreditofinalidad_tipoprestamoid_fkey" FOREIGN KEY ("tipoprestamoid") REFERENCES "tipoprestamo" ("tipoprestamoid") ON DELETE NO ACTION ON UPDATE NO ACTION;
