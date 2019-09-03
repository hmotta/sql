CREATE TABLE dictaminacredito
(
 dictaminaid 	      serial,
 solicitudprestamoid  integer REFERENCES solicitudprestamo(solicitudprestamoid),
 tipoprestamoid       character(3) REFERENCES tipoprestamo(tipoprestamoid),         
 reciprocidad         numeric, 
 partesocial          numeric,
 ahorrogarantia       numeric,             
 abonospropuestos     integer,                
 montoautorizado      numeric,               
 periodopagoid        integer,               
 fechaentrega         date,   
 primerpago            date, 
 tasanormal            numeric,
 tasamora              numeric,              
 dias_de_cobro        integer, 
 dia_mes_cobro        integer,           
 estatus               integer,
 garantias            text,
 condiciones           text,
 observaciones         text,
 fechadictaminacion    date,
 actano               integer, 
 rangoid               integer     REFERENCES rangoautorizacion(rangoid),
 vigencia              date,
 periodogracia         integer,
 pagointeres           integer,
 ahorrocompromiso      numeric,
  PRIMARY KEY (dictaminaid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE dictaminacredito
  OWNER TO postgres;
  
  
