
drop table listanegra cascade; 
create table listanegra(
   listaid serial,
   cadena text,
   encontrado integer
 );

drop table tmplistanegra cascade; 
create table tmplistanegra(
   cadena text
);
