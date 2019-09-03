drop table chsalvobuencobro;
CREATE   TABLE chsalvobuencobro
(
  chequeid integer NOT NULL,
  socioid integer NOT NULL references socio (socioid),
  banco character varying(20),
  identificacion character varying(20),
  numeroidentificacion character varying(15),
  numerocheque integer,
  monto  numeric,
  beneficiario character varying(60),
  seriecajero character varying(2),
  pagado character,
  fecha date,
  instrucciones character varying(200)
  
 
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE chsalvobuencobro                                     
  OWNER TO postgres;
