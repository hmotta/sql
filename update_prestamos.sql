update prestamos pr set cat_cuentasid=(select cat_cuentasid from cat_cuentas_tipoprestamo where tipoprestamoid=pr.tipoprestamoid and clavefinalidad=pr.clavefinalidad and renovado=pr.renovado );