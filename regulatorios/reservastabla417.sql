
alter table precorte add tipocartera char(2);
update precorte set tablareservaid =null;
update precorte set tipocartera='11' where finalidaddefault='002';
update precorte set tipocartera='13' where finalidaddefault='001';
update precorte set tipocartera='17' where finalidaddefault='003';

alter table tablareserva add porcentajereservaidnc numeric;
alter table tablareserva add  tipocartera char(2);
alter table tablareserva add  cuentasiti char(24);
delete from tablareserva;

COPY tablareserva (tablareservaid, descripcion, diainicial, diafinal, porcentajereserva, factordisminucion, finalidaddefault) FROM stdin;
1	0   Dias	-1	0	0.01	0.34	002
2	1-7 Dias 	1	7	0.04	0.34	002
3	8-30 Dias 	8	30	0.15	0.34	002
4	31-60 Dias 	31	60	0.30	0.34	002
5	61-90 Dias 	61	90	0.50	0.34	002
6	91-120 Dias 	91	120	0.75	0.34	002
7	121-180 Dias	121	180	0.90	0.34	002
8	Mas de 180	181	10000	1.00	0.34	002
9	0   Dias	-1	0	0.01	0.34	002
10	1-7 Dias 	1	7	0.01	0.34	002
11	8-30 Dias 	8	30	0.04	0.34	002
12	31-60 Dias 	31	60	0.30	0.34	002
13	61-90 Dias 	61	90	0.60	0.34	002
14	91-120 Dias 	91	120	0.80	0.34	002
15	121-180 Dias	121	180	0.90	0.34	002
16	Mas de 180	181	10000	1.00	0.34	002
17	0 dias  	-1	0	0.005	0.34	001
18	1 a 30 dias  	1	30	0.025	0.34	001
19	31 a 60 dias	31	60	0.15	0.34	001
20	61 a 90 dias	61	90	0.30	0.34	001
21	91 a 120 dias	91	120	0.40	0.34	001
22	121 a 150 dias	121	150	0.60	0.34	001
23	151 a 180 dias	151	180	0.75	0.34	001
24	181 a 210 dias	181	210	0.85	0.34	001
25	211 a 240 dias	211	240	0.95	0.34	001
26	Mas de 240 dia	241	10000	1.00	0.34	001
27	0 dias  	-1	0	0.10	0.34	001
28	1 a 30 dias  	1	30	0.10	0.34	001
29	31 a 60 dias	31	60	0.30	0.34	001
30	61 a 90 dias	61	90	0.40	0.34	001
31	91 a 120 dias	91	120	0.50	0.34	001
32	121 a 150 dias	121	150	0.70	0.34	001
33	151 a 180 dias	151	180	0.95	0.34	001
34	181 a 210 dias	181	210	1.00	0.34	001
35	211 a 240 dias	211	240	1.00	0.34	001
36	Mas de 240 dia	241	10000	1.00	0.34	001
37	0-7 Dias	-1	7	0.01	0.34	001
38	8-30 Dias 	8	30	0.05	0.34	001
39	31-60 Dias 	31	60	0.20	0.34	001
40	61-90 Dias 	61	90	0.40	0.34	001
41	91-120 Dias 	91	120	0.70	0.34	001
42	Mas 120 Dias 	120	10000	1.00	0.34	001
43	0-7 Dias	-1	7	0.01	0.34	001
44	8-30 Dias 	8	30	0.025	0.34	001
45	31-60 Dias 	31	60	0.20	0.34	001
46	61-90 Dias 	61	90	0.50	0.34	001
47	91-120 Dias 	91	120	0.80	0.34	001
48	Mas 120 Dias 	120	10000	1.00	0.34	001
49	0   Dias	-1	0	0.0035	0.34	003
50	1-30 Dias 	1	30	0.0105	0.34	003
51	31-60 Dias 	31	60	0.0245	0.34	003
52	61-90 Dias 	61	90	0.0875	0.34	003
53	91-120 Dias 	91	120	0.175	0.34	003
54	121-150 Dias 	121	150	0.3325	0.34	003
55	151-180 Dias	151	180	0.3430	0.34	003
56	181-1460 Dias	181	1460	0.70	0.34	003
57	Mas de 1460	1461	10000	1.00	0.34	003
\.

update tablareserva set tipocartera='11' where tablareservaid <=  8;
update tablareserva set cuentasiti='852001010100' where tablareservaid=1;
update tablareserva set cuentasiti='852001010200' where tablareservaid=2;
update tablareserva set cuentasiti='852001010300' where tablareservaid=3;
update tablareserva set cuentasiti='852001010400' where tablareservaid=4;
update tablareserva set cuentasiti='852001010500' where tablareservaid=5;
update tablareserva set cuentasiti='852001010600' where tablareservaid=6;
update tablareserva set cuentasiti='852001010700' where tablareservaid=7;
update tablareserva set cuentasiti='852001010800' where tablareservaid=8;

update tablareserva set tipocartera='12' where tablareservaid >8 and tablareservaid <= 16;
update tablareserva set cuentasiti='852001020100' where tablareservaid=9;
update tablareserva set cuentasiti='852001020200' where tablareservaid=10;
update tablareserva set cuentasiti='852001020300' where tablareservaid=11;
update tablareserva set cuentasiti='852001020400' where tablareservaid=12;
update tablareserva set cuentasiti='852001020500' where tablareservaid=13;
update tablareserva set cuentasiti='852001020600' where tablareservaid=14;
update tablareserva set cuentasiti='852001020700' where tablareservaid=15;
update tablareserva set cuentasiti='852001020800' where tablareservaid=16;

