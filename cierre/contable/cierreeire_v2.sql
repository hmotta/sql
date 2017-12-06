
CREATE or replace FUNCTION cierreeire(character, character, date) RETURNS integer
    AS '
declare
  pcuentaid alias for $1;
  pserie alias for $2;
  pfecha alias for $3;

  ppolizaid int4;
  pmovipolizaid int4;
  pnumero_poliza int4;
  preferencia int4;

  iejercicio int;
  iperiodo int;

  resultado numeric;

  r saldos%rowtype;

  fsaldo numeric;
  speriodo char(2);
  

begin

  iejercicio := cast(date_part(''year'',pfecha) as int);
  iperiodo := cast(date_part(''month'',pfecha) as int);

  speriodo := ltrim(to_char(iperiodo,''99''))||''1'';

  --  iperiodo := iperiodo+1;

  update periodo set estatus=''A''
   where ejercicio=iejercicio and periodo=iperiodo;

  delete from movipolizas where polizaid in
    (select polizaid from polizas where fechapoliza=pfecha and tipo=''X'');

  delete from polizas where fechapoliza=pfecha and tipo=''X'';


--
-- Dar de alta la poliza contable
--
  select *
    into pnumero_poliza,preferencia
  from rconspoliza(cast(date_part(''year'',pfecha) as int),cast(date_part(''month'',pfecha) as int),''X'',pserie,''D'');

-- Encabezado de la poliza
  select * 
    into ppolizaid
    from spipolizasfecha(preferencia,pserie,''X'',pnumero_poliza,cast(date_part(''year'',pfecha) as int),cast(speriodo as int),'' '',pfecha,''D'','' '','' '',''Poliza de Cierre EIRE'',pfecha);


  resultado :=0;

  
  for r in
    select 1,s.cuentaid,s.ejercicio,iperiodo,sum(s.saldoinicialperiodo),
           sum(s.cargosdelperiodo),sum(s.abonosdelperiodo)
      from saldos s, catalogo_ctas c
     where s.ejercicio=iejercicio and
           s.periodo=iperiodo and
           c.cuentaid=s.cuentaid and
           c.tipo_cta=''A'' and
           (substr(c.cuentaid,1,1)=''5'' or substr(c.cuentaid,1,1)=''6'')
   group by s.cuentaid,s.ejercicio
   order by s.cuentaid

  loop
    -- Detalle de la poliza

   raise notice ''Cerrando %'',r.cuentaid;

   fsaldo:=r.saldoinicialperiodo+r.cargosdelperiodo-r.abonosdelperiodo;
    
   if fsaldo<>0 then
     if fsaldo<0 then
       select *
         into pmovipolizaid
         from spimovipoliza(ppolizaid,r.cuentaid,'' '',''C'',-1*fsaldo,0,'' '','' '',''Cierre Ejercicio'');
     else
       select *
         into pmovipolizaid
         from spimovipoliza(ppolizaid,r.cuentaid,'' '',''A'',0,fsaldo,'' '','' '',''Cierre Ejercicio'');
     end if;

   end if;

   resultado:=resultado+fsaldo;

  end loop;

  raise notice ''Resultado = %'',resultado;

  if resultado>0 then
   raise notice ''Cargandolo'';
   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,pcuentaid,'' '',''C'',abs(resultado),0,'' '','' '',''Cierre EIRE'');
  else
   raise notice ''Abonandolo'';
   select *
     into pmovipolizaid
     from spimovipoliza(ppolizaid,pcuentaid,'' '',''A'',0,abs(resultado),'' '','' '',''Cierre EIRE'');

  end if;

  update periodo set estatus=''C''
   where ejercicio=iejercicio and periodo=iperiodo;

return 1;
end
'
    LANGUAGE plpgsql SECURITY DEFINER;


  CREATE or replace FUNCTION cbalanza(integer, integer) RETURNS SETOF saldos
    AS $_$
declare
  pejercicio alias for $1;
  pperiodo   alias for $2;

  r saldos%rowtype;
  f record;
  dblink1 text;
  dblink2 text;

begin

for f in
 select * from sucursales where vigente='S'
 loop
        raise notice 'Conectando sucursal % % ',f.basededatos,f.esquema;

        dblink1:='host='||f.host||' dbname='||f.basededatos||' user='||f.usuariodb||' password='||f.passworddb;
        dblink2:='select * from '||f.esquema||'.saldos where ejercicio='||to_char(pejercicio,9999)||' and to_char(periodo,99)='||''''||to_char(pperiodo,99)||'''';

--        raise notice 'dblink % % ',dblink1,dblink2;

        for r in
        SELECT * FROM
        dblink(dblink1,dblink2) as
               t2(saldoid int4, 
  CuentaID CHAR(24), 
  ejercicio INTEGER, 
  periodo INTEGER, 
  saldoinicialperiodo NUMERIC, 
  cargosdelperiodo NUMERIC, 
  abonosdelperiodo numeric)

 loop
   return next r;
 end loop;

 end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


CREATE or replace FUNCTION balanza(character, character, integer, integer) RETURNS SETOF catalogo_ctas
    AS $_$
declare
  pcuentai   alias for $1;
  pcuentaf   alias for $2;
  pejercicio alias for $3;
  pperiodo   alias for $4;
  r catalogo_ctas%rowtype;
  rs catalogo_ctas%rowtype;
  rc record;

  -- Totales debe y haber
  ldebe numeric;
  lhaber numeric;

