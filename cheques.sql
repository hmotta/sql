select p.numero_poliza,referenciamovi,beneficiario,montocheque,fechacheque,b.banco,serie,trim(p.concepto_poliza) from chequesemitidos ch, movibanco mb, polizas p, bancos b where ch.movibancoid=mb.movibancoid and p.polizaid=mb.polizaid and mb.no_cuenta=b.no_cuenta and ch.fechacheque between '"+gFecha1+"' and '"+gFecha2+"';