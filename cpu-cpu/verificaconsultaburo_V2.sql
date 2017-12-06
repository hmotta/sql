drop type rverificaconsulta cascade;
create type rverificaconsulta as (
	consultaid integer,
	ultimafecha date,
	cadena text
);
create or replace function verificaconsultaburo(character,character,character,character,date,character,character,character) returns SETOF rverificaconsulta
AS $_$
declare
	ppaterno alias for $1;
	pmaterno alias for $2;
	pprimer_nombre alias for $3;
	psegundo_nombre alias for $4;
	pfecha_nacimiento alias for $5;
	prfc alias for $6;
	pcurp alias for $7;
	pife alias for $8;
	r rverificaconsulta%rowtype;
begin
	--select coalesce(max(cb.consultaid),0),max(fecha) into r.consultaid,r.ultimafecha from consultaburo cb,respuestaburo rb where paterno=sburo(ppaterno) and materno=sburo(pmaterno) and primer_nombre=sburo(pprimer_nombre) and segundo_nombre=sburo(psegundo_nombre) and fecha_nacimiento=pfecha_nacimiento and substr(rfc,1,10)=substr(prfc,1,10) and cb.consultaid=rb.consultaid;
	select coalesce(max(cb.consultaid),0),max(fecha) into r.consultaid,r.ultimafecha from consultaburo cb,respuestaburo rb where paterno=sburo(ppaterno) and materno=sburo(pmaterno) and primer_nombre=sburo(pprimer_nombre) and segundo_nombre=sburo(psegundo_nombre) and fecha_nacimiento=pfecha_nacimiento and cb.consultaid=rb.consultaid;
	--r.consultaid=653;
	--r.ultimafecha='2015-01-01';
	if r.consultaid =0 then
		select coalesce(max(cb.consultaid),0),max(fecha) into r.consultaid,r.ultimafecha from consultaburo cb,respuestaburo rb where paterno=sburo(ppaterno) and materno=sburo(pmaterno) and fecha_nacimiento=pfecha_nacimiento and cb.consultaid=rb.consultaid;
	end if;
	
	if r.consultaid =0 then
		select coalesce(max(cb.consultaid),0),max(fecha) into r.consultaid,r.ultimafecha from consultaburo cb,respuestaburo rb where paterno=sburo(ppaterno) and materno=sburo(pmaterno) and primer_nombre=sburo(pprimer_nombre) and segundo_nombre=sburo(psegundo_nombre) and cb.consultaid=rb.consultaid;
	end if;
	
	select cadena into r.cadena from respuestaburo where consultaid=r.consultaid;
	
	return next r;
end
$_$
	LANGUAGE plpgsql SECURITY DEFINER;
