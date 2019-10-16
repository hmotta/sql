create or replace function ultimafechaburo(integer) returns date
AS $_$
declare
	psujetoid alias for $1;
	ppaterno character varying(20);
	pmaterno character varying(20);
	pprimer_nombre character varying(40);
	psegundo_nombre character varying(40);
	pfecha_nacimiento date;
	prfc character varying(16);
	pcurp character varying(20);
	--pife alias for $8;
	dultimafecha date;
	pposicion integer;
	pnombre character varying(40);
begin
	
	select sburo(paterno),sburo(materno),sburo(nombre),trim(rfc),trim(curp),fecha_nacimiento into ppaterno,pmaterno,pnombre,prfc,pcurp,pfecha_nacimiento from sujeto su where su.sujetoid=psujetoid;
		
	IF ppaterno='' AND pmaterno<>'' THEN
		ppaterno:=pmaterno;
		pmaterno:='';
	end if;
	
	IF pmaterno='' THEN 
		pmaterno:='NO PROPORCIONADO' ;
	END IF;
		
	
	pposicion := position(' ' in pnombre);
	IF pposicion > 3 THEN
		pprimer_nombre:=substring(pnombre,0,pposicion);
		psegundo_nombre :=substring(pnombre,pposicion+1,character_length(pnombre));
	ELSE
		pprimer_nombre:=pnombre;
		psegundo_nombre:='';
	END IF;
	--raise notice '%,%,%,%,%,%,%',(ppaterno),(pmaterno),(pprimer_nombre),psegundo_nombre,(prfc),(pcurp),pfecha_nacimiento;
	
	select coalesce(ultimafecha,'2000-01-01') into dultimafecha from verificaconsultaburo(ppaterno,pmaterno,pprimer_nombre,psegundo_nombre,pfecha_nacimiento,prfc,pcurp,'');
	--raise notice '%',dultimafecha;
	return  dultimafecha;
	--return  current_date;
end
$_$
	LANGUAGE plpgsql SECURITY DEFINER;
