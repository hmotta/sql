/*
 Navicat Premium Data Transfer

 Source Server         : server-fap.ddns.net
 Source Server Type    : PostgreSQL
 Source Server Version : 90514
 Source Host           : server-fap.ddns.net:5432
 Source Catalog        : monteverde_prueba01
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 90514
 File Encoding         : 65001

 Date: 22/04/2019 18:39:15
*/


-- ----------------------------
-- Table structure for cat_ahorros_mayor
-- ----------------------------
DROP TABLE IF EXISTS "public"."cat_ahorros_mayor";
CREATE TABLE "public"."cat_ahorros_mayor" (
  "catid" int4 NOT NULL DEFAULT nextval('cat_ahorros_mayor_catid_seq'::regclass),
  "tipomovimientoid" char(2) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of cat_ahorros_mayor
-- ----------------------------
INSERT INTO "public"."cat_ahorros_mayor" VALUES (1, 'AA');

-- ----------------------------
-- Primary Key structure for table cat_ahorros_mayor
-- ----------------------------
ALTER TABLE "public"."cat_ahorros_mayor" ADD CONSTRAINT "cat_ahorros_mayor_pkey" PRIMARY KEY ("catid");

-- ----------------------------
-- Foreign Keys structure for table cat_ahorros_mayor
-- ----------------------------
ALTER TABLE "public"."cat_ahorros_mayor" ADD CONSTRAINT "cat_ahorros_mayor_tipomovimientoid_fkey" FOREIGN KEY ("tipomovimientoid") REFERENCES "tipomovimiento" ("tipomovimientoid") ON DELETE NO ACTION ON UPDATE NO ACTION;
