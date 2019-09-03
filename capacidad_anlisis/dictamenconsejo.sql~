CREATE TABLE dictamenconsejo
(
 dictamenid 	      serial,
 dictaminaid  integer REFERENCES dictaminacredito(dictaminaid),
 fechadictamen        date,
 acuerdo              character varying(15),
 motivodictamen       integer,
 PRIMARY KEY (dictamenid)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE dictamenconsejo
  OWNER TO postgres;
  
  
