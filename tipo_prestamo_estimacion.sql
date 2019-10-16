CREATE OR REPLACE FUNCTION tipo_prestamo_estimacion(integer) RETURNS integer
    AS $_$
declare

 pprestamoid alias for $1;
 
 stipoprestamoid varchar(3);
 nrenovado integer;
 ndiasmora_origen integer;
 nsocioid integer;
 
 nprestamoid_tipo2 integer;
 xsaldo_tipo2 numeric;
 
 ntipo_cartera_est integer;
begin
	ntipo_cartera_est:=1;
	
	--los tipos T2
	select socioid,tipoprestamoid,renovado,diasmoraorigen into nsocioid,stipoprestamoid,nrenovado,ndiasmora_origen from prestamos where prestamoid=pprestamoid;
	if (stipoprestamoid = 'T2') then
		ntipo_cartera_est:=2;
	end if;
	
	if (nrenovado=1 and ndiasmora_origen>0) then --si es renovado emproblemado
		ntipo_cartera_est:=2;
	end if;
	
	if pprestamoid in (select prestamoid from emproblemados) then
		ntipo_cartera_est:=2;
	end if;
	
	--si tiene un tipo 2 en el precorte y ademas está activo
	select pr.prestamoid into nprestamoid_tipo2 from precorte p inner join prestamos pr on (p.prestamoid=pr.prestamoid) where p.tipo_cartera_est=2 and pr.socioid=nsocioid order by fechacierre desc limit 1;
	nprestamoid_tipo2:=coalesce(nprestamoid_tipo2,0);
	
	select saldoprestamo into xsaldo_tipo2 from prestamos where prestamoid=nprestamoid_tipo2;
	xsaldo_tipo2:=coalesce(xsaldo_tipo2,0);
	
	if nprestamoid_tipo2>0 and (xsaldo_tipo2)>0 then
		ntipo_cartera_est:=2;
	end if;
	
	--Por ultimo si el cliente ya tiene un credito tipo 2 activo
	if (select count(*) from prestamos where socioid=nsocioid and claveestadocredito='001' and tipo_cartera_est=2) >0 then
		ntipo_cartera_est:=2;
	end if;
	
	update prestamos set tipo_cartera_est=ntipo_cartera_est where prestamoid=pprestamoid;
return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
