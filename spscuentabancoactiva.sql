CREATE OR REPLACE FUNCTION spscuentabancoactiva(character) RETURNS SETOF bancos
    AS $$
declare	
 r bancos%rowtype;
  pnombresuc alias for $1;
begin

  if pnombresuc<>'              ' then
    for r in
      select no_cuenta,cuentaid,banco,fecha_inicio,saldo_inicial,saldo_actual,saldo_pen,seriebanco,nocheque from bancos natural join catalogo_ctas where cuentanombre ilike '%'||pnombresuc||'%' and no_cuenta not in ('7342250933','152449137','9202276801','152449129','71361421','7342189533','22000223811','123268963','4042527507','92000107912') order by no_cuenta
    loop
      return next r;
    end loop;
  else
   for r in
      select no_cuenta,cuentaid,banco,fecha_inicio,saldo_inicial,saldo_actual,saldo_pen,seriebanco,nocheque from bancos where no_cuenta not in ('7342250933','152449137','9202276801','152449129','71361421','7342189533','22000223811','123268963','4042527507','92000107912') order by no_cuenta
    loop
      return next r;
    end loop;
  end if;
  return;
end
$$
    LANGUAGE plpgsql SECURITY DEFINER;