
drop table perfiltransaccional cascade; 
create table perfiltransaccional(
   perfiltransaccionalid serial,
   fechahora    timestamp without time zone DEFAULT now(),
   socioid      integer,
   referencia   integer,
   serie        char(2),
   valorderiego numeric,
   tipoderiesgoid   char(2),
   tipomovimientoid char(2),
   valorefectivo    numeric,
   valordocumentos  numeric,
   observaciones text
 );

