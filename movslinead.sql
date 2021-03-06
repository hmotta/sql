CREATE or replace FUNCTION movslinead(integer,date,date,integer) RETURNS SETOF rmovimientoslinea
    AS $_$
declare
  r rmovimientoslinea%rowtype;
  pprestamoid alias for $1;
  pfecha1 alias for $2;
  pfecha2 alias for $3;
  pdesglose alias for $4;
  l record;

 fcargo numeric;
 fabono numeric;
 fsaldo numeric;
 
 fcapital_disp numeric;
 fcapital_pag numeric;
 fseguro numeric;
 fiva_seguro numeric;
 fnormal numeric;
 fmoratorio numeric;
 fiva numeric;
 fpago_total numeric;

 nnum integer;
begin
	nnum:=0;
	fsaldo := 0;
	  r.num_mov:=0;
	  r.concepto:='Saldo Incial';
	  r.debe := 0;
	  r.haber := 0;
	  r.tipomov := 0;
	  r.saldo := fsaldo;
	  return next r;
	  nnum:=nnum+1;
	  
    for r in
      select p.polizaid,0 as num_mov,p.fechapoliza as fecha,'' as concepto,0 as debe,0 as haber,0 as saldo
        from polizas p, movipolizas mp,tipoprestamo tp, prestamos pr
       where pr.prestamoid = pprestamoid and
             p.polizaid = mp.polizaid and
			 mp.prestamoid = pr.prestamoid and
			 p.fechapoliza between pfecha1 and pfecha2 and 
             tp.tipoprestamoid = pr.tipoprestamoid  group by p.polizaid,p.fechapoliza
    order by p.polizaid,p.fechapoliza

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
          select mp.polizaid,ct.cta_cap_vig,ct.cta_int_vig_resultados,ct.cta_mora_vig_resultados,ct.cta_iva
            from movipolizas mp, prestamos pr, cat_cuentas_tipoprestamo ct
           where mp.polizaid = r.polizaid and
                 pr.prestamoid =  mp.prestamoid and
                 (ct.cat_cuentasid = pr.cat_cuentasid)
                 
        loop

		select sum(coalesce(debe-haber,0)) into fcapital_disp
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cta_cap_vig and haber=0;
				 
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
                 cuentaid = l.cta_cap_vig and debe=0;
				 raise notice 'fcapital_pag=%',fcapital_pag;
	
          select sum(coalesce(haber-debe,0)) into fnormal
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cta_int_vig_resultados and debe=0;
				 
          select sum(coalesce(haber-debe,0)) into fmoratorio
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cta_mora_vig_resultados and debe=0;
				 
          select sum(coalesce(haber-debe,0)) into fiva
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cta_iva and debe=0;
           
        end loop;
		
		fcapital_disp:=coalesce(fcapital_disp,0);
		fseguro:=coalesce(fseguro,0);
		fiva_seguro:=coalesce(fiva_seguro,0);
		fcapital_pag:=coalesce(fcapital_pag,0);
		fnormal:=coalesce(fnormal,0);
		fmoratorio:=coalesce(fmoratorio,0);
		fiva:=coalesce(fiva,0);

		if fcapital_disp-(fseguro+fiva_seguro)<>0 then
		  r.num_mov:=nnum;
          r.concepto:='Disposicion';
          r.debe := fcapital_disp-(fseguro+fiva_seguro);
          r.haber := 0;
		  r.tipomov := 1;
		  fsaldo := fsaldo + r.debe - r.haber;
		  r.saldo := fsaldo;
          return next r;
		  nnum:=nnum+1;
        end if;
		
		if fseguro<>0 then
		  r.num_mov:=nnum;
          r.concepto:='Seguro de monto dispuesto';
          r.debe := fseguro+fiva_seguro;
          r.haber := 0;
		  r.tipomov := 2;
		  fsaldo := fsaldo + r.debe - r.haber;
		  r.saldo := fsaldo;
          return next r;
		  nnum:=nnum+1;
        end if;
		
		if pdesglose=0 then
			fpago_total := fcapital_pag + fnormal + fmoratorio + fiva;
			raise notice 'fpago_total=%',fpago_total;
			if fpago_total<>0 then
			  r.num_mov:=nnum;
			  r.concepto:='Pago';
			  r.debe := 0;
			  r.haber := fpago_total;
			  r.tipomov := 7;
			  fsaldo := fsaldo - r.debe + fcapital_pag;
			  r.saldo := fsaldo;
			  return next r;
			  nnum:=nnum+1;
			end if;
		else
			if fcapital_pag<>0 then
			  r.num_mov:=nnum;
			  r.concepto:='Abono Capital';
			  r.debe := 0;
			  r.haber := fcapital_pag;
			  r.tipomov := 3;
			  fsaldo := fsaldo + r.debe - r.haber;
			  r.saldo := fsaldo;
			  return next r;
			  nnum:=nnum+1;
			end if;
			if fnormal<>0 then
			  r.num_mov:=nnum;
			  r.concepto:='Int. Normal';
			  r.debe := 0;
			  r.haber := fnormal;
			  r.tipomov := 4;
			  fsaldo := fsaldo;
		      r.saldo := fsaldo;
			  return next r;
			  nnum:=nnum+1;
			end if;
			if fmoratorio<>0 then
			  r.num_mov:=nnum;
			  r.concepto:='Int. Morat.';
			  r.debe := 0;
			  r.haber := fmoratorio;
			  r.tipomov := 5;
			  fsaldo := fsaldo;
		      r.saldo := fsaldo;
			  return next r;
			  nnum:=nnum+1;
			end if;
			if fiva<>0 then
			  r.num_mov:=nnum;
			  r.concepto:='IVA';
			  r.debe := 0;
			  r.haber := fiva;
			  r.tipomov := 6;
			  fsaldo := fsaldo;
		      r.saldo := fsaldo;
			  return next r;
			  nnum:=nnum+1;
			end if;
		end if;
    end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;