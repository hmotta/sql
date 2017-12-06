CREATE OR REPLACE FUNCTION verificasociosbloquear() RETURNS  integer
    AS $_$
declare
  r record;
  saldopa numeric;
begin
	--bloquear los socios que cumplieron la mayoria de edad
	for r in
		select socioid,fecha_nacimiento from socio natural join sujeto su where tiposocioid in ('01') and estatussocio in (1,3) and socioid not in (select socioid from cuentasbloqueadas where socioid=socio.socioid and bloqueovigente='S' and bloqueatodo='S') group by socioid,su.fecha_nacimiento  having substr(age(fecha_nacimiento),1,2)::integer>=18
	loop
		insert into cuentasbloqueadas values(r.socioid,null,'S','S','el socio ha cumplido la mayoria de edad.',null,null);
	end loop;
	
	--bloquear los socios que tienen mas de 6 meses o 180 dias de inactividad
	for r in
		select socioid,current_date-max(p.fechapoliza),tiposocioid from movicaja mc natural join polizas p natural join socio s where tipomovimientoid in ('AC','AA','IP','AI','AP','P3','TA','PR','AH','AO','AF','AM','00','IN') and seriecaja not in ('ZA','WW') and estatussocio in (1,3) and socioid not in (select socioid from cuentasbloqueadas where socioid=mc.socioid and bloqueovigente='S' and bloqueatodo='S') group by socioid,tiposocioid having (current_date-max(p.fechapoliza))>=180
	loop
		select coalesce(saldomov,0) into saldopa from saldomov(r.socioid,'PA',current_date);
		if saldopa>0 or r.tiposocioid='01' then
			perform *  from cuentasbloqueadas where bloqueovigente='S' and bloqueatodo='S' and socioid=r.socioid;
			if not found then
				insert into cuentasbloqueadas values(r.socioid,null,'S','S','por 6 meses o mas de inactividad.',null,null);
			end if;
		end if;
	end loop;
	
	

return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;