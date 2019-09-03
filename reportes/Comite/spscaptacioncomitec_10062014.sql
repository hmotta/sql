CREATE or replace FUNCTION spscaptacioncomitec(date) RETURNS SETOF tcaptacioncomite
    AS $_$
declare

  pfecha alias for $1;
  r tcaptacioncomite%rowtype;

  f record;

  dblink1 text;
  dblink2 text;

  i int;
begin

i:=1;

for f in
 select * from sucursales where vigente='S'
 
  loop

        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='set search_path to public,'||f.esquema||';select * from  spscaptacioncomite('||''''||pfecha||''''||');';

        --raise notice '% % ', dblink1,dblink2;

      for r in
        SELECT * FROM
          dblink(dblink1,dblink2) as
          t2(
	numero_de_socio character varying(18),
	nombre_de_socio character varying(80),
	no_contrato character varying(14),
	sucursal character varying(16),
	fecha_de_apertura character(10),
	tipo_de_deposito character varying(30),
	fecha_del_deposito character(10),
	fecha_de_vencimiento character varying(10),
	plazo_del_deposito_dias integer,
	forma_de_pago_de_rendimientos_dias character varying(10),
	tasa_de_interes_nominal_pactada_anual numeric,
	saldo_promedio_para_determinar_intereses_men numeric,
	monto_del_ahorro_o_deposito_plazo_capital numeric,
	int_dev_no_pag_al_cierre_del_mes_dep_a_plazo_acumulados numeric,
	sdo_total_al_cierre_mes_cap_mas_int_dev_no_pag_dep_a_plazo numeric,
	int_generados_en_el_mes_devengados_pagados_y_no_pagados_del_mes numeric)

        loop
            return next r;
        end loop;
  
  end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