begin

 ldebe := 0;
 lhaber := 0;

 update catalogo_ctas
    set saldo_inic_ejer=0,
        cargos_acum_ejer =0,
        abonos_acum_ejer=0;

 ----------------------------------------------------
 -- Buscar los saldos iniciales en
 -- los movimientos de polizas
 ---------------------------------------------------- 
 for rc in
   select m.cuentaid,sum(round(m.debe,2))-sum(round(m.haber,2)) as saldoinicial
          from polizas p,movipolizas m
    where ((p.ejercicio<pejercicio) or
           (p.ejercicio=pejercicio and to_char(p.periodo,99)<to_char(pperiodo,99))) and
          m.polizaid=p.polizaid        
   group by m.cuentaid
 loop
    update catalogo_ctas
       SET saldo_inic_ejer=coalesce(rc.saldoinicial,0)
     WHERE cuentaid=rc.cuentaid;
 end loop;

 ----------------------------------------------------
 -- Buscar para el ejercicio y periodo
 -- los movimientos de polizas
 ----------------------------------------------------
 for rc in
   select m.cuentaid,sum(round(m.debe,2)) as cargos,sum(round(m.haber,2)) as abonos
     from polizas p,movipolizas m
    where p.ejercicio=pejercicio and p.periodo=pperiodo and
          m.polizaid=p.polizaid        
   group by m.cuentaid
 loop
    update catalogo_ctas
       SET cargos_acum_ejer=coalesce(round(rc.cargos,2),0),
           abonos_acum_ejer=coalesce(round(rc.abonos,2),0)
     WHERE cuentaid=rc.cuentaid;
 end loop;

 ----------------------------------------------------
 -- Acumular los movimientos de manera recursiva
 -- junto con sus cuentas acumulables respectivas
 ----------------------------------------------------
 
 FOR r IN SELECT *
            FROM catalogo_ctas
           WHERE tipo_cta='A' and
                 cuentaid>=pcuentai and
                 cuentaid<=pcuentaf and
                 (saldo_inic_ejer<>0 or
                  cargos_acum_ejer<>0 or
                  abonos_acum_ejer<>0)

 LOOP
   --raise notice 'Procensando cuenta %',r.cuentaid;
   FOR rs IN SELECT * FROM subcuentas(r.cuentaid,0,0,0)
   LOOP
      if rs.tipo_cta='A' then
        ldebe := ldebe + rs.cargos_acum_ejer;
        lhaber := lhaber + rs.abonos_acum_ejer;
      end if;
      RETURN NEXT rs;
   END LOOP;
 END LOOP;

 ----------------------------------------------------
 -- Regresar las cuentas que no tienen movimientos
 -- o saldo inicial cero
 ----------------------------------------------------
 FOR r IN SELECT * FROM catalogo_ctas
           WHERE cuentaid not in
                 (SELECT c.cuentaid
                    FROM catalogo_ctas c
                   WHERE c.cuentaid>=pcuentai and
                        c.cuentaid<=pcuentaf and
                         (c.saldo_inic_ejer<>0 or c.cargos_acum_ejer<>0 or c.abonos_acum_ejer<>0)) and
                 cuentaid>=pcuentai and
                 cuentaid<=pcuentaf
 LOOP
   if r.tipo_cta='A' then
     ldebe := ldebe +  r.cargos_acum_ejer;
     lhaber := lhaber + r.abonos_acum_ejer;
   end if;
   RETURN NEXT r;
 END LOOP; 

 r.cuentaid := 'T';
 r.cuentanombre := 'TOTALES .... ';
 r.cargos_acum_ejer := ldebe;
 r.abonos_acum_ejer := lhaber;
 return next r;

 update catalogo_ctas
    set saldo_inic_ejer=0,
        cargos_acum_ejer =0,
        abonos_acum_ejer=0;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;



CREATE or replace FUNCTION consolidabalanza(integer, integer) RETURNS SETOF catalogo_ctas
    AS $_$
declare

  pejercicio alias for $1;
  pperiodo   alias for $2;
  r catalogo_ctas%rowtype;

  -- Totales debe y haber
  ldebe numeric;
  lhaber numeric;

begin

  ldebe := 0;
  lhaber := 0;

  for r in
    select c.cuentaid,c.cat_cuentaid,c.identificacion,c.cuentanombre,c.tipo_cta,c.estado_cta,c.fecha_estado,c.fecha_ult_mov,c.naturaleza,c.digito_agrupador,sum(b.saldoinicialperiodo) as saldo_inic_ejer, sum(b.cargosdelperiodo) as cargos_acum_ejer,sum(b.abonosdelperiodo) as abonos_acum_ejer
    from catalogo_ctas c, cbalanza(pejercicio,pperiodo) as b
    where b.cuentaid=c.cuentaid
  group by c.cuentaid,c.cat_cuentaid,c.identificacion,c.cuentanombre,c.tipo_cta,c.estado_cta,c.fecha_estado,c.fecha_ult_mov,c.naturaleza,c.digito_agrupador
  loop
      if r.tipo_cta='A' then
        ldebe := ldebe + r.cargos_acum_ejer;
        lhaber := lhaber + r.abonos_acum_ejer;
      end if;

    return next r;
  end loop;


 r.cuentaid := 'T';
 r.cuentanombre := 'TOTALES .... ';
 r.cargos_acum_ejer := ldebe;
 r.abonos_acum_ejer := lhaber;
 return next r;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


        
--modo de uso

--select * from cierreeire('410701','Z','2012-07-31');
--select * from generasaldos(2012,7);
--select * from generasaldos(2012,71);


