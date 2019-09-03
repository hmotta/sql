alter table operaciones_detectadas_pld add column "estatus" varchar(50) DEFAULT 'NUEVA'::character varying;
alter table operaciones_detectadas_pld add column "descripcion_operacion" varchar(255);
alter table operaciones_detectadas_pld add column "razones_operacion" varchar(255);
alter table operaciones_detectadas_pld add column "tipo_transaccion" int4;
alter table operaciones_detectadas_pld add column "instrumento_monetario" int4;
alter table operaciones_detectadas_pld add column "comentarios_oc" varchar(255);
alter table operaciones_detectadas_pld add column "parametroid" varchar(3) references parametros_pld (parametroid);