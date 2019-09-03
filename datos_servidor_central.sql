


-- ----------------------------
-- Table structure for datos_servidor_central
-- ----------------------------
DROP TABLE IF EXISTS "public"."datos_servidor_central";
CREATE TABLE "public"."datos_servidor_central" (
  "datosid" int2 NOT NULL DEFAULT nextval('datos_servidor_central_datosid_seq'::regclass),
  "host" varchar(255) COLLATE "pg_catalog"."default",
  "base" varchar(255) COLLATE "pg_catalog"."default",
  "esquema" varchar(255) COLLATE "pg_catalog"."default",
  "usuario" varchar(255) COLLATE "pg_catalog"."default",
  "password" varchar(255) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of datos_servidor_central
-- ----------------------------
INSERT INTO "public"."datos_servidor_central" VALUES (1, 'sucursal15.cyolomecatl.com', 'cajayolo15', 'sucursal15', 'sistema', '1sc4pslu2');
