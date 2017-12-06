CREATE OR REPLACE FUNCTION verficapermiso(character varying,character varying) RETURNS character
AS $_$
declare
  --r rgestioncobranza%rowtype;
 -- l record;
  pclavemodulo alias for $1;
  pusuario alias for $2;
  cpermiso character;
begin
	select coalesce(permiso,'N') into cpermiso from permisosmodulos where clavemodulo = pclavemodulo and usuarioid=pusuario;
	
	insert into bitacoraaccesos (clavemodulo,descripcionmodulos,usuarioid,fecha,fechahora,acceso) values (pclavemodulo,(select descripcionmodulos from modulos where clavemodulo=pclavemodulo),pusuario,current_date,current_timestamp,cpermiso);
	return cpermiso;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;
