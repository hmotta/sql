--Parametrizaion de los productos de credito activos para el cobro de comison 1 al millar

select spicargoprestamo('N1 ','6101080601              ','N1 CREDISOLUCION',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N4 ','6101080601              ','N4 CREDICUMPLIDO',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N5 ','6101080601              ','N5 CREDIUNION',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N7 ','6101080601              ','N7 CREDIEMPLEADO',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N8 ','6101080601              ','N8 CREDIMATICO',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N9 ','6101080601              ','N9 AUTOESTRENA',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N13 ','6101080601              ','N13 CREDITO NAVIDEÑO',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N14 ','6101080601              ','N14 CREDI ESCOLAR',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N15 ','6101080601              ','N15 CREDI HOGAR',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N16 ','6101080601              ','N16 CREDIMATICO INVERSION',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401            ');
select spicargoprestamo('N17 ','6101080601              ','N17 CREDI TANDA SEMANAL',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N18 ','6101080601              ','N18 CREDI TANDA QUINCENAL',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('P1 ','6101080601              ','P1 CREDI CAMPO',0,0,1,0.000000,999999.000000,0.100000,0.000000,0,0,'','2305090401              ');
select spicargoprestamo('N20 ','6101080304              ','N20 CREDI LLANTAS',0,0,1,0.000000,999999.000000,8.000000,0.000000,0,0,'','2305090401              ');


---Parametrizacion en la tabla tipoprestamo para el cobro de comision 1 al millar  

update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N1 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N4 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N5 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N7 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N8 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N9 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N13 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N14 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N15 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N16 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N17 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='N18 ';
update tipoprestamo set cuentacomision='6101080601', cuentaivacomision='2305090401' where tipoprestamoid='P1 ';





