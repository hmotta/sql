CREATE or replace FUNCTION spucomplementarios(integer, integer, integer, integer, integer, integer, integer, date, character) RETURNS integer
    AS $_$
declare

 pprestamoid             alias for $1;
 pnorenovaciones         alias for $2;
 pformalizado            alias for $3;
 pcondicionid            alias for $4;
 pclasificacioncreditoid alias for $5;
 psujetoid               alias for $6;
 ptipoacreditadoid       alias for $7;
 pfechavaluaciongarantia alias for $8;
 pprestamodescontado     alias for $9;
 stipoprestamoid char(3);


begin
	select tipoprestamoid into stipoprestamoid from prestamos where prestamoid=pprestamoid;
	if stipoprestamoid in ('T1','T2','T3') then
		if pclasificacioncreditoid<>3 then	
			raise exception 'La clasifiacion de credito debe ser REESTRUCTURADO';
		end if;
	elseif stipoprestamoid in ('R1','R2','R3') then
		if pclasificacioncreditoid<>2 then	
			raise exception 'La clasifiacion de credito debe ser RENOVADO';
		end if;
	end if;


   update prestamos
      set norenovaciones     = pnorenovaciones,
          formalizado        = pformalizado,
          condicionid        = pcondicionid,
          clasificacioncreditoid = pclasificacioncreditoid,
          sujetoid           = psujetoid,
          tipoacreditadoid   = ptipoacreditadoid,
          fechavaluaciongarantia = pfechavaluaciongarantia,
          prestamodescontado = pprestamodescontado
 where prestamoid = pprestamoid;

return pprestamoid;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
