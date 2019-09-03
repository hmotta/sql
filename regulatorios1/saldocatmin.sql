--Esta función regresa solo saldos de cuentas acumulables
CREATE or replace FUNCTION saldocatmin(character) RETURNS SETOF numeric
    AS $_$
declare
  cuenta alias for $1;
  fsaldo numeric;
  fsaldototal numeric;
  r record;
  l record;
begin
	fsaldo:=0;
	fsaldototal:=0;
	--Regresa el saldo de las subcuentas afectables (es decir que tienen saldo directo) de la cuenta en cuestión
	if cuenta  in (select cmacumulable  from catalogominimo2 where cmacumulable=cuenta and tipo_cta='A') then
		for l in
			select cmcuenta from catalogominimo2 where cmacumulable=cuenta and tipo_cta='A' group by cmcuenta
		loop
			select coalesce(round(sum(saldo)),0) into fsaldo from catalogominimo2 where cmcuenta=l.cmcuenta and tipo_cta='A';
			--raise notice 'signo=%',(select signo from catalogominimo2 where cmcuenta=l.cmcuenta limit 1);
			--raise notice 'CUENTA=%,saldo=%',l.cmcuenta,fsaldo;
			fsaldototal:=fsaldototal+fsaldo;
			--fsaldototal:=fsaldototal*(select signo from catalogominimo2 where cmcuenta=l.cmcuenta limit 1);
		end loop;
	end if;
	--fsaldototal:=fsaldototal+fsaldo;
	--Para todas las subcuentas acumulables de la cuenta en cuestiona (si las hay) llama al proceso recursivo
	for r in 
		select cmcuenta,cmacumulable from catalogominimo2 where cmacumulable=cuenta and tipo_cta='C'
	loop
		select saldocatmin into fsaldo from saldocatmin(r.cmcuenta);
		--raise notice 'saldo=%',fsaldo;
		--raise notice 'saldo=%',fsaldo;
		fsaldototal:=fsaldototal+fsaldo;
		--fsaldototal:=fsaldototal*(select signo from catalogominimo2 where cmcuenta=r.cmcuenta limit 1);
	end loop;
	
return next fsaldototal;
end
$_$
    LANGUAGE plpgsql;-- SECURITY DEFINER;

	
	
	
