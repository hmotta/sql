CREATE FUNCTION spsusuariofinanciero(text) RETURNS SETOF tsociocaja
    AS $_$
declare
  pfiltro alias for $1; 
  r tsociocaja%rowtype;
  filtro text;
begin

    filtro := pfiltro || '%';
    for r in
      select s.socioid,s.clavesocioint,j.paterno,j.materno,j.nombre,tp.descritiposocio as estatus
        from socio s, sujeto j,tiposocio tp
       where j.sujetoid = s.sujetoid and         
             (s.clavesocioint like filtro or
              (j.nombre||' '||j.paterno||' '||j.materno) like filtro or
              (j.paterno||' '||j.materno||' '||j.nombre) like filtro) and
             tp.tiposocioid = s.tiposocioid   and tp.tiposocioid='06'           
      order by s.clavesocioint
    loop
      return next r;
    end loop;

return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
