/*
 Navicat Premium Data Transfer

 Source Server         : SIOEF
 Source Server Type    : PostgreSQL
 Source Server Version : 90519
 Source Host           : 192.168.1.135:5432
 Source Catalog        : cajayolo01
 Source Schema         : sucursal1

 Target Server Type    : PostgreSQL
 Target Server Version : 90519
 File Encoding         : 65001

 Date: 19/08/2019 18:26:46
*/


-- ----------------------------
-- Table structure for responsable_une
-- ----------------------------
DROP TABLE IF EXISTS responsable_une;
CREATE TABLE responsable_une (
  responsable_id serial NOT NULL ,
  responsable varchar(255) ,
  horario varchar(255) ,
  domicilio varchar(255) ,
  telefono varchar(255) ,
  correo varchar(255) ,
  pag_web varchar(255) ,
  activo int2 NOT NULL,
  region varchar(255)
)
;

-- ----------------------------
-- Records of responsable_une
-- ----------------------------
INSERT INTO responsable_une VALUES (3, 'LIC. BRANDO BARRAGAN TLAQUIZ', 'LUNES A VIERNES DE 9:00 A 17:00 HRS.', '5 DE FEBRERO No. 114-A, COL. CENTRO, AJALPAN, PUEBLA, C.P. 75910', '(236) 690 06 47', 'une@cyolomecatl.com', 'www.cooperativayolomecatl.com.mx', 1, 'PUEBLA');
INSERT INTO responsable_une VALUES (2, 'L.A.E. MARÍA LUISA MARTÍNEZ HERNÁNDEZ', 'LUNES A VIERNES DE 9:00 A 17:00 HRS.', 'ALLENDE No. 5, COL. CENTRO, ASUNCIÓN NOCHIXTLAN, OAXACA', '(951) 522 08 90', 'une@cyolomecatl.com', 'www.cooperativayolomecatl.com.mx', 1, 'OAXACA');
INSERT INTO responsable_une VALUES (1, 'Responsable UNE', 'Horario Lunes a Viernes', 'Domicilio', '000000000', 'correo@gmail.com', 'www.pagina.com', 0, NULL);
INSERT INTO responsable_une VALUES (5, 'RESPONSABLE UNE PRUEBA', 'HORARIO LUNES A VIERNES PRUEBA', 'DOMICILIO PRUEBA', '0000000001', '1correo@gmail.com', 'www.paginaprueba.com', 0, 'PRUEBA');

-- ----------------------------
-- Primary Key structure for table responsable_une
-- ----------------------------
ALTER TABLE responsable_une ADD CONSTRAINT responsable_une_pkey PRIMARY KEY (responsable_id);
