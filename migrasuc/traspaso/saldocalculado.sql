
drop type saldocalculado cascade;
create type saldocalculado as (saldo numeric, fechaultimopago date);

drop function saldocalculado(int4);

create or replace function saldocalculado(int4) returns setof saldocalculado as
'
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
  from prestamos p, tipoprestamo tp, movicaja mc, movipolizas m
 where p.prestamoid = lprestamoid and
       tp.tipoprestamoid = p.tipoprestamoid and
       mc.prestamoid = p.prestamoid and
       m.polizaid = mc.polizaid and
       m.cuentaid = tp.cuentaactivo
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
          mc.estatusmovicaja=''A'' and
          mc.tipomovimientoid=''00'' and
          m.debe+m.haber>0;

  dultimoabono:= coalesce(dultimoabono,dfechaotorga);

  r.saldo := fsaldocalculado;
  r.fechaultimopago := dultimoabono;

  return next r;
  return;

end
'

language 'plpgsql' security definer;
