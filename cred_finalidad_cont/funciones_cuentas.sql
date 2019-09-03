
CREATE OR REPLACE FUNCTION cta_general(int4,varchar)
  RETURNS varchar(24) AS $BODY$
 --cta_general (regresa una cuenta especifica del credito segun la columna enviada)
declare
	pprestamoid alias for $1;
	pcolumna alias for $2;
	sclavefinalidad char(3);
	nrenovado int4;
	stipoprestamoid varchar(3);
	scuenta varchar(24);
begin
	select tipoprestamoid,clavefinalidad,renovado into stipoprestamoid,sclavefinalidad,nrenovado from prestamos where prestamoid=pprestamoid;
	select pcolumna into scuenta from cat_cuentas_tipoprestamo where tipoprestamoid=stipoprestamoid and clavefinalidad=sclavefinalidad and renovado=nrenovado;
	if (trim(scuenta)='' or scuenta is null or trim(scuenta)='99') then
		raise exception 'No existe la cuenta % para el tipo: %',pcolumna,stipoprestamoid;
	end if;
	return scuenta;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  

CREATE OR REPLACE FUNCTION cta_cap_vig(int4)
  RETURNS varchar(24) AS $BODY$
  --Regresa la cuenta de capital vigente (Cuenta contable de ACTIVO para  registrar/acumular el CAPITAL VIGENTE) (se ocupa en CAJA)
declare
	pprestamoid alias for $1;
begin
	return cta_general(pprestamoid,'cuentaactivo');
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  

CREATE OR REPLACE FUNCTION cta_cap_ven(int4)
  RETURNS varchar(24) AS $BODY$
  --Cuenta de capital vencido (Cuenta contable de ACTIVO para registrar/acumular el CAPITAL VENCIDO)
declare
	pprestamoid alias for $1;
begin
	return cta_general(pprestamoid,'cuentaactivovencida');
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  

CREATE OR REPLACE FUNCTION cta_int_vig(int4)
  RETURNS varchar(24) AS $BODY$
  --Cuenta contable de INGRESOS (RESULTADO) para registrar/acumular el INTERES NORMAL VIGENTE COBRADO (se ocupa en CAJA)
declare
	pprestamoid alias for $1;
begin
	return cta_general(pprestamoid,'cuentaintnormal');
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
  
CREATE OR REPLACE FUNCTION cta_int_ven(int4)
 RETURNS varchar(24) AS $BODY$
 --Cuenta contable de ACTIVO para registrar/acumular el INTERES VENCIDO 
declare
	pprestamoid alias for $1;
begin
	return cta_general(pprestamoid,'cuentaintnormalvencida');
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  

CREATE OR REPLACE FUNCTION cta_int_nocob_vig(int4)
 RETURNS varchar(24) AS $BODY$
 --Cuenta contable de INGRESOS para registrar/acumular el INTERES DEVENGADO NO COBRADO VIGENTE
declare
	pprestamoid alias for $1;
begin
	return cta_general(pprestamoid,'cuentaintnormalnocob');
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cta_int_mora(int4)
 RETURNS varchar(24) AS $BODY$
 --Cuenta contable de INGRESOS para registrar/acumular el INTERES MORATORIO COBRADO (se ocupa en CAJA)
declare
	pprestamoid alias for $1;
begin
	return cta_general(pprestamoid,'cuentaintmora');
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
CREATE OR REPLACE FUNCTION cta_iva(int4)
 RETURNS varchar(24) AS $BODY$
 --Cuenta contable de IVA para registrar/acumular el IVA COBRADO (se ocupa en CAJA)
declare
	pprestamoid alias for $1;
begin
	return cta_general(pprestamoid,'cuentaiva');
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;