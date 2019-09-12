CREATE  OR REPLACE FUNCTION generaramortizaciones(character, numeric, date) RETURNS integer
    AS $_$
declare
 
  preferenciaprestamo alias for $1;
  pabono alias for $2;
  pultimopago alias for $3;
  x record;
  r tablaamor%rowtype;
  amor amortizaciones%rowtype;

  lamortizacionid int4;
  fAbono numeric;
  fAplicar numeric;
  pprestamoid int4;
begin

  select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo;
  delete from amortizaciones where prestamoid=pprestamoid;

  for x in
    select * from prestamos where referenciaprestamo=preferenciaprestamo
  loop
      for r in
        select * from
           sptablaamor(x.montoprestamo,x.fecha_1er_pago,x.tipoprestamoid,x.numero_de_amor,
                       x.dias_de_cobro,x.meses_de_cobro,x.dia_mes_cobro,x.fecha_otorga,x.tasanormal)
      loop
         select * into lamortizacionid
           from spiamortizacion(x.prestamoid,r.numamortizacion,r.fechadepago,r.importeamortizacion,
                                r.interesnormal,r.saldo_absoluto,'001',0,0,x.fecha_otorga,r.iva,r.pagototal);
      end loop;
      
  end loop;

 if pabono>0 then
    fAbono := pabono;
    --select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo;
    for amor in
        select *
          from amortizaciones
         where prestamoid=pprestamoid and importeamortizacion-abonopagado>0
      order by fechadepago
    loop

      fAplicar := amor.importeamortizacion - amor.abonopagado;

      if fAbono>=fAplicar then
        update amortizaciones
           set abonopagado = importeamortizacion,
               ultimoabono = pultimopago,
               claveestadocredito = '002'
         where amortizacionid=amor.amortizacionid;
         fAbono := fAbono - fAplicar;
      else
        if fAbono>0 then
          update amortizaciones
             set abonopagado = abonopagado+fAbono,
                 ultimoabono = pultimopago
           where amortizacionid=amor.amortizacionid;
           fAbono := 0;
        end if;
      end if;
    end loop;
  end if;
	-->> modificacion hmota 25/04/2012
	PERFORM verificaultimafechaamort(pprestamoid);
  --<< modificacion hmota 25/04/2012	
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;