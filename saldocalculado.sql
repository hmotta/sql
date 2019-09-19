-- ----------------------------
-- Type structure for saldocalculado
-- ----------------------------
--DROP TYPE IF EXISTS saldocalculado;
CREATE TYPE saldocalculado AS (
  saldo numeric,
  fechaultimopago date
);

CREATE OR REPLACE FUNCTION saldocalculado(int4)
  RETURNS SETOF saldocalculado AS $BODY$
declare

lprestamoid alias for $1;
r saldocalculado%rowtype;
fsaldoact  numeric;
fsaldocalculado numeric;
sclaveestadocredito char(3);
dfechaotorga date;
dultimoabono date;
pmonto numeric;

begin

select p.saldoprestamo, p.montoprestamo-sum(m.haber),p.claveestadocredito,p.fecha_otorga
  into fsaldoact,fsaldocalculado,sclaveestadocredito,dfechaotorga
  from prestamos p, cat_cuentas_tipoprestamo ct, movicaja mc, movipolizas m
 where p.prestamoid = lprestamoid and
       ct.cat_cuentasid = p.cat_cuentasid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.cuentaid = ct.cuentaactivo
group by p.saldoprestamo,p.montoprestamo,p.claveestadocredito,p.fecha_otorga;


  select montoprestamo into pmonto from prestamos where prestamoid=lprestamoid;

  fsaldoact:=coalesce(fsaldoact,0);
  fsaldocalculado:= coalesce(fsaldocalculado,pmonto);

  -- Verificar la fecha de ultimo abono
  -- en caso de estar erronea correguirla
  --
  select max(p.fechapoliza)
     into dultimoabono
     from movicaja mc,polizas p, movipolizas m
    where mc.prestamoid = lprestamoid and             
          p.polizaid = mc.polizaid and
          m.movipolizaid = mc.movipolizaid and
          mc.estatusmovicaja='A' and
          mc.tipomovimientoid='00' and
          m.debe+m.haber>0;

  dultimoabono:= coalesce(dultimoabono,dfechaotorga);

  r.saldo := fsaldocalculado;
  r.fechaultimopago := dultimoabono;

  return next r;
  return;

end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;