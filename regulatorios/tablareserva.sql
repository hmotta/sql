update precorte set tipocartera=NULL,tablareservaid=NULL;
delete from tablareserva;
insert into tablareserva values(1,'0 Dias',-1,0,0.01,1,'002',0.01,10,852001010100);
insert into tablareserva values(2,'1-7 Dias',1,7,0.02,1,'002',0.02,10,852001010200);
insert into tablareserva values(3,'8-30 Dias',8,30,0.1,1,'002',0.1,10,852001010300);
insert into tablareserva values(4,'31-60 Dias',31,60,0.2,1,'002',0.2,10,852001010400);
insert into tablareserva values(5,'61-90 Dias',61,90,0.4,1,'002',0.4,10,852001010500);
insert into tablareserva values(6,'91-120 Dias',91,120,0.7,1,'002',0.7,10,852001010600);
insert into tablareserva values(7,'121-180 Dias',121,180,0.85,1,'002',0.85,10,852001010700);
insert into tablareserva values(8,'Mas de 180',181,1000000,1,1,'002',1,10,852001010800);
insert into tablareserva values(9,'0 Dias',-1,0,0.1,1,'002',0.1,11,852001010100);
insert into tablareserva values(10,'1-7 Dias',1,7,0.13,1,'002',0.13,11,852001010200);
insert into tablareserva values(11,'8-30 Dias',8,30,0.2,1,'002',0.2,11,852001010300);
insert into tablareserva values(12,'31-60 Dias',31,60,0.35,1,'002',0.35,11,852001010400);
insert into tablareserva values(13,'61-90 Dias',61,90,0.55,1,'002',0.55,11,852001010500);
insert into tablareserva values(14,'91-120 Dias',91,120,0.8,1,'002',0.8,11,852001010600);
insert into tablareserva values(15,'121-180 Dias',121,180,0.95,1,'002',0.95,11,852001010700);
insert into tablareserva values(16,'Mas de 1460',181,1000000,1,1,'002',1,11,852001010800);
insert into tablareserva values(17,'0 Dias',-1,0,0.0035,1,'002',0.0035,12,852001020100);
insert into tablareserva values(18,'1-30 Dias',1,30,0.0105,1,'002',0.0105,12,852001020200);
insert into tablareserva values(19,'31-60 Dias',31,60,0.0245,1,'002',0.0245,12,852001020300);
insert into tablareserva values(20,'61-90 Dias',61,90,0.0875,1,'002',0.0875,12,852001020400);
insert into tablareserva values(21,'61-90 Dias',61,90,0.175,1,'002',0.175,12,852001020500);
insert into tablareserva values(22,'91-120 Dias',91,120,0.3325,1,'002',0.3325,12,852001020600);
insert into tablareserva values(23,'121-150 Dias',151,180,0.343,1,'002',0.343,12,852001020700);
insert into tablareserva values(24,'181-1460 Dias',181,1460,0.7,1,'002',0.7,12,852001020800);
insert into tablareserva values(25,'Mas de 1460',1460,1000000,1,1,'002',1,12,852001020800);
insert into tablareserva values(26,'0 dias',-1,0,0.005,1,'001',0.005,13,852002010100);
insert into tablareserva values(27,'1 a 30 dias',1,30,0.025,1,'001',0.025,13,852002010200);
insert into tablareserva values(28,'31 a 60 dias',31,60,0.15,1,'001',0.15,13,852002010300);
insert into tablareserva values(29,'61 a 90 dias',61,90,0.3,1,'001',0.3,13,852002010400);
insert into tablareserva values(30,'91 a 120 dias',91,120,0.4,1,'001',0.4,13,852002010500);
insert into tablareserva values(31,'121 a 150 dias',121,150,0.6,1,'001',0.6,13,852002010600);
insert into tablareserva values(32,'151 a 180 dias',151,180,0.75,1,'001',0.75,13,852002010700);
insert into tablareserva values(33,'181 a 210 dias',181,210,0.85,1,'001',0.85,13,852002010800);
insert into tablareserva values(34,'211 a 240 dias',211,240,0.95,1,'001',0.95,13,852002010900);
insert into tablareserva values(35,'Mas de 240 dia',241,1000000,1,1,'001',1,13,852002011000);
