create type rsaldolineadias as (
	dia integer,
	fecha date,
	saldo_inicial numeric,
	cargo numeric,
	abono numeric,
	saldo_final numeric
);

CREATE or replace FUNCTION saldolineadias(integer,date,date) RETURNS SETOF rsaldolineadias
    AS $_$
declare
  r rsaldolineadias%rowtype;
  pprestamoid alias for $1;
  pfecha1 alias for $2;
  pfecha2 alias for $3;
 
  l record;

 fcargo numeric;
 fabono numeric;
 fsaldo numeric;
 
 xsaldo_inicial numeric;
 xcargo numeric;
 xabono numeric;
 xsaldo_final numeric;
 fseguro numeric;
 fiva_seguro numeric;
 fnormal numeric;
 fmoratorio numeric;
 fiva numeric;
 ndias integer;
 i integer;
 dfecha date;
begin
	fsaldo := 0;
	ndias:=pfecha2-pfecha1;
	raise notice 'ndias=%',ndias;
	dfecha:=pfecha1;
	xsaldo_inicial:=0;
	if exists (select * from corte_linea where lineaid=pprestamoid and fecha_corte=pfecha1) then
		select coalesce(saldo_final,0) into xsaldo_inicial from corte_linea where lineaid=pprestamoid and fecha_corte=pfecha1;
	end if;
    for i in 1..ndias loop
        r.dia:=i;
		r.fecha:=dfecha;
		r.saldo_inicial:=xsaldo_inicial;
		select coalesce(sum(debe),0) into xcargo from movslinead(pprestamoid,dfecha,dfecha,0) where tipomov in (1,2);
		r.cargo:=xcargo;
		select coalesce(sum(haber),0) into xabono from movslinead(pprestamoid,dfecha,dfecha,0) where tipomov in (7);
		xcargo:=coalesce(xcargo,0);
		xabono:=coalesce(xabono,0);
		
		r.abono:=xabono;
		xsaldo_final:=xsaldo_inicial + xcargo - xabono;
		r.saldo_final:=xsaldo_final;
		return next r;
		
		dfecha:=dfecha+1;
		xsaldo_inicial:=xsaldo_final;
    end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;