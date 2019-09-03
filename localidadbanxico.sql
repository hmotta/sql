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

 Date: 04/03/2019 17:53:01
*/


-- ----------------------------
-- Table structure for localidadbanxico
-- ----------------------------
DROP TABLE IF EXISTS "public"."localidadbanxico";
CREATE TABLE "public"."localidadbanxico" (
  "localidadid" varchar(10) NOT NULL,
  "nombre" varchar(50)
)
;

-- ----------------------------
-- Primary Key structure for table localidadbanxico
-- ----------------------------
ALTER TABLE "public"."localidadbanxico" ADD CONSTRAINT "localidadbanxico_pkey" PRIMARY KEY ("localidadid");
