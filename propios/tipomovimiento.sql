
CREATE or replace FUNCTION spstipomovimiento(character) RETURNS SETOF tipomovimiento
    AS $_$
declare
  r tipomovimiento%rowtype;
  pclave alias for $1;
begin

  if pclave<>'  ' then
    for r in
      select tipomovimientoid,cuentadeposito,cuentaretiro,cuentaintpagado,cuentaintcobrado,cuentaivamovimiento,cuentaisr,desctipomovimiento,aplicasaldo,tipopoliza,aceptadeposito,aceptaretiro,tasainteres,cuentaordenacredor,cuentaordendeudor,cuentaorden,cuentaprovisionisr,comision,porcomision,porivacomision,cuentacomision,cuentaivacomision,desglosaiva
        from tipomovimiento where tipomovimientoid=pclave
    loop
      return next r;
    end loop;
  else
   for r in
      select tipomovimientoid,cuentadeposito,cuentaretiro,cuentaintpagado,cuentaintcobrado,cuentaivamovimiento,cuentaisr,desctipomovimiento,aplicasaldo,tipopoliza,aceptadeposito,aceptaretiro,tasainteres,cuentaordenacredor,cuentaordendeudor,cuentaorden,cuentaprovisionisr,comision,porcomision,porivacomision,cuentacomision,cuentaivacomision,desglosaiva
      from tipomovimiento order by tipomovimientoid
    loop
      return next r;
    end loop;
  end if;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
