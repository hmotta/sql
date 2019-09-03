CREATE or replace FUNCTION bitacorapassword(character, character) RETURNS integer
    AS $_$
declare
  pusuarioid alias for $1;
  ppassworda  alias for $2;

begin

  insert into bitacoraaccesos(clavemodulo,descripcionmodulos,usuarioid,fecha,fechahora,acceso,tipomovimientoid,deposito,retiro)
      values ('CCLAVE','ASIGNACION DE PASSWORD',pusuarioid,current_date,current_timestamp,'N','DY',0,0);

  return 1;
  
end 
$_$
    LANGUAGE plpgsql SECURITY DEFINER;