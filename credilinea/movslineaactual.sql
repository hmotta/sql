drop type rmovimientoslinea cascade;
create type rmovimientoslinea as (
	polizaid integer,
	num_mov integer,
	fecha date,
	concepto character varying(200),
	debe numeric,
	haber numeric,
	saldo numeric,
	tipomov int
);
CREATE or replace FUNCTION movslineaactual(integer) RETURNS SETOF rmovimientoslinea
    AS $_$
declare
  r rmovimientoslinea%rowtype;
  pprestamoid alias for $1;
  l record;
 fcargo numeric;
 fabono numeric;
 fsaldo numeric;
 fcapital_disp numeric;
 fcapital_pag numeric;
 fseguro numeric;
 fiva_seguro numeric;
 dfecha_corte date;
 fnormal numeric;
 fmoratorio numeric;
 fiva numeric;
 fpago_total numeric;
 fsaldo_inicial numeric;
 ncorteid integer;
 nnum integer;
begin
	fsaldo := 0;
	nnum := 1;
	
	select fecha_otorga,montoprestamo into dfecha_corte,fsaldo_inicial from prestamos where prestamoid=pprestamoid;
	
	select corteid into ncorteid from corte_linea where lineaid=pprestamoid order by fecha_corte desc limit 1;
	if FOUND then
		--Ya hay un corte anterior, se cambian las variables iniciales
		select fecha_corte,saldo_final into dfecha_corte,fsaldo_inicial from corte_linea where corteid=ncorteid;
	end if;
	
    for r in
      select p.polizaid,0 as num_mov,p.fechapoliza as fecha,'' as concepto,0 as debe,0 as haber,0 as saldo
        from polizas p, movipolizas mp,tipoprestamo tp, prestamos pr
       where pr.prestamoid = pprestamoid and
             p.polizaid = mp.polizaid and
			 mp.prestamoid = pr.prestamoid and
             tp.tipoprestamoid = pr.tipoprestamoid and p.fechapoliza between dfecha_corte and current_date group by p.polizaid,p.fechapoliza
    order by p.fechapoliza

    loop
        fcargo := 0;
        fabono := 0;
		fcapital_disp := 0;
		 fcapital_pag := 0;
		 fseguro := 0;
		 fiva_seguro := 0;
		 fnormal := 0;
		 fmoratorio := 0;
		 fiva := 0;

        for l in
          select mp.polizaid,t.cuentaactivo,t.cuentaintnormal,t.cuentaintmora,t.cuentaiva
            from movipolizas mp, prestamos pr, tipoprestamo t
           where mp.polizaid = r.polizaid and
                 pr.prestamoid =  mp.prestamoid and
                 t.tipoprestamoid = pr.tipoprestamoid
                 
        loop

		select sum(coalesce(debe-haber,0)) into fcapital_disp
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaactivo and haber=0;
				 raise notice 'fcapital_disp=%',fcapital_disp;
		select sum(coalesce(haber-debe,0)) into fseguro
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = '6101080601' and debe=0;
				 
		select sum(coalesce(haber-debe,0)) into fiva_seguro
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = '2305090401' and debe=0;
		select sum(coalesce(haber-debe,0)) into fcapital_pag
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaactivo and debe=0;
				 raise notice 'fcapital_pag=%',fcapital_pag;
	
          select sum(coalesce(haber-debe,0)) into fnormal
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaintnormal and debe=0;
				 
          select sum(coalesce(haber-debe,0)) into fmoratorio
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaintmora and debe=0;
				 
          select sum(coalesce(haber-debe,0)) into fiva
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaiva and debe=0;
           
        end loop;
	
		fiva_seguro:=coalesce(fiva_seguro,0);
		fseguro:=coalesce(fseguro,0);
		fcapital_disp:=coalesce(fcapital_disp,0);
		fcapital_pag:=coalesce(fcapital_pag,0);
		fnormal:=coalesce(fnormal,0);
		fmoratorio:=coalesce(fmoratorio,0);
		fiva:=coalesce(fiva,0);
		
		if fcapital_disp<>0 then
		  r.num_mov:=nnum;
          r.concepto:='Disposicion';
          r.debe := fcapital_disp-(fseguro+fiva_seguro);
          r.haber := 0;
		  r.tipomov := 1;
		  fsaldo_inicial := fsaldo_inicial - r.debe + r.haber;
		  r.saldo := fsaldo_inicial;
          return next r;
		  nnum:=nnum+1;
        end if;
		
		if fseguro<>0 then
		  r.num_mov:=nnum;
          r.concepto:='Seguro de monto dispuesto';
          r.debe := fseguro+fiva_seguro;
          r.haber := 0;
		  r.tipomov := 2;
		  fsaldo_inicial := fsaldo_inicial - r.debe + r.haber;
		  r.saldo := fsaldo_inicial;
          return next r;
		  nnum:=nnum+1;
        end if;
		
		fpago_total := fcapital_pag + fnormal + fmoratorio + fiva;
		raise notice 'fpago_total=%',fpago_total;
		
		if fpago_total<>0 then
		  r.num_mov:=nnum;
          r.concepto:='Pago';
          r.debe := 0;
          r.haber := fpago_total;
		  r.tipomov := 3;
		  fsaldo_inicial := fsaldo_inicial - r.debe + r.haber;
		  r.saldo := fsaldo_inicial;
          return next r;
		  nnum:=nnum+1;
        end if;
        
    end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;