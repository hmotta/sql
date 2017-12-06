
alter table tipoprestamo drop  tipoprestamores;
alter table tipoprestamo add column  clasificacioncontable character(24);
alter table tipoprestamo add column  tipoprestamores character(3);


-- Verificar las cuentas de ingreso por otras recuperaciones
-- Verificar las cuentas de orden para manejo de cartera castigada.

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('7107','71',0,'CREDITOS CARTERA CASTIGADA','C',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('7207','72',0,'CREDITOS CARTERA CASTIGADA','C',' ','2008-01-01','2008-01-01','A',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('710701','7107',0,'CREDITOS CARTERA CASTIGADA','A',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('720701','7207',0,'CREDITOS CARTERA CASTIGADA','A',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('55','5',0,'OTROS INGRESOS POR CARTERA CASTIGADA','C',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('5501','55',0,'OTROS INGRESOS POR CARTERA CASTIGADA','C',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('550103','5501',0,'POR INTERES NORMAL DE CARTERA CASTIGADA','A',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('550104','5501',0,'POR INTERES MORA DE CARTERA CASTIGADA','A',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('550105','5501',0,'POR CAPITAL DE CARTERA CASTIGADA','A',' ','2008-01-01','2008-01-01','D',5,0,0,0);

insert into catalogo_ctas(cuentaid,cat_cuentaid,identificacion,cuentanombre,tipo_cta,estado_cta,fecha_estado,fecha_ult_mov,naturaleza,digito_agrupador,saldo_inic_ejer,cargos_acum_ejer,abonos_acum_ejer) values ('2306090102','23060901',0,'IVA DE CARTERA CASTIGADA','A',' ','2008-01-01','2008-01-01','D',5,0,0,0);


COPY tipoprestamo (tipoprestamoid, cuentaactivo, cuentaactivovencida, cuentaintnormal, cuentaintnormalvencida, cuentaintnormalnocob, cuentaintmora, cuentaintmoravencida, cuentaiva, cuentariesgocred, cuentaordeninteres, cuentaordenaval, tipomovimientoid, desctipoprestamo, tantos, tasa_normal, tasa_mora, aplicaivaprestamo, diastraspasoavencida, cuentaintdevnocobres, cuentariesgocredres, cuentaintmoranocobact, cuentaintmoradevnocobres, ordendeudornormalbonificado, ordenacredornormalbonificado, cuentafondorecuperacion, cuentagtosadm, cuentaintnormalresvencida, ordeninteresacreedor, calculonormalid, calculomoraid, clavefinalidad, cuentaintnormalresvigente, cuentaordenavalacredor, cuentagarantiadeudor, cuentagarantiaacredor, cuentaprovisioniva, montomaximo, plazomaximo, montominimo, avalesminimos, periododiasdefault, estatus, tipoprestamores, comision, ivacomision, cuentacomision, cuentaivacomision, nivelautorizacion, reciprocidad, prestamogrupal, clasificacioncontable) FROM stdin;
CAS 	710701                	720701                	550103                	550105                	99                	550104                	99                	2305090201                	99                	99                      	99                      	AA	CREDITOS CASTIGADOS        	0	34.959999	41.950001	S	89	99                	99                  	99                      	99                      	99                      	99                      	99                      	99                      	99                	99                      	1	2	002	99                	99                      	99                      	99                      	99                      	100000.000000	9000	1.000000	0	30	1	\N	\N	\N	\N	\N	\N	\N	0	\N
\.



