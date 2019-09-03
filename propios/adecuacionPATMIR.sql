update tipoprestamo set montomaximo=2000.000000,montominimo=2000.000000, tasa_normal=0.000000,tasa_mora=0.000000,periododiasdefault=180,plazomaximo=999 where tipoprestamoid='P4';


update tipoinversion set tasa_normal_inversion=30.000000, plazo=180,tipomovimientoid='AO', montomaximo=2000.000000,montominimo=2000.000000  where tipoinversionid='K3';
