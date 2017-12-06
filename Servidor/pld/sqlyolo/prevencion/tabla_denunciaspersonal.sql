CREATE TABLE denunciaspersonal (
    id serial,
    texto text,
    fechaalta timestamp without time zone DEFAULT now(),
    usuarioid_reporta character(20),
    usuarioid_reportado character(20),
    persona_que_reporta character(300),
    estatus integer DEFAULT 0,
    observacionesoficial text,
    datosoficial text
);
