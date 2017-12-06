update tipoprestamo set estatus=0 where tipoprestamoid in ('C0','N18','N17');
delete from calculo where calculoid in (6,7,8,9,10,11);