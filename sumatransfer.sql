select (sum(capital)+sum(interes)+sum(moratorio)+sum(iva)+sum(deposito))-sum(retiro) from cortecajatransfer('V8','2015-07-10',0);