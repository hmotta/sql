--DROP TABLE cat_cuentas_tipoprestamo;
CREATE TABLE cat_cuentas_tipoprestamo(
  cat_cuentasid serial NOT NULL,
  tipoprestamoid char(3) NOT NULL references tipoprestamo(tipoprestamoid),
  clavefinalidad char(3) NOT NULL references cat_finalidad_contable(clavefinalidad),
  renovado int4 not null,
  
  --Capital
  cta_cap_vig char(24) references catalogo_ctas(cuentaid), --antes cuentaactivo - Cuenta contable de ACTIVO para  registrar/acumular el CAPITAL VIGENTE (CAJA)
  cta_cap_ven char(24) references catalogo_ctas(cuentaid), --antes cuentaactivovencida - Cuenta contable de ACTIVO para registrar/acumular el CAPITAL VENCIDO
  
  --Int. Ordinario vigente
  cta_int_vig_balance char(24) references catalogo_ctas(cuentaid), --antes cuentaintdevnocobres - Cuenta contable de ACTIVO para registrar/acumular el INTERES NORMAL VIGENTE COBRADO
  cta_int_vig_resultados char(24) references catalogo_ctas(cuentaid), --antes cuentaintnormal  - Cuenta contable de INGRESOS (RESULTADO) para registrar/acumular el INTERES NORMAL VIGENTE COBRADO (CAJA)
  cta_int_vig_dev_nocob_resultados char(24) references catalogo_ctas(cuentaid), --antes cuentaintnormalnocob  - Cuenta contable de INGRESOS para registrar/acumular el INTERES DEVENGADO NO COBRADO VIGENTE
  
  --Int. Ordinario vencido
  cta_int_ven_balance char(24) references catalogo_ctas(cuentaid), --antes cuentaintnormalvencida - Cuenta contable de ACTIVO para registrar/acumular el INTERES VENCIDO
  cta_int_ven_resultados char(24) references catalogo_ctas(cuentaid), --antes cuentaintnormalresvencida - Cuenta contable de INGRESOS para registrar/acumular el INTERES NORMAL VENCIDO COBRADO
  cta_int_ven_dev_nocob_resultados char(24) references catalogo_ctas(cuentaid), --antes cuentaintnormalresvigente - Cuenta contable de INGRESOS para registrar/acumular el INTERES NORMAL VENCIDO COBRADO
  cta_int_ven_orden_deudora char(24) references catalogo_ctas(cuentaid), --antes cuentaordeninteres  - Cuenta contable  de ORDEN (DEUDORA) para registrar/acumular el INT. DEV. NO COB VENCIDO
  cta_int_ven_orden_acreedora char(24) references catalogo_ctas(cuentaid), --antes ordeninteresacreedor - Cuenta contable  de ORDEN (ACREEDORA) para registrar/acumular el INT. DEV. NO COB VENCIDO
  
  --Int. Moratorio vigente
  cta_mora_vig_balance char(24) references catalogo_ctas(cuentaid), --antes moravigentebalance - Cuenta contable de ACTIVO para registrar/acumular el INTERES MORATORIO VIGENTE (CIERRE)
  cta_mora_vig_resultados char(24) references catalogo_ctas(cuentaid), --antes cuentaintmora  - Cuenta contable de INGRESOS para registrar/acumular el INTERES MORATORIO COBRADO (CAJA)  
  cta_mora_vig_dev_nocob_resultados char(24) references catalogo_ctas(cuentaid), --antes moravigenteresultado - Cuenta contable de INGRESOS (RESULTADO) para registrar/acumular el INTERES MORATORIO VIGENTE NO COB (CIERRE)  
  
  --Int. Moratorio vencido
  cta_mora_ven_balance char(24) references catalogo_ctas(cuentaid), --antes moravencidobalance - Cuenta contable de ACTIVO para registrar/acumular el INTERES MORATORIO VENCIDO (CIERRE)
  cta_mora_ven_resultados char(24) references catalogo_ctas(cuentaid), --antes cuentaintmoravencida - Cuenta contable de INGRESOS para registrar/acumular el INTERES MORATORIO COB DE CAR VENCIDA
  cta_mora_ven_dev_nocob_resultados char(24) references catalogo_ctas(cuentaid), --antes moravencidoresultado - Cuenta contable de INGRESOS (RESULTADO) para registrar/acumular el INTERES MORATORIO VENCIDO NO COB (CIERRE)
  cta_mora_ven_orden_deudora char(24) references catalogo_ctas(cuentaid), --antes moractaordendeudora - Cuenta contable  de ORDEN (DEUDORA) para registrar/acumular el INT MORA NO COB VEN (CIERRE)
  cta_mora_ven_orden_acreedora char(24) references catalogo_ctas(cuentaid), --antes moractaordenacredora - - Cuenta contable  de ORDEN (ACREEDORA) para registrar/acumular el INT MORA NO COB VEN (CIERRE)
    
  --Iva
  cta_iva char(24) references catalogo_ctas(cuentaid), --antes cuentaiva - Cuenta contable de IVA para registrar/acumular el IVA COBRADO
  cta_iva_comision char(24) references catalogo_ctas(cuentaid),  --antes cuentaivacomision -  Cuenta contable  para registrar/acumular el IVA de la comision
  
  --Otros
  cta_comision char(24) references catalogo_ctas(cuentaid), --antes cuentacomision -  Cuenta contable  de INGRESOS (COMISIONES Y TARIFAS COBRADAS) para registrar/acumular la comision en su caso
    
  --Estimación
  cta_estimacion char(24) references catalogo_ctas(cuentaid), --antes cuentariesgocred  - Cuenta contable de ACTIVO  para registrar/acumular el LA ESTIMACION DEL CREDITO
  cta_estimacion_resultados char(24) references catalogo_ctas(cuentaid), --antes cuentariesgocredres -  Cuenta contable de MARGEN FINANCIERO (RESULTADO) para registrar/acumular el LA ESTIMACION DEL CREDITO
  
  --Cuentas de orden para Bonificaciones
  cta_int_bonifica_orden_deudora char(24) references catalogo_ctas(cuentaid), --antes no existia, se metia manual la cuenta en codigo de siof
  cta_int_bonifica_orden_acreedora char(24) references catalogo_ctas(cuentaid), --
  cta_mor_bonifica_orden_deudora char(24) references catalogo_ctas(cuentaid), --
  cta_mor_bonifica_orden_acreedora char(24) references catalogo_ctas(cuentaid), --
  
  --Cuentas de orden para Castigos
  cta_int_castigo_orden_deudora char(24) references catalogo_ctas(cuentaid), --antes ordendeudornormalbonificado
  cta_int_castigo_orden_acreedora char(24) references catalogo_ctas(cuentaid), --antes ordenacredornormalbonificado
  cta_mor_castigo_orden_deudora char(24) references catalogo_ctas(cuentaid), --antes cuentaintmoranocobact -  Cuenta contable  de ORDEN (DEUDORA) para registrar/acumular EL INTERES MORATORIO EN CASTIGOS DE CARTERA
  cta_mor_castigo_orden_acreedora char(24) references catalogo_ctas(cuentaid), --antes cuentaintmoradevnocobres -  -  Cuenta contable  de ORDEN (ACREEDORA) para registrar/acumular los CASTIGOS DE CARTERA
  
  --Cuentas de orden para disposicion de creditos revolventes
  cta_disp_rev_orden_deudora char(24) references catalogo_ctas(cuentaid),
  cta_disp_rev_orden_acreedora char(24) references catalogo_ctas(cuentaid),
  
  clasificacioncontable char(24),
  PRIMARY KEY (cat_cuentasid),
  UNIQUE (tipoprestamoid,clavefinalidad,renovado)
);

