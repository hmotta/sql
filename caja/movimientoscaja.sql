
CREATE or replace FUNCTION movimientoscaja(character, character) RETURNS SETOF rmovimientoscaja
    AS $_$
declare
  r rmovimientoscaja%rowtype;
  pclavesocioint alias for $1;
  ptipomovimientoid alias for $2;

  l record;

 fcapital numeric;
 fnormal numeric;
 fmoratorio numeric;
 fiva numeric;
 rcapital numeric;
 
begin

    for r in
      select p.fechapoliza,p.seriepoliza,p.numero_poliza,mc.seriecaja,mc.referenciacaja,
             t.desctipomovimiento,refmovimiento(mc.prestamoid,mc.inversionid),m.debe,m.haber,
             t.tipomovimientoid,mc.movicajaid
        from movicaja mc,polizas p, movipolizas m,tipomovimiento t, socio s
       where s.clavesocioint = pclavesocioint and
             mc.socioid = s.socioid and
             p.polizaid = mc.polizaid and
             m.movipolizaid = mc.movipolizaid and
             (ptipomovimientoid='  ' or mc.tipomovimientoid=ptipomovimientoid) and
             t.tipomovimientoid = mc.tipomovimientoid 
    order by p.fechapoliza,mc.movicajaid

    loop
      if r.tipomovimientoid not in ('00','IN') then
        return next r;
      else
        if r.tipomovimientoid='00' then 
     
        fcapital := 0;
        fnormal := 0;
        fmoratorio := 0;
        fiva := 0;

        for l in
          select m.polizaid,t.cuentaactivo,t.cuentaintnormal,t.cuentaintmora,t.cuentaiva
            from movicaja m, prestamos pr, tipoprestamo t
           where m.movicajaid = r.movicajaid and
                 pr.prestamoid =  m.prestamoid and
                 t.tipoprestamoid = pr.tipoprestamoid
                 
        loop

          select sum(coalesce(haber-debe,0)) into fcapital
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaactivo and debe=0;
          select sum(coalesce(haber-debe,0)) into fnormal
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaintnormal;
          select sum(coalesce(haber-debe,0)) into fmoratorio
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaintmora;
          select sum(coalesce(haber-debe,0)) into fiva
            from movipolizas
           where polizaid = l.polizaid and
                 cuentaid = l.cuentaiva;
           
        end loop;

        if fcapital<>0 then
          r.desctipomovimiento:='Abono Capital';
          r.debe := fcapital;
          r.haber := 0;
          return next r;
        end if;
        if fnormal<>0 then
          r.desctipomovimiento:='Int. Normal';
          r.debe := fnormal;
          r.haber := 0;
          return next r;
        end if;
        if fmoratorio<>0 then
          r.desctipomovimiento:='Int. Morat.';
          r.debe := fmoratorio;
          r.haber := 0;
          return next r;
        end if;
        if fiva<>0 then
          r.desctipomovimiento:='IVA';
          r.debe := fiva;
          r.haber := 0;
          return next r;
        end if;
        
        else

          fcapital := 0;
          fnormal := 0;
          for l in
             select m.polizaid,t.cuentapasivo,t.cuentaintinver,t.cuentaprovisionisr from movicaja m, inversion i, tipoinversion t
           where m.movicajaid = r.movicajaid and
                 i.inversionid =  m.inversionid and
                 t.tipoinversionid = i.tipoinversionid
                 
          loop

            select sum(coalesce(haber,0)) into fcapital
              from movipolizas
             where polizaid = l.polizaid and
                   cuentaid = l.cuentapasivo and debe=0;
                   
            select sum(coalesce(debe,0)) into rcapital
              from movipolizas
             where polizaid = l.polizaid and
                   cuentaid = l.cuentapasivo and haber=0;
                   
            select sum(coalesce(debe,0)) into fnormal
               from movipolizas
               where polizaid = l.polizaid and
                  cuentaid = l.cuentaintinver;
         
            select sum(coalesce(haber,0)) into fiva
              from movipolizas
             where polizaid = l.polizaid and
                   cuentaid = l.cuentaprovisionisr;
           
          end loop;

            if fcapital<>0 then
              r.desctipomovimiento:='Capital Inversion';
              r.debe := fcapital;
              r.haber := 0;
              return next r;
            end if;

            if rcapital<>0 then
              r.desctipomovimiento:='Capital Inversion';
              r.debe := 0;
              r.haber := rcapital;
              return next r;
            end if;
          
            if fnormal<>0 then
              r.desctipomovimiento:='Int. Inversion';
              r.debe := fnormal;
              r.haber := fnormal;
              return next r;
            end if;
      
            if fiva<>0 then
              r.desctipomovimiento:='ISR Inversion';
              r.debe := fiva;
              r.haber := fiva;
              return next r;
            end if;
        
        end if;
      end if;
    end loop;


return;
end
$_$
    LANGUAGE plpgsql SECURITY DEFINER;

