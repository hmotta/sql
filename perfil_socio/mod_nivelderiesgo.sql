
CREATE SEQUENCE "public"."nivelderiesgo_nivelderiesgo_seq" 
INCREMENT 1
START 1;

SELECT setval('"public"."nivelderiesgo_nivelderiesgo_seq"', 3, false);

ALTER TABLE "public"."nivelderiesgo" 
  ALTER COLUMN "nivelderiesgo" SET DEFAULT nextval('nivelderiesgo_nivelderiesgo_seq'::regclass);