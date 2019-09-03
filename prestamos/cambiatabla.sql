CREATE FUNCTION cambiatabla(numeric, date, character, integer, integer, integer, integer, date, numeric, integer) RETURNS numeric
    AS $_$
declare
  pmonto          alias for $1;
  ppago1          alias for $2;
  ptipoprestamoid alias for $3;
  pnoamor         alias for $4;
  pperiododias    alias for $5;
  pmeses          alias for $6;
  pdiames         alias for $7;
  pfechaotorga    alias for $8;
  ptasanormal     alias for $9;
  pprestamoid     alias for $10;

  fmonto numeric;
  dpago1 date;
  stipoprestamoid char(3);
  inoamor integer;
  iperiododias integer;
  imeses integer;
  idiames integer;
  ffechaotorga date;
  ftasanormal numeric;

  ivalor numeric;
  
  
begin

  ivalor=0;
  select montoprestamo,fecha_1er_pago,tipoprestamoid,numero_de_amor,dias_de_cobro,meses_de_cobro,dia_mes_cobro,fecha_otorga,tasanormal
  into fmonto,dpago1,stipoprestamoid,inoamor,iperiododias,imeses,idiames,ffechaotorga,ftasanormal
  from prestamos where prestamoid=pprestamoid;
  
  if fmonto <> pmonto or dpago1 <> ppago1 or stipoprestamoid <> ptipoprestamoid or inoamor <> pnoamor or iperiododias <> pperiododias
     or imeses <> pmeses or idiames <> pdiames or ffechaotorga <> pfechaotorga or ftasanormal <> ptasanormal then
     ivalor = 100;

  end if;

  -- Validar si no existe el prestamo generar la tabla
  
  if not exists(select prestamoid from prestamos where prestamoid=pprestamoid) then
     ivalor = 100;
  end if;   

  return ivalor;

  end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;