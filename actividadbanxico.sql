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

 Date: 04/03/2019 17:52:22
*/


-- ----------------------------
-- Table structure for actividadbanxico
-- ----------------------------
DROP TABLE IF EXISTS "public"."actividadbanxico";
CREATE TABLE "public"."actividadbanxico" (
  "actividadid" varchar(10) NOT NULL,
  "nombre" varchar(60),
  "nivelderiesgo" int4
)
;

-- ----------------------------
-- Primary Key structure for table actividadbanxico
-- ----------------------------
ALTER TABLE "public"."actividadbanxico" ADD CONSTRAINT "actividadbanxico_pkey" PRIMARY KEY ("actividadid");

-- ----------------------------
-- Foreign Keys structure for table actividadbanxico
-- ----------------------------
ALTER TABLE "public"."actividadbanxico" ADD CONSTRAINT "actividadbanxico_nivelderiesgo_fkey" FOREIGN KEY ("nivelderiesgo") REFERENCES "nivelderiesgo" ("nivelderiesgo") ON DELETE NO ACTION ON UPDATE NO ACTION;
