
insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('61010802','610108',5,'COMISION CONSULTA BURO CREDITO','A',' ','2008-01-01','2008-01-01','A',0,0,0,0);

update catalogo_ctas set cuentanombre='COMISION CONSULTA BURO CREDITO' where cuentaid='61010802';

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('2305090401','23050904',1,'IVA CONSULTA BURO CREDITO','A',' ','2008-01-01','2008-01-01','A',0,0,0,0);

update catalogo_ctas set cuentanombre='IVA CONSULTA BURO CREDITO' where cuentaid='2305090401';


delete from tipomovimiento where tipomovimientoid ='BU';

COPY tipomovimiento (tipomovimientoid, cuentadeposito, cuentaretiro, cuentaintpagado, cuentaintcobrado, cuentaivamovimiento, cuentaisr, desctipomovimiento, aplicasaldo, tipopoliza, aceptadeposito, aceptaretiro, tasainteres, cuentaordenacredor, cuentaordendeudor, cuentaorden, cuentaprovisionisr) FROM stdin;
BU	61010802                	61010802                	99                      	99                      	99                      	99                      	COMISION BURO CREDITO                 	S	J	S	S	0.000000	99                      	99                      	N	99                      
\.

update tipomovimiento set comision=0,porcomision=0,porivacomision=16,cuentacomision ='61010802',cuentaivacomision='2305090401',aplicasaldo='N',desglosaiva=1 where tipomovimientoid='BU';

update tipomovimiento set cuentadeposito=61010802,cuentaretiro=61010802 where tipomovimientoid='BU';

