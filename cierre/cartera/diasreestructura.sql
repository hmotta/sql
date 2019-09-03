CREATE OR REPLACE FUNCTION diasreestructura(integer)
  RETURNS integer AS
$BODY$
declare
  pprestamoid alias for $1;
 
  r record;
  dfecha date;
  dfechaotorga date;
  dfechaotorga_ant date;
  origenid integer;
  
 
begin
	if pprestamoid=11162 then
		return 42;
	end if;
	if pprestamoid=13079 then
		return 66;
	end if;
	--if pprestamoid=15286 then
		--return 174;
	--end if;
	if pprestamoid=16077 then
		return 66;
	end if;
	select prestamoid into origenid from prestamos where referenciaprestamo=(select referenciaprestamoorigen from prestamos where prestamoid=pprestamoid);
	select fecha_otorga into dfechaotorga from prestamos where prestamoid=pprestamoid;
	dfechaotorga_ant:=dfechaotorga-1;
	select fechaprimeradeudo into dfecha from fechaprimeradeudo(origenid,dfechaotorga_ant);
	return dfechaotorga-dfecha;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;