update tablareserva set tipocartera='13' where tablareservaid >16 and tablareservaid <= 26;
update tablareserva set cuentasiti='852002010100' where tablareservaid=17;
update tablareserva set cuentasiti='852002010200' where tablareservaid=18;
update tablareserva set cuentasiti='852002010300' where tablareservaid=19;
update tablareserva set cuentasiti='852002010400' where tablareservaid=20;
update tablareserva set cuentasiti='852002010500' where tablareservaid=21;
update tablareserva set cuentasiti='852002010600' where tablareservaid=22;
update tablareserva set cuentasiti='852002010700' where tablareservaid=23;
update tablareserva set cuentasiti='852002010800' where tablareservaid=24;
update tablareserva set cuentasiti='852002010900' where tablareservaid=25;
update tablareserva set cuentasiti='852002011000' where tablareservaid=26;

update tablareserva set tipocartera='14' where tablareservaid >26 and tablareservaid <= 36;
update tablareserva set cuentasiti='852002020100' where tablareservaid=27;
update tablareserva set cuentasiti='852002020200' where tablareservaid=28;
update tablareserva set cuentasiti='852002020300' where tablareservaid=29;
update tablareserva set cuentasiti='852002020400' where tablareservaid=30;
update tablareserva set cuentasiti='852002020500' where tablareservaid=31;
update tablareserva set cuentasiti='852002020600' where tablareservaid=32;
update tablareserva set cuentasiti='852002020700' where tablareservaid=33;
update tablareserva set cuentasiti='852002020800' where tablareservaid=34;
update tablareserva set cuentasiti='852002020900' where tablareservaid=35;
update tablareserva set cuentasiti='852002021000' where tablareservaid=36;


update tablareserva set tipocartera='15' where tablareservaid >36 and tablareservaid <= 42;
update tablareserva set cuentasiti='852002030100' where tablareservaid=37;
update tablareserva set cuentasiti='852002030200' where tablareservaid=38;
update tablareserva set cuentasiti='852002030300' where tablareservaid=39;
update tablareserva set cuentasiti='852002030400' where tablareservaid=40;
update tablareserva set cuentasiti='852002030500' where tablareservaid=41;
update tablareserva set cuentasiti='852002030600' where tablareservaid=42;

update tablareserva set tipocartera='16' where tablareservaid >42 and tablareservaid <= 48;
update tablareserva set cuentasiti='852002040100' where tablareservaid=43;
update tablareserva set cuentasiti='852002040200' where tablareservaid=44;
update tablareserva set cuentasiti='852002040300' where tablareservaid=45;
update tablareserva set cuentasiti='852002040400' where tablareservaid=46;
update tablareserva set cuentasiti='852002040500' where tablareservaid=47;
update tablareserva set cuentasiti='852002040600' where tablareservaid=48;

update tablareserva set tipocartera='17' where tablareservaid >48 and tablareservaid <= 57;
update tablareserva set cuentasiti='852003010000' where tablareservaid=49;
update tablareserva set cuentasiti='852003020000' where tablareservaid=50;
update tablareserva set cuentasiti='852003030000' where tablareservaid=51;
update tablareserva set cuentasiti='852003040000' where tablareservaid=52;
update tablareserva set cuentasiti='852003050000' where tablareservaid=53;
update tablareserva set cuentasiti='852003060000' where tablareservaid=54;
update tablareserva set cuentasiti='852003070000' where tablareservaid=55;
update tablareserva set cuentasiti='852003080000' where tablareservaid=56;
update tablareserva set cuentasiti='852003090000' where tablareservaid=57;


update tablareserva set factordisminucion=1;
update tablareserva set porcentajereservaidnc= porcentajereserva;
update tablareserva set porcentajereservaidnc= 1 where diainicial >90;
update precorte set depositogarantia=0 where depositogarantia is null;


CREATE or replace FUNCTION aplicareserva() RETURNS numeric AS ' 
DECLARE

r record;

BEGIN

  for r in
     select p.precorteid,t.porcentajereserva,
            ((p.saldoprestamo-p.depositogarantia)*t.porcentajereserva) as reservacalculada,
            (p.interesdevengadomenoravencido+p.interesdevmormenor)*t.porcentajereservaidnc as reservaidnc,
            t.factordisminucion,t.tablareservaid,p.prestamoid,
            p.diasvencidos,p.finalidaddefault
       from precorte p, tablareserva t
      where p.finalidaddefault=t.finalidaddefault and p.tipocartera=t.tipocartera and  p.diasvencidos>=t.diainicial and p.diasvencidos<=t.diafinal

   loop

        update precorte set tablareservaid = r.tablareservaid,
            porcentajeaplicado=r.porcentajereserva,
            reservacalculada=r.reservacalculada,
            reservaidnc=r.reservaidnc,
            factoraplicado=r.factordisminucion
        where precorteid=r.precorteid;

        raise notice '' Prestamoid % '',r.precorteid;

   end loop;
       
RETURN 1; 
END; 
' LANGUAGE 'plpgsql' security definer;

select * from aplicareserva();

update precorte set factoraplicado=(select porcentaje/100  from porcreserva where precorte.fechacierre >= fechainicial and precorte.fechacierre <= fechafinal);


