drop type rinteresdiario cascade;
create type rinteresdiario as (
	num integer,
	fecha date,
	--concepto varchar(80),
	--cargo numeric,
	--abono numeric,
	saldo numeric,
	interes_diario numeric,
	interes_acumulado numeric
	--total_pago numeric
	
);
CREATE or replace FUNCTION calcula_int_ord_linea(integer,date) RETURNS SETOF rinteresdiario
    AS $_$
declare
	pprestamoid alias for $1;
	pfecha alias for $2;
	r rinteresdiario%rowtype;
    dfecha_adeudo_interes date;
	dfecha_inicial date;
	ndias_interes integer;
	
	xsaldo_anterior numeric;
	xsaldo_actual numeric;
	xsaldo numeric;
	xtasa_ordinaria numeric;
	dfecha_otorga date;
begin
	select fecha_otorga,tasanormal into dfecha_otorga,xtasa_ordinaria from prestamos  where prestamoid = pprestamoid;
	raise notice 'fecha_otorga=%',dfecha_otorga;
	--Lo primero es sacar la fecha a partir de la cual se va a calcular el interes (fecha de disposicion o fecha de ultimo pago de interes)
	--Primero se saca la fecha de ultimo pago de interes
	select ultimoabonointeres into dfecha_adeudo_interes from ultimoabonointeres(pprestamoid,pfecha);
	raise notice 'ultimoabonointeres=%',dfecha_adeudo_interes;
	if dfecha_adeudo_interes=dfecha_otorga then --no ha pagado interes entonces se toma la fecha de la primera disposicion que tuvo y apartir de ahi se empieza a calcular el interes
		select min(fecha) into dfecha_inicial from movslinead(pprestamoid,dfecha_otorga,pfecha,0) where tipomov in (1,2);
		raise notice 'Primera Disposicion=%',dfecha_inicial;
	else
		dfecha_inicial:=dfecha_adeudo_interes;
	end if;
	raise notice 'Fecha inicial=%',dfecha_inicial;
	ndias_interes:=pfecha - dfecha_inicial;
	raise notice 'Dias de interes: %',ndias_interes;
	-- Empieza el algoritmo de calculo a partir de la fecha inicial
	
	r.interes_acumulado:=0;
	for i in 1..ndias_interes loop
		r.num := i;
		r.fecha:=dfecha_inicial+i;
		select spssaldoadeudolineafecha into r.saldo from spssaldoadeudolineafecha(pprestamoid,r.fecha);
		--raise notice 'Saldo=%',r.saldo;
		r.interes_diario:=round(r.saldo*(xtasa_ordinaria/100/360),6);
		r.interes_acumulado:=r.interes_acumulado+r.interes_diario;
		return next r;
	end loop;

end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;