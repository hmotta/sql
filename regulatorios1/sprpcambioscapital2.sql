-- Function: sprpcambioscapital2(integer, integer, integer, integer)

-- DROP FUNCTION sprpcambioscapital2(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sprpcambioscapital2(integer, integer, integer, integer)
  RETURNS SETOF rrpcambios AS
$BODY$
declare

  pejercicio   alias for $1;
  pperiodo     alias for $2;
  pconsolidado alias for $3;
  pmiles       alias for $4;

  sconsolida char(1);
  r rrpcambios%rowtype;

  daytab numeric[2][13]:=array[[31,28,31,30,31,30,31,31,30,31,30,31,31],
                               [31,29,31,30,31,30,31,31,30,31,30,31,31]];
  mestab varchar[13]:=array['ENERO','FEBRERO','MARZO',
                            'ABRIL','MAYO','JUNIO',
                            'JULIO','AGOSTO','SEPTIEMBRE',
                            'OCTUBRE','NOVIEMBRE','DICIEMBRE',
                            'DICIEMBRE'];

  fpaincompleta numeric;
  pfecha date;

  fresultadoneto numeric;

  saldofinalcs2011 numeric;
  saldofinald2011 numeric;
  ejeranteriores2011 numeric;
  resneto numeric;
  susccapsoc numeric;
  efectoincor numeric;
  pfechaa date;

  constreser numeric;
  capitexce numeric;
  efecreexp numeric;

begin

 select cast(to_char(pejercicio,'9999')||'-'||trim(to_char(pperiodo,'99'))||'-'||trim(to_char(daytab[1][pperiodo],'99')) as date)
    into pfecha;

  raise notice 'Fecha %',pfecha;

pfechaa := pfecha-cast(daytab[1][pperiodo] as int);

raise notice 'Fecha 2 %',pfechaa;

  if pconsolidado=1 then
    sconsolida:='S';
  else
    sconsolida:='N';
  end if;

--obtener resultados finales de saldos 2011
select sum(saldo_inic_ejer+cargos_acum_ejer-abonos_acum_ejer) into saldofinalcs2011 from consolidabalanza(2011,12) where cuentaid='410101';
select sum(saldo_inic_ejer+cargos_acum_ejer-abonos_acum_ejer) into saldofinald2011 from consolidabalanza(2011,12) where cuentaid='4106';
select sum(saldo_inic_ejer+cargos_acum_ejer-abonos_acum_ejer) into ejeranteriores2011 from consolidabalanza(2011,12) where cuentaid='4202';
select sum(saldo_inic_ejer+cargos_acum_ejer-abonos_acum_ejer) into resneto from consolidabalanza(2012,1) where cuentaid='42020111';

select sum(saldo_inic_ejer+cargos_acum_ejer-abonos_acum_ejer) into susccapsoc from consolidabalanza(pejercicio,pperiodo) where cuentaid='4101';

select sum(saldo_inic_ejer+cargos_acum_ejer-abonos_acum_ejer) into capitexce from consolidabalanza(pejercicio,pperiodo) where cuentaid='4106';

    if pmiles=1 then
      saldofinalcs2011:=round(saldofinalcs2011,-3)/1000;
    end if;

    if pmiles=1 then
      saldofinald2011:=round(saldofinald2011,-3)/1000;
    end if;

    if pmiles=1 then
      ejeranteriores2011:=round(ejeranteriores2011,-3)/1000;
    end if;

    if pmiles=1 then
      resneto:=round(resneto,-3)/1000;
    end if;

    if pmiles=1 then
      susccapsoc:=round(susccapsoc,-3)/1000;
    end if;

    if pmiles=1 then
      capitexce:=round(capitexce,-3)/1000;
    end if;

    fresultadoneto:=abs(saldocuenta('5  ',pejercicio,pperiodo,sconsolida))-
                    abs(saldocuenta('6  ',pejercicio,pperiodo,sconsolida));

    if pmiles=1 then
      fresultadoneto:=round(fresultadoneto,-3)/1000;
    end if;


-- efectos de reexpresion con resultados de ejercicios anteriores
    efecreexp:=abs(saldocuenta('4202  ',pejercicio,pperiodo,sconsolida))-
                    abs(saldocuenta('42020111  ',pejercicio,pperiodo,sconsolida));

--Queda fijo este codigo, para que jale el saldo del mes de diciembre 2011
  r.rubro1:='Saldo al 1 de DICIEMBRE DE 2011';
  r.t1:=(-1)*(saldofinalcs2011);
  r.t2:='0';
  r.t3:=(-1)*(saldofinald2011);
  r.t4:='0';
  r.t5:=(ejeranteriores2011);
  r.t6:='0';
  r.t7:='0';
  r.t8:=(-1)*(resneto);
  r.t9:=(-1)*saldofinalcs2011+(-1)*saldofinald2011+ejeranteriores2011+(-1)*resneto;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='MOVIMIENTOS INHERENTES A LAS DECISIONES DE';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='LOS SOCIOS';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;


  r.rubro1:='Suscripcion de certificados de aportacion';
  r.t1:=(-1)*(((-1)*(saldofinalcs2011))-((-1)*susccapsoc));
  r.t2:='0';
  r.t3:='0';
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:='0';
  r.t9:= (-1)*(((-1)*(saldofinalcs2011))-((-1)*susccapsoc));
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='Capitalizacion de excedentes';
  r.t1:='0';
  r.t2:='0';
  r.t3:=capitexce;
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:='0';
  r.t9:=capitexce;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;


  r.rubro1:='Constitucion de reservas';
  r.t1:='0';
  r.t2:='0';
  r.t3:='0';
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:=resneto;
  r.t9:=resneto;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='Traspaso del resultado neto a resultado de ejercicios anteriores';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;


  r.rubro1:='Distribucion de excedentes';
  r.t1:='0';
  r.t2:='0';
  r.t3:='0';
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:='0';
  r.t9:='0';
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;


  r.rubro1:='';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='Total';
  r.t1:=(-1)*(((-1)*(saldofinalcs2011))-((-1)*susccapsoc));
  r.t2:='0';
  r.t3:=saldofinald2011;
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:=resneto;
  r.t9:=(-1)*(((-1)*(saldofinalcs2011))-((-1)*susccapsoc))+saldofinald2011+resneto;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;


  r.rubro1:='';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

-- Efecto por incorporacion al regimen de sociedades cooperativas de ahorro y prestamo
    efectoincor:=(-1*saldocuenta('4107  ',pejercicio,pperiodo,sconsolida));
    if pmiles=1 then
    efectoincor:=round(efectoincor,-3)/1000;
    end if;


  r.rubro1:='MOVIMIENTOS INHERENTES AL RECONOCIMIENTO';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='DE LA UTILIDAD INTEGRAL';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='Utilidad Integral';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='-Resultado neto';
  r.t1:='0';
  r.t2:='0';
  r.t3:='0';
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:=fresultadoneto;
  r.t9:=fresultadoneto;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='-Resultado por valuacion de titulos disponibles para la venta';
  r.t1:='0';
  r.t2:='0';
  r.t3:='0';
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:='0';
  r.t9:='0';
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;


  r.rubro1:='-Resultado por tenencia de activos no monetarios';
  r.t1:='0';
  r.t2:='0';
  r.t3:='0';
  r.t4:='0';
  r.t5:='0';
  r.t6:='0';
  r.t7:='0';
  r.t8:='0';
  r.t9:='0';
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='Efectos de reexpresion';
  r.t1:='0';
  r.t2:=efectoincor;
  r.t3:='0';
  r.t4:='0';
  r.t5:=efecreexp;
  r.t6:='0';
  r.t7:='0';
  r.t8:='0';
  r.t9:=((efectoincor)-(-1)*(efecreexp));
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;


  r.rubro1:='';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='Total';
  r.t1:='0';
  r.t2:=efectoincor;
  r.t3:='0';
  r.t4:='0';
  r.t5:=ejeranteriores2011;
  r.t6:='0';
  r.t7:='0';
  r.t8:=fresultadoneto;
  r.t9:=(((efectoincor)-(-1)*(ejeranteriores2011))-(-1)*(fresultadoneto));
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='';
  r.t1:=NULL;
  r.t2:=NULL;
  r.t3:=NULL;
  r.t4:=NULL;
  r.t5:=NULL;
  r.t6:=NULL;
  r.t7:=NULL;
  r.t8:=NULL;
  r.t9:=NULL;
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;
  return next r;

  r.rubro1:='Saldo al '||to_char(daytab[1][pperiodo],'99')||' de '||mestab[pperiodo]||' DE'||to_char(pejercicio,'9999');

  r.t1:=((-1)*(saldofinalcs2011))+((-1)*(((-1)*(saldofinalcs2011))-((-1)*susccapsoc)));
  r.t2:=efectoincor;
  r.t3:=((-1)*(saldofinald2011))+saldofinald2011;
  r.t4:='0';
  r.t5:=ejeranteriores2011+ejeranteriores2011;
  r.t6:='0';
  r.t7:='0';
  r.t8:=((-1)*(resneto))+resneto+fresultadoneto;
  r.t9:=((-1)*saldofinalcs2011+(-1)*saldofinald2011+ejeranteriores2011+(-1)*resneto)+((-1)*(((-1)*(saldofinalcs2011))-((-1)*susccapsoc))+saldofinald2011+resneto)+((((efectoincor)-(-1)*(ejeranteriores2011))-(-1)*(fresultadoneto)));
  r.t10:=NULL;
  r.t11:=NULL;
  r.t12:=NULL;
  r.t13:=NULL;
  r.t14:=NULL;
  r.t15:=NULL;
  r.t16:=NULL;
  r.t17:=NULL;
  r.t18:=NULL;

 
  return next r;

return;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
ALTER FUNCTION sprpcambioscapital2(integer, integer, integer, integer) OWNER TO sistema;

