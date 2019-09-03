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
