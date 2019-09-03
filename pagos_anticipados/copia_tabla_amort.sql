CREATE or replace FUNCTION copia_tabla_amort(integer) RETURNS integer
AS $_$
declare
	pprestamoid alias for $1;
	nversion integer;
	r record;
  begin
	select max(version) into nversion from credito_amortizaciones_historico where prestamoid=pprestamoid;
	nversion:=COALESCE(nversion,0);
	nversion:=nversion+1;
	raise notice 'version=%',nversion;
	
	for r in
		select * from amortizaciones where prestamoid=pprestamoid
	loop
		insert into credito_amortizaciones_historico(prestamoid,numamortizacion,fechadepago,importeamortizacion,interesnormal,saldo_absoluto,interespagado,  abonopagado,ultimoabono,iva,totalpago,ahorro,ahorropagado,cobranza,cobranzapagado,moratoriopagado,version) values (r.prestamoid,r.numamortizacion,r.fechadepago,r.importeamortizacion,r.interesnormal,r.saldo_absoluto,r.interespagado,r.abonopagado,r.ultimoabono,r.iva,r.totalpago,r.ahorro,r.ahorropagado,r.cobranza,r.cobranzapagado,r.moratoriopagado,nversion);
	end loop;
  return 1;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

