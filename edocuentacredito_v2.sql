-- Function: edocuentacredito(date, date, text, text)

-- DROP FUNCTION edocuentacredito(date, date, text, text);

CREATE OR REPLACE FUNCTION edocuentacredito(date, date, text, text)
  RETURNS SETOF tedocuentacredito AS
$BODY$
declare
pfecha alias for $1;
pfecha2 alias for $2;
pclave alias for $3;
preferencia alias for $4;
r tedocuentacredito%rowtype;
l record;
navales integer;
nmovimientos integer;
begin
	select count(*) into navales from avales a,prestamos p where a.aceptada=1 and a.prestamoid=p.prestamoid and p.referenciaprestamo=preferencia;
	--select saldoprestamo into saldo from prestamos p where p.referenciaprestamo=preferencia;
	select count(*) into nmovimientos from edocuenta(preferencia,pfecha2);
    select c.fecha from sujeto s,socio so, consultaburo c 	where s.curp=c.curp and s.sujetoid=so.sujetoid and so.clavesocioint=pclave 	and c.fecha>=pfecha and c.fecha<=pfecha2 order by c.fecha desc limit 1
	
	if nmovimientos>0 then
		return next r;
	end if;
	

for l in
	select 
	fecha,
	serie,
	nopoliza,
	referenciacaja,
	monto_prestamo,
	capital,
	interes,
	moratorio,
	iva,
	total,
	saldoinicial,
	saldofinal,
	saldocobranza,
	comisiones 
	from edocuenta(preferencia,pfecha2)
	loop
	 
	    r.fecha:=l.fecha;
		r.serie:=l.serie;
		r.nopoliza:=l.nopoliza;
		r.referenciacaja:=l.referenciacaja;
		r.monto_prestamo:=l.monto_prestamo;
		r.capital:=l.capital;
		r.interes:=l.interes;
		r.moratorio:=l.moratorio;
		r.iva:=l.iva;
		r.total:=l.total;
		r.saldoinicial:=l.saldoinicial;
		r.saldofinal:=l.saldofinal;
		r.saldocobranza:=l.saldocobranza;
		r.comisiones:=l.comisiones;
return next r;

		end loop;		
				
return;
end
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

