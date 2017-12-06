CREATE OR REPLACE FUNCTION generaramortizaciones(character) RETURNS integer
    AS $_$
declare
 
  preferenciaprestamo alias for $1;
  x record;
  r tablaamor%rowtype;

  lamortizacionid int4;
  -->> modificacion hmota 25/04/2012
  pprestamoid int4;
  --<< modificacion hmota 25/04/2012	
begin
	-->> modificacion hmota 25/04/2012
	select prestamoid into pprestamoid from prestamos where referenciaprestamo=preferenciaprestamo;
	--<< modificacion hmota 25/04/2012	
  for x in
    select * from prestamos where referenciaprestamo=preferenciaprestamo
  loop
      for r in
        select * from
           sptablaamor(x.montoprestamo,x.fecha_1er_pago,x.tipoprestamoid,x.numero_de_amor,
                       x.dias_de_cobro,x.meses_de_cobro,x.dia_mes_cobro,x.fecha_otorga)
      loop
         select * into lamortizacionid
           from spiamortizacion(x.prestamoid,r.numamortizacion,r.fechadepago,r.importeamortizacion,
                                r.interesnormal,r.saldo_absoluto,'001',r.interesnormal,0,x.fecha_otorga);
      end loop;
      
  end loop;
	-->> modificacion hmota 25/04/2012
	PERFORM verificaultimafechaamort(pprestamoid);
	--<< modificacion hmota 25/04/2012	
return 1;
end
$_$
    LANGUAGE plpgsql;