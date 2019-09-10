

-- ----------------------------
-- Table structure for cat_respuestas_matriz
-- ----------------------------
DROP TABLE IF EXISTS cat_respuestas_matriz;
CREATE TABLE cat_respuestas_matriz (
  catalogoid int4 NOT NULL DEFAULT nextval('cat_respuestas_matriz_catalogoid_seq'::regclass),
  preguntaid int4 NOT NULL,
  descripcion_respuesta varchar(255) COLLATE pg_catalog.default,
  valor_respuesta_minimo numeric(255),
  valor_respuesta_maximo numeric(255),
  nivelriesgoid int4 NOT NULL
)
;

-- ----------------------------
-- Primary Key structure for table cat_respuestas_matriz
-- ----------------------------
ALTER TABLE cat_respuestas_matriz ADD CONSTRAINT cat_respuestas_matriz_pkey PRIMARY KEY (catalogoid);

-- ----------------------------
-- Foreign Keys structure for table cat_respuestas_matriz
-- ----------------------------
ALTER TABLE cat_respuestas_matriz ADD CONSTRAINT cat_respuestas_matriz_nivelriesgoid_fkey FOREIGN KEY (nivelriesgoid) REFERENCES nivelderiesgo (nivelderiesgo) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE cat_respuestas_matriz ADD CONSTRAINT cat_respuestas_matriz_preguntaid_fkey FOREIGN KEY (preguntaid) REFERENCES preguntasmatrizriesgo (preguntaid) ON DELETE NO ACTION ON UPDATE NO ACTION;
