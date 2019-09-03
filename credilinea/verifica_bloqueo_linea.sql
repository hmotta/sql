CREATE or replace FUNCTION verifica_bloqueo_linea(integer) RETURNS integer
    AS $_$
declare  
	pprestamoid alias for $1;
	smotivo varchar(200);
	npagos_vencidos integer;
	dfecha_adeudo date;
begin
	--Primero verifica si ya está bloqueda
	select motivo into smotivo from creditos_lineas_bloqueo where estatus='B' and vigente='S' and lineaid=pprestamoid;
	if NOT FOUND then	
		--Verifica si tiene 3 cortes vencidos
		select count(*) into npagos_vencidos from corte_linea where lineaid=pprestamoid and fecha_limite<current_date and (capital-capital_pagado)>0;
		npagos_vencidos:=coalesce(npagos_vencidos,0);
		if npagos_vencidos>=3 then -- La linea se bloquea
			select fecha_limite+1 into dfecha_adeudo from corte_linea where lineaid=pprestamoid and fecha_limite<current_date and (capital-capital_pagado)>0 order by fecha_limite limit 1;
			insert into creditos_lineas_bloqueo (lineaid,fecha,motivo,automatico,usuario,estatus,vigente) values(pprestamoid,dfecha_adeudo,'La linea tiene 3 cortes vencidos','S','automaitco','B','S');
		end if;
	end if;
	--select motivo into smotivo from creditos_lineas_bloqueo where estatus='B' and vigente='S';
	--if FOUND then
	--	raise exception 'Linea bloqueda: %', smotivo;
	--	return 1;
	--end if;
	return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